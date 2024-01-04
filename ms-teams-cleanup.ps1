<#
.Synopsis
Remove Microsoft Teams for user profiles that do not meet or exceed a specified target version.
.DESCRIPTION
Fetches user profiles under the system drive (typically C:\Users) and iterates through those users to check the locally installed
version of Microsoft Teams. Unused profiles on the system do not receive updates to Teams, exposing the system to unnecessary risk.
If a user is found to have a version of Teams that is not compliant (specified in the script as $targetVersion) the script will
invoke two functions, "unInstallTeams" and "removeRoamingFolder". The user will still be able to log in, and no user data is changed.
Teams will boot up as a pre-defined startup application, and the application will update to a more compliant version. The target version
is derived from ACAS scanning, and will need to be adjusted to meet changing version demands.
#>

# Change TargetVersion variable to desired version
$targetVersion = "1.6.00.18681"
$targetArray = $targetVersion -split '\.' | ForEach-Object { [int]$_ }


# Pre-defined functions for doing the actual uninstall work
function unInstallTeams($path) {
    Write-Host "Uninstalling..."
    $clientInstaller = "$($path)\Update.exe"
    Start-Process -FilePath "$clientInstaller" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction SilentlyContinue
}

function removeRoamingFolder($roamingFolder) {
    if (Test-Path -Path $roamingFolder -PathType Container) {
        Remove-Item -Path "$roamingFolder\*" -Recurse -Force
        Write-Host "Local cache data removed from Roaming folder for user."
    } else {
        Write-Host "Roaming folder not found for user."
    }
}

# Get all users on the system
$Users = Get-ChildItem -Path "$($ENV:SystemDrive)\Users"

# Process all users
$Users | ForEach-Object {
        Write-Host "Process user: $($_.Name)" -ForegroundColor Yellow

        #Locate installation folder
        $localAppData = "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Microsoft\Teams"
        $programData = "$($env:ProgramData)\$($_.Name)\Microsoft\Teams"
        $roamingFolder = "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Roaming"

        if (Test-Path "$($localAppData)\current\Teams.exe") {
            $InstalledVersion = (Get-ItemProperty "$($localAppData)\current\Teams.exe").VersionInfo.FileVersion
            $installedVersionArray = $InstalledVersion -split '\.' | ForEach-Object { [int]$_ }

            Write-Host "Detected Version: $InstalledVersion"
        
            for ($i = 0; $i -lt $targetArray.Count; $i++) {
                if ($targetArray[$i] -gt $installedVersionArray[$i]) {
                    Write-Host "Processing chunk [$i]"
                    Write-Host "Teams (LocalAppData) outdated"
                    unInstallTeams($localAppData)
                    removeRoamingFolder($roamingFolder)
                } elseif ($targetArray[$i] -lt $installedVersionArray[$i]) {
                    Write-Host "Processing chunk [$i]"
                    Write-Host "Specified, compliant version is met or exceeded. No further processing needed."
                } else {
                    Write-Host "Processing chunk [$i]"
                    Write-Host "Current chunk is equal for both the installed version and the specified, compliant version"
                }
            }

        } elseif (Test-Path "$($programData)\current\Teams.exe") {
            $InstalledVersion = (Get-ItemProperty "$($programData)\current\Teams.exe").VersionInfo.FileVersion
            $installedVersionArray = $InstalledVersion -split '\.' | ForEach-Object { [int]$_ }

            Write-Host "Detected Version: $InstalledVersion"

            for ($i = 0; $i -lt $targetArray.Count; $i++) {
                if ($targetArray[$i] -gt $installedVersionArray[$i]) {
                    Write-Host "Processing chunk [$i]"
                    Write-Host "Teams (ProgramData) outdated"
                    unInstallTeams($localAppData)
                    removeRoamingFolder($roamingFolder)
                } elseif ($targetArray[$i] -lt $installedVersionArray[$i]) {
                    Write-Host "Processing chunk [$i]"
                    Write-Host "Specified, compliant version is met or exceeded. No further processing needed."
                } else {
                    Write-Host "Processing chunk [$i]"
                    Write-Host "Current chunk is equal for both the installed version and the specified, compliant version"
                }
            } 
        } else {
          write-Host "Teams not present for user $($_.Name)"  
        }

        
        If (Test-Path -Path "$localAppData\.dead") {
            removeRoamingFolder($roamingFolder)
        }
}
