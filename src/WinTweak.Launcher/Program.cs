using System.Diagnostics;
using System.IO.Compression;
using System.Reflection;
using System.Windows.Forms;

namespace WinTweak.Launcher;

static class Program
{
    private const string BundleResourceName = "WinTweak.Launcher.bundle.zip";
    private const string AppVersion = "1.0.0";

    [STAThread]
    static int Main()
    {
        string baseDir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "WinTweak");
        string bundleDir = Path.Combine(baseDir, "bundle", AppVersion);
        string logPath = Path.Combine(baseDir, "launcher.log");

        try
        {
            Directory.CreateDirectory(baseDir);

            if (!EnsureBundleExtracted(bundleDir, logPath))
            {
                Log(logPath, "Failed to extract or verify bundle.");
                ShowError(logPath, "WinTweak could not extract required files. See launcher.log.");
                return 1;
            }

            string scriptPath = Path.Combine(bundleDir, "WinTweak.ps1");
            if (!File.Exists(scriptPath))
            {
                Log(logPath, $"Script not found: {scriptPath}");
                ShowError(logPath, "WinTweak script not found after extract. See launcher.log.");
                return 1;
            }

            string powershell = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.System),
                "WindowsPowerShell", "v1.0", "powershell.exe");
            if (!File.Exists(powershell))
            {
                Log(logPath, "PowerShell not found at: " + powershell);
                ShowError(logPath, "PowerShell 5.1 not found. See launcher.log.");
                return 1;
            }

            var psi = new ProcessStartInfo
            {
                FileName = powershell,
                Arguments = $"-NoProfile -ExecutionPolicy Bypass -STA -File \"{scriptPath}\"",
                WorkingDirectory = bundleDir,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            Log(logPath, $"Starting: {psi.FileName} {psi.Arguments}");
            using var process = Process.Start(psi);
            if (process == null)
            {
                Log(logPath, "Process.Start returned null.");
                ShowError(logPath, "Failed to start PowerShell. See launcher.log.");
                return 1;
            }

            string stdout = process.StandardOutput.ReadToEnd();
            string stderr = process.StandardError.ReadToEnd();
            process.WaitForExit();

            if (stdout.Length > 0)
                Log(logPath, "stdout: " + stdout);
            if (stderr.Length > 0)
                Log(logPath, "stderr: " + stderr);
            Log(logPath, $"Exit code: {process.ExitCode}");

            if (process.ExitCode != 0)
            {
                ShowError(logPath,
                    $"PowerShell exited with code {process.ExitCode}. Check launcher.log for details.");
                return process.ExitCode;
            }

            return 0;
        }
        catch (Exception ex)
        {
            Log(logPath, ex.ToString());
            ShowError(logPath, $"Launcher error: {ex.Message}");
            return 1;
        }
    }

    static bool EnsureBundleExtracted(string bundleDir, string logPath)
    {
        string versionFile = Path.Combine(bundleDir, ".wintweak_version");

        if (Directory.Exists(bundleDir) && File.Exists(versionFile))
        {
            try
            {
                string exePath = Environment.ProcessPath;
                if (!string.IsNullOrEmpty(exePath) && File.Exists(exePath))
                {
                    DateTime exeTime = File.GetLastWriteTimeUtc(exePath);
                    DateTime versionTime = File.GetLastWriteTimeUtc(versionFile);
                    // If exe was rebuilt after the bundle was extracted, re-extract so bundle is up to date
                    if (exeTime > versionTime)
                        return ExtractBundle(bundleDir, versionFile, logPath);
                }
                if (File.ReadAllText(versionFile).Trim() == AppVersion &&
                    File.Exists(Path.Combine(bundleDir, "WinTweak.ps1")))
                    return true;
            }
            catch { /* re-extract on any doubt */ }
        }

        return ExtractBundle(bundleDir, versionFile, logPath);
    }

    static bool ExtractBundle(string bundleDir, string versionFile, string logPath)
    {
        try
        {
            if (Directory.Exists(bundleDir))
            {
                try
                {
                    Directory.Delete(bundleDir, recursive: true);
                }
                catch (Exception ex)
                {
                    Log(logPath, "Could not delete old bundle dir: " + ex.Message);
                    return false;
                }
            }

            Directory.CreateDirectory(bundleDir);

            Assembly asm = Assembly.GetExecutingAssembly();
            using Stream? stream = asm.GetManifestResourceStream(BundleResourceName);
            if (stream == null)
            {
                Log(logPath, "Embedded bundle resource not found: " + BundleResourceName);
                return false;
            }

            using var zip = new ZipArchive(stream, ZipArchiveMode.Read);
            zip.ExtractToDirectory(bundleDir, overwriteFiles: true);
            File.WriteAllText(versionFile, AppVersion);
            return true;
        }
        catch (Exception ex)
        {
            Log(logPath, "Extract failed: " + ex.ToString());
            return false;
        }
    }

    static void Log(string logPath, string message)
    {
        try
        {
            string dir = Path.GetDirectoryName(logPath)!;
            if (!string.IsNullOrEmpty(dir))
                Directory.CreateDirectory(dir);
            string line = $"[{DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}Z] {message}{Environment.NewLine}";
            File.AppendAllText(logPath, line);
        }
        catch { /* ignore */ }
    }

    static void ShowError(string logPath, string message)
    {
        string fullMessage = message + $"\n\nLog: {logPath}";
        MessageBox.Show(fullMessage, "WinTweak", MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
}
