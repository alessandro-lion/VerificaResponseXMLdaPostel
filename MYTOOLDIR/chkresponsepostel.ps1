	#A. Lion 17/01/2023 Ver 1.0
	#Verifica in tutti i files della cartella passata come argument (compresi quelli in tutte le sue sottocartelle) se vi sono corrispondenze con l'espressione regolare impostata in RX
	#scrive tutti i match in un file csv nella cartella D:\WORK\LOGS\, ATTENZIONE se non ci sono match il file eventualmente presente per lo stesso giorno viene svuotato
	
	#ESEMPIO UTILIZZO da command prompt: powershell.exe -ExecutionPolicy ByPass -File "C:\MYTOOLDIR\chkResponse\chkresponsepostel.ps1" "D:\WORK\POSTEL\TOSEND\TOSEND\PTL_20230116.005"
	
	#24/01/2023 Ver 1.1 Verifica due espressioni regolari così da andare bene con response nexive che ha anche casi di errori non riportati sulla dashboard web
	#09/02/2023 Ver 1.2 Aggiunta Estrapolazione messaggio di errore riscontrato su response postel così da vederli senza dover aprire il response
	#     "      "   "  Aggiunta filtro per considerare solo le response degli ultimi 4 giorni così da poter invocare lo script sul folder root al posto che specificare le singole sottocartelle PTL
	
	
    $Directory = $args[0]
	
	$Filedate = Get-Date -format 'yyyy-MM-dd'
	
  $ResultsCSV = "C:\WORK\LOGS\chkresponsepostel." + $Filedate +".csv"
    
	$RX = "Error Code=`"[1-9]`" Message=`"[^][]*`""
	$RXNex ="<Header GlobalCode=`"[1-9]`"[^\!]*"
	
	$TextFiles = Get-ChildItem $Directory -Include *_Response.xml -Recurse | Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-7) } 

    $file2 =  new-object System.IO.StreamWriter($ResultsCSV) #output Stream
    $numrow=0
	$nummatch=0
    foreach ($FileSearched in $TextFiles) {   #loop over files in folder
        
        $file = New-Object System.IO.StreamReader ($FileSearched)  # Input Stream

        while ($text = $file.ReadLine()) {      # read line by line
            $numrow++
			#Write-Output "Esamino riga" + $numrow.ToString()
			foreach ($match in ([regex]$RX).Matches($text)) {   
				   if ($nummatch -eq 0)
					{
					    # write header line to output stream
						$file2.WriteLine('RIGA,ERROR MATCH,NOME FILE') # write header
					}
				   $nummatch++
				   # write line to output stream
                   $file2.WriteLine("{0},{1},{2}", $numrow.ToString(), $match.Value, $FileSearched.fullname )  
            } #foreach $match RX
			foreach ($match in ([regex]$RXNex).Matches($text)) {   
				   if ($nummatch -eq 0)
					{
					    # write header line to output stream
						$file2.WriteLine('RIGA,ERROR MATCH,NOME FILE') # write header
					}
				   $nummatch++
				   # write line to output stream
                   $file2.WriteLine("{0},{1},{2}", $numrow.ToString(), $match.Value, $FileSearched.fullname )  
            } #foreach $match RXNex			
        }#while $file
         $file.close();  
		 $numrow=0
    } #foreach  
    $file2.close()
