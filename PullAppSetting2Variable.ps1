#Config Location
$webConfigPath = "C:\B-cycle\B-cycle.exe.Config" 

#Parse Config File
$xml = [xml](get-content $webConfigPath);
$root = $xml.get_DocumentElement();            

#Create Hash Table
$setting = @{}

#Put AppSettings into Hash Table
Foreach( $item in $root.appSettings.add)
{              
$setting.Add($item.key,$item.value)
}

#Put Hash Table values into Variables
$modem = $setting.ConnectionName
$manual = $setting.ManualCardEntryEnabled