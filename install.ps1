Set-StrictMode -Off;
$ProgressPreference = 'SilentlyContinue'

#region Initial checks
$platform = [string][System.Environment]::OSVersion.Platform
if(!($platform.StartsWith("Win"))) {
	[console]::error.writeline("WSL-AltInstaller: This script works and is intended only for the Windows system.")
    pause
	exit 1
}

if([System.Environment]::OSVersion.Version.Build -lt 19041) {
	[console]::error.writeline("WSL-AltInstaller: This script only supports Windows 11 and Windows 10 version 2004 or higher.")
    pause
	exit 1
}

if(!((Get-CimInstance Win32_operatingsystem).OSArchitecture -eq "64-bit")) {
	[console]::error.writeline("WSL-AltInstaller: This script works only on a 64-bit Windows system.")
    pause
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
    pause
	exit 1
}

if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	[console]::error.writeline("WSL-AltInstaller: PowerShell was not run as an Administrator.")
    pause
	exit 1
}

if(!((Get-NetConnectionProfile).IPv4Connectivity -contains "Internet" -or (Get-NetConnectionProfile).IPv6Connectivity -contains "Internet")) {
	[console]::error.writeline("WSL-AltInstaller: This script requires a stable Internet connection.")
    pause
	exit 1
}

"WSL-AltInstaller v0.0.2-alpha"
""
#endregion

#region New ver
function InstallNew {
	if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -ne 'Enabled'){
		"WSL-AltInstaller: Enabling 'Virtual Machine Platform'..."
		Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform -LimitAccess | Out-Null
	} else {
		"WSL-AltInstaller: Virtual Machine Platform was already enabled."
	}

	$Aria2Exec = CheckAria2
	$WSLInstall = 0
	$UbuntuInstall = 0

	if(!((Get-AppPackage).Name -like "*WindowsSubsystemForLinux*")) {
		$wsl = Invoke-RestMethod -Uri https://api.github.com/repos/microsoft/WSL/releases
		$wsl = $wsl[0] | Select-Object -ExpandProperty assets | Select-Object -expand browser_download_url
		& $Aria2Exec "-x16" "-s16" "-k4M" $wsl "-o" "wsl.msixbundle"
		$WSLInstall = 1
	}

	if(!((Get-AppPackage).Name -like "*Ubuntu*")) {
		& $Aria2Exec "-x16" "-s16" "-k4M" "https://aka.ms/wslubuntu" "-o" "ubuntu.appxbundle"
		$UbuntuInstall = 1
	}

	if($WSLInstall) {
		Add-AppxPackage "wsl.msixbundle"
	}
	if($UbuntuInstall) {
		Add-AppxPackage "ubuntu.appxbundle"
	}

	if($WSLInstall -Or $UbuntuInstall) {
		"WSL-AltInstaller: The requested operation is successful (hopefully). Changes will not be effective until the system is rebooted."
	} else {
		"WSL-AltInstaller: No changes were made to the system."
	}
}
#endregion

#region Old ver
function InstallOld {
	if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -ne 'Enabled'){
		"WSL-AltInstaller: Enabling 'Virtual Machine Platform'..."
		Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform -LimitAccess | Out-Null
	} else {
		"WSL-AltInstaller: Virtual Machine Platform was already enabled."
	}

	if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -ne 'Enabled'){
		"WSL-AltInstaller: Enabling 'Windows Subsystem for Linux'..."
		Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux -LimitAccess | Out-Null
	} else {
		"WSL-AltInstaller: Windows Subsystem for Linux was already enabled."
	}

	"later"
}
#endregion

#region Check if aria2 was installed before
function CheckAria2 {
	if(Get-Command "aria2c" -ErrorAction SilentlyContinue | Select -ExpandProperty Source) {
		return "aria2c"
	} else {
		$aria2 = Invoke-RestMethod -Uri https://api.github.com/repos/aria2/aria2/releases/latest | Select-Object -ExpandProperty assets | Select-Object -expand browser_download_url
		Invoke-WebRequest $aria2[2] -OutFile "aria2.zip"
		Expand-Archive .\aria2.zip
		Move-Item "aria2\*\aria2c.exe" .
		Remove-Item -LiteralPath "aria2" -Force -Recurse
		Remove-Item -LiteralPath "aria2.zip"
		return ".\aria2c.exe"
	}
}
#endregion

#region Start
function StartScript {
	$prevdir = (Get-Location).Path
	$tempdir = [System.IO.Path]::GetTempPath() + "\WSL-AltInstaller"
	New-Item -Path $tempdir -ItemType "directory" -Force | Out-Null
	Set-Location $tempdir
	Invoke-WebRequest "https://raw.githubusercontent.com/Lumaeris/ps-menu/master/ps-menu.psm1" -OutFile "psm.psm1"
	Import-Module -Name ".\psm.psm1" -DisableNameChecking

	"This script can install the newer version of WSL 2 with support for GNU/Linux graphical"
	"applications and GPU acceleration and the older version for operating systems without"
	"UWP support (e.g. Windows Server)."
	""
	"For more information visit https://aka.ms/wsl"
	""
	"NOTE: Installation of the old version is not available at this time."
	""
	"Navigation is done with the up/down arrows or with the k/j buttons on the keyboard."
	"Press Enter to proceeed or press Esc to exit."
	""
	$sel = menu @("Newer version", "Oldest version") -ReturnIndex
	""
	if($sel -eq 0) {
		InstallNew
	} elseif($sel -eq 1) {
		InstallOld
	}

	Set-Location $prevdir
	Remove-Item -LiteralPath $tempdir -Force -Recurse
}
#endregion

StartScript
