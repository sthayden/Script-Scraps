#Purpose - update images according to program ID by downloading file associated with Program
# sthayden - 11feb15

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

#find and read config file
$ConfigPath = "C:\B-cycle\B-cycle.exe.Config"
$xml = [xml] $config = Get-Content $ConfigPath         

#set variables
$progid = (select-xml -path c:\b-cycle\b-cycle.exe.config -xpath "/configuration/appSettings/add[@key = 'ProgramId']").Node.value 
$downloadurl = "https://bcyclepublic.blob.core.windows.net/kiosk/"    
$file = $progid + "images.zip"          

#download 7za to c:\tools
$TOOLS_PATH = "C:\Tools"                         

if ((Test-Path $TOOLS_PATH) -eq 0) {
	New-Item -ItemType directory -Path $TOOLS_PATH
}

if ((Test-Path "C:\Tools\7za.exe") -eq 0) {
	DownloadFile "https://bcyclepublic.blob.core.windows.net/kiosk/7za.exe" "C:\Tools\7za.exe"
}
 
#download screenimages
DownloadFile $downloadurl$file "C:\Tools\screenimages.zip"

#close b-dog and b-cycle
taskkill /f /im b-dog.exe
taskkill /f /im b-cycle.exe
Start-Sleep -s 3

#extract images to b-cycle folder
cmd /c "C:\Tools\7za.exe" x -y C:\Software\screenimages.zip -oC:\B-cycle\images 
Start-Sleep -s 4

#restart b-dog.exe
start "C:\B-cycle\B-dog.exe"