# update of Chip DNA server service for EMV stations

# stop Chip DNA service

Stop-Service CreditcallChipDNAServer

# unpack new Chip DNA

cmd /c "C:\Tools\7za.exe" x -y C:\Software\CDNA1_11.zip -oC:\Chip DNA

# delete Chip DNA service

sc.exe \\server delete	"Creditcall-ChipDNAServer"

# create new Chip DNA service

sc.exe  