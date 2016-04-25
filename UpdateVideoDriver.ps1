function DownloadFile($url, $targetFile)

{

   $uri = New-Object "System.Uri" "$url"

   $request = [System.Net.HttpWebRequest]::Create($uri)

   $request.set_Timeout(15000) #15 second timeout

   $response = $request.GetResponse()

   $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)

   $responseStream = $response.GetResponseStream()

   $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create

   $buffer = new-object byte[] 10KB

   $count = $responseStream.Read($buffer,0,$buffer.length)

   $downloadedBytes = $count

   while ($count -gt 0)

   {

       $targetStream.Write($buffer, 0, $count)

       $count = $responseStream.Read($buffer,0,$buffer.length)

       $downloadedBytes = $downloadedBytes + $count

       Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)

   }

   Write-Host "Finished downloading file"

   $targetStream.Flush()

   $targetStream.Close()

   $targetStream.Dispose()

   $responseStream.Dispose()

}

$TOOLS_PATH = "C:\Tools"
$DRIVERS_PATH = "C:\Drivers"

# download 7-zip
if ((Test-Path $TOOLS_PATH) -eq 0) {
	New-Item -ItemType directory -Path $TOOLS_PATH
}

if ((Test-Path "C:\Tools\7za.exe") -eq 0) {
	downloadFile "https://bcyclepublic.blob.core.windows.net/kiosk/7za.exe" "C:\Tools\7za.exe"
}

# download video driver update
if ((Test-Path $DRIVERS_PATH) -eq 0) {
	New-Item -ItemType directory -Path $DRIVERS_PATH
}

if ((Test-Path "C:\Drivers\Win7_Video_IEMGD_130630.zip") -eq 0) {
	downloadFile "https://bcyclepublic.blob.core.windows.net/kiosk/win7_video_IEMGD_130630.zip" "C:\Drivers\Win7_Video_IEMGD_130630.zip"
}

# Extract update
cmd /c "C:\Tools\7za.exe" x -y C:\Drivers\Win7_Video_IEMGD_130630.zip -oC:\Drivers

Start-Sleep -s 4

#install driver in eleveated powershell
cmd /c "C:\Drivers\IEMGD_HEAD_Windows7\setup.exe -nolic -overwrite -res '640x480x32x75' -s"

#wait
cmd /c "ping 1.1.1.1 -n 1 -w 10000 > nul"

#clean up
Remove-Item C:\Drivers\Win7_Video_IEMGD_130630.zip

#exit
exit
