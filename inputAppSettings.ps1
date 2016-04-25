# Config Location
$webConfigPath = "C:\B-cycle\B-cycle.exe.Config" 

# Parse Config File
$xml = [xml](get-content $webConfigPath);
$root = $xml.get_DocumentElement();

#replace values based off keys with predefined variables
foreach( $item in $root.appSettings.add)
{ 
    if($item.key –eq “ConnectionName”)
    { 
      $item.value = “$modem”
    } 
    if($item.key –eq “ManualCardEntryEnabled”)
    { 
      $item.value = “$manual”
    } 
    if($item.key –eq “LocalCulture”)    
    { 
      $item.value = “$local”
    } 
}