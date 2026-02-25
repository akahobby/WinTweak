# Shows the CLI app removal menu and prompts the user to select which apps to remove.
function Show-NimbusCliAppRemoval {
    PrintHeader "App Removal"

    Write-Output "> Opening Win11Reclaim app selection form..."

    $result = Show-NimbusAppSelection

    if ($result -eq $true) {
        Write-Output "You have selected $($script:SelectedApps.Count) apps for removal"
        AddParameter 'RemoveAppsCustom'

        SaveSettings

        # Suppress prompt if Silent parameter was passed
        if (-not $Silent) {
            Write-Output ""
            Write-Output ""
            Write-Output "Press enter to remove the selected apps or press CTRL+C to quit..."
            Read-Host | Out-Null
            PrintHeader "App Removal"
        }
    }
    else {
        Write-Host "Selection was cancelled, no apps have been removed" -ForegroundColor Red
        Write-Output ""
    }
}