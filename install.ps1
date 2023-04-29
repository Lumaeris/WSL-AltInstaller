Set-StrictMode -Off;

### Various checks

$platform = [string][System.Environment]::OSVersion.Platform
if(!($platform.StartsWith("Win"))) {
	[console]::error.writeline("WSL-AltInstaller: This script works and is intended only for the Windows system.")
	exit 1
}

if([System.Environment]::OSVersion.Version.Build -lt 19041) {
	[console]::error.writeline("WSL-AltInstaller: This script only supports Windows 11 and Windows 10 version 2004 or higher.")
	exit 1
}

if([System.Environment]::UserName -eq "Administrator") {
	# This can usually happen in AME10/11, VERY rarely by the user's own intent (which is stupid IMO).
	[console]::error.writeline("WSL-AltInstaller: You literally run this script as 'Administrator', not as your personal account. WSL and a distribution of your choice will only be installed on this system account and your personal account will not be able to run these applications.")
	if (Get-Command "amecs.exe" -ErrorAction SilentlyContinue) { 
		[console]::error.writeline("WSL-AltInstaller: Since you are using AME10/11, you can open 'Central AME Script' from the Start menu or by opening 'amecs' in the 'Run' application and apply 'Elevate User' temporarily.")
	} else {
		[console]::error.writeline("WSL-AltInstaller: We recommend that you log out of this system account and use only your own.")
	}
	exit 1
}

function is_elevated {
	return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if(!(is_elevated)) {
	[console]::error.writeline("WSL-AltInstaller: PowerShell was not run as an Administrator.")
	exit 1
}

### END: Various checks

if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -ne 'Enabled'){
   	"Enabling 'Virtual Machine Platform'..."
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform -LimitAccess
} else {
    "Virtual Machine Platform was already enabled."
}

if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -ne 'Enabled'){
    "Enabling 'Windows Subsystem for Linux'..."
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux -LimitAccess
} else {
    "Windows Subsystem for Linux was already enabled."
}
