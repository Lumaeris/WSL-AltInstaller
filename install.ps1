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

if(!((Get-CimInstance Win32_operatingsystem).OSArchitecture -eq "64-bit")) {
	[console]::error.writeline("WSL-AltInstaller: This script works only on a 64-bit Windows system.")
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

if(!((Get-NetConnectionProfile).IPv4Connectivity -contains "Internet" -or (Get-NetConnectionProfile).IPv6Connectivity -contains "Internet")) {
	[console]::error.writeline("WSL-AltInstaller: This script requires a stable Internet connection.")
	exit 1
}

### END: Various checks

$prevdir = (Get-Location).Path
$tempdir = [System.IO.Path]::GetTempPath()
Set-Location $tempdir
New-Item -Path "WSL-AltInstaller" -ItemType "directory" -Force > $null
Set-Location "WSL-AltInstaller"

if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -ne 'Enabled'){
	"Enabling 'Virtual Machine Platform'..."
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform -LimitAccess > $null
} else {
    "Virtual Machine Platform was already enabled."
}

if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -ne 'Enabled'){
    "Enabling 'Windows Subsystem for Linux'..."
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux -LimitAccess > $null
} else {
    "Windows Subsystem for Linux was already enabled."
}

$aria2 = Invoke-RestMethod -Uri https://api.github.com/repos/aria2/aria2/releases/latest | Select-Object -ExpandProperty assets | Select-Object -expand browser_download_url
$aria2link = $aria2[2]
Invoke-WebRequest $aria2link -OutFile "aria2.zip"
Expand-Archive .\aria2.zip
Move-Item "aria2\*\aria2c.exe" .
Remove-Item -LiteralPath "aria2" -Force -Recurse
Remove-Item -LiteralPath "aria2.zip"

if(!((Get-AppPackage).Name -like "*WindowsSubsystemForLinux*")) {
	$wsl = Invoke-RestMethod -Uri https://api.github.com/repos/microsoft/WSL/releases
	$wsllink = $wsl[0] | Select-Object -ExpandProperty assets | Select-Object -expand browser_download_url

	& ".\aria2c.exe" "-x16" "-k4M" $wsllink "-o" "wsl.msixbundle"
	Add-AppxPackage "wsl.msixbundle"
}

if(!((Get-AppPackage).Name -like "*Ubuntu*")) {
	& ".\aria2c.exe" "-x16" "-k4M" "https://aka.ms/wslubuntu" "-o" "ubuntu.appxbundle"
	Add-AppxPackage "ubuntu.appxbundle"
}

Set-Location ..
Remove-Item -LiteralPath "WSL-AltInstaller" -Force -Recurse
Set-Location $prevdir

"WSL-AltInstaller: The requested operation is successful (hopefully). Changes will not be effective until the system is rebooted."
