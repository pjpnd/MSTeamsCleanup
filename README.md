# MSTeamsCleanup
<h2>Description</h2>
Unused profiles on the system do not receive updates to Teams, exposing the system to unnecessary risk. 
If a user is found to have a version of Teams that is not compliant (specified in the script as $targetVersion) the script will invoke two functions, "unInstallTeams" and "removeRoamingFolder".
The user will still be able to log in, and no user data is changed. Teams will typically boot up as a pre-defined startup application, and the application will still be able to update to a more compliant version. 
The target version is derived from ACAS scanning, and will need to be adjusted to meet changing version demands.

<h2>Notes</h2>
This is a neutral, baseline form of the script. To function properly, run this in an elevated (admin) PowerShell session. You will need to edit the script and make changes to the following variables to suit your specifc domain and user group needs. These are at the top of the script and are easy to adjust:

- $targetVersion

<h2>Requirements</h2>
The system must be able to run PowerShell scripts - verify the current execution policy via <code>Get-ExecutionPolicy</code> and temporarily change the policy using <code>Set-ExecutionPolicy Unrestricted</code>. Be sure to set the execution policy
back to the original policy after the script is finished running.
