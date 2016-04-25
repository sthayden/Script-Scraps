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

$version = "DotNet452.zip"

# download 7za to C:\Tools

Write-Host "Downloading 7-Zip"

$TOOLS_PATH = "C:\Tools"

if ((Test-Path $TOOLS_PATH) -eq 0) {
	New-Item -ItemType directory -Path $TOOLS_PATH
} else {
	write-host "Tools folder exists"
}

if ((Test-Path "C:\Tools\7za.exe") -eq 0) {
	DownloadFile "https://bcyclepublic.blob.core.windows.net/kiosk/7za.exe" "C:\Tools\7za.exe"
} else {
	write-host "7za program exists"
}

# download .NET framwork Version 4.5.2

Write-Host "Downloading .NET version 4.5.2"
DownloadFile "http://bcyclepublic.blob.core.windows.net/kiosk/DotNet452.zip" "C:\Tools\DotNet452.zip"


Start-Sleep -s 4


# Extract update

Write-Host "Extracting Update"
cmd /c "C:\Tools\7za.exe" x -y C:\Tools\DotNet452.zip -oC:\Software
Start-Sleep -s 4
