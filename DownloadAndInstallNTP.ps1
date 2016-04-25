$localStorage = "C:\B-Cycle\ntp\"
$remoteStorage = "https://bcyclepublic.blob.core.windows.net/kiosk/"

# make the ntp folder
If (!(Test-Path -Path $localStorage)) {
	New-Item -ItemType directory -Path $localStorage
}

$filename = "ntp.conf"
$Url = $remoteStorage + $filename
$ntpConfDownloadToPath = $localStorage + $filename

If (Test-Path $ntpConfDownloadToPath){
	Remove-Item -Force $ntpConfDownloadToPath
}

$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($Url, $ntpConfDownloadToPath)

$filename = "ntp-install.ini"
$Url = $remoteStorage + $filename
$ntpIniDownloadToPath = $localStorage + $filename

If (Test-Path $ntpIniDownloadToPath){
	Remove-Item -Force $ntpIniDownloadToPath
}

$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($Url, $ntpIniDownloadToPath)

$filename = "ntp-4.2.8-win32-setup.exe"
$Url = $remoteStorage + $filename
$ntpSetupDownloadToPath = $localStorage + $filename

If (!(Test-Path $ntpSetupDownloadToPath)){
	$webclient = New-Object System.Net.WebClient
	$webclient.DownloadFile($Url, $ntpSetupDownloadToPath)
}

# install
Write-Output ((Test-Path $ntpSetupDownloadToPath) -and (Test-Path $ntpConfDownloadToPath) -and (Test-Path $ntpIniDownloadToPath))
If ((Test-Path $ntpSetupDownloadToPath) -and (Test-Path $ntpConfDownloadToPath) -and (Test-Path $ntpIniDownloadToPath)) {
	 Start-Process -FilePath $ntpSetupDownloadToPath -ArgumentList "/USE_FILE=C:\B-Cycle\ntp\ntp-install.ini" -Wait
}
