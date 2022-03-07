$DNSrecords = ipconfig /displayDNS | select-string 'Record Name' | sort -Unique
foreach($record in $DNSrecords) { 
	write-host $record.ToString().Split(' ')[-1]
   } 
   