#-----------------------------------------------------------------------------------------------------------------------
#Function reference and additional modules loading 
#Author:
#Purpose : The PurPose the script to generate Html Report and Generate it from Jeniks
#-----------------------------------------------------------------------------------------------------------------------

Import-Module .\Functionlibrary.ps1

Import-Module .\Set-HtmlCellcolor.ps1

Add-Type -AssemblyName System.Web

#-----------------------------------------------------------------------------------------------

$dir= `pwd

#Reading parameters from Jenkins -$env -Jenkins 

#$folder1=$env:Expected 
#$folder2=$env:Actual 




$folder1= "C:\TestData\BaselineComparePDFNewFiles" 
$folder2="C:\TestData\BaseDir"
$folder3= "C:\BackReportstext"

#creating reports directory if doesnot exists , if exists back up

    If (Test-Path -Path $folder3"\reports\") {

    $backup= Move-Item -Path $folder3"\Reports\" -Destination $folder3"\reports_"$(Get-date -f MM-dd-yyyy_HH_mm_ss)

    $reportDir = new-item -type directory $folder3"\reports\"

   #$reportDir = new-item -type directory "C:\BackReports"

         }
        Else 
      {

   # $reportDir = new-item -type directory $folder1"\..\reports\"
   # $reportDir = new-item -type "C:\BackReports"
     $reportDir = new-item -type directory $folder3"\reports\"

}

    Write-host "Expected Folder: "$folder1
    write-host "Actual Folder:  "$folder2
    Write-host "Report Folder:  "$reportDir


#Removing same filenames with different timestamps, taking only the last one 

    Write-host "Removing Duplicate Files-Start "

    remove-dups $folder1
    remove-dups $folder2

    Write-host "Removing Duplicate Files -Complete"

 #Extracting test from PDF flies and Storing in the text format 

    Write-host "PDF to Text File Conversion - Start"
    
    ProcessPDFFiles $folder1
    ProcessPDFFiles $folder2

    Write-host "PDF to Test File Conversion -Complete"

#Removing unwanted data from text files 

    Write-host "Text File Filtering - Start"
    
    Filter-Files $folder1
    Filter-Files $folder2

    Write-host "Text File Filtering - Complete"


#compare Report HTML Content 

Write-host "Files in Folders Comparison -Start: " $folder1 " and "$folder2

    $Header=@"
    <style>

    TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH {border-width: 1px;padding: 3px;border-style: solid;border-color: blue;background-color: green;}
    TD {border-width: 1px;padding: 3px;border-style: solid;border-color: blue;background-color: #CCEEFF;}
    </style>
    <title>
        PDF Files Comparison
    </title>
   
"@


#-------------------------------------------------------------------------------------------------------------------------
#Get All Files under $folder1,Filter out directories 


   #$folder1=$env:Expected 
   #$folder2=$env:Actual 
$folder1= "C:\TestData\BaselineComparePDFNewFiles" 
$folder2="C:\TestData\BaseDir"

  # $reportDir = Join-Path $folder3 "\..\reports\"
   $reportDir = Join-Path $folder3 "\reports\"
    $firstfolder = Get-ChildItem $folder1  -filter "*_fl.txt"| Where-object {-not $_.PsIsContainer}



    $faildedCount = 0
    $i=0
    $totalCount = $firstfolder.count
    Write-Host $_.FullName

    $firstfolder|ForEach-Object {

    $i= $i+1

    $Header = @"

      <style>
    TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH {border-width: 1px;padding: 3px;border-style: solid;border-color: blue;background-color: green;}
    TD {border-width: 1px;padding: 3px;border-style: solid;border-color: blue;background-color: #CCEEFF;}
    </style>
    <title>
        PDF Files Comparison
    </title>
    
"@

    Write-Progress -Activity "Searching Files" -Status "Searching File $i of  $totalcount" -PercentComplete ($i / $firstfolder.count * 100)

    #check if the file,From $folder1 exists with the same path under $folder2

    If (Test-path ( $_.FullName.Replace($folder1, $folder2) ) ) {

    Write-Host $_.FullName

    $results = Compare-Files $_.FullName $_.FullName.Replace($folder1,$folder2)

    If ($results -ne $null) {

    #List the paths of the files containing diffs 

    $fileSuffix = $_.FullName.TrimStart($folder1)

    $faildeCount = $failedcount + 1

    Write-Host $_.Name "is in each folder,but doest not match"

    $col= $_.FullName.Replace($folder1, $folder2)

    $report=$reportDir+$_.Name+".html"

    $detailedPre = "<h2 Style='color:blue;'> PDF Comparison Details:$_.Name </h2>"

    $combined = $reportDir+"CombinedDifferences.html"

    Write-Host "Detailed Report File for Differences in PDF: " $report

    #$results |Sort Line|Select -object -property "Line","Expected","Actual"|ConvertedTo-HTML -Head $Header -Precontent $pre |Set-CellColor $col -color "red" -Filter "$col -notlike 'Page*'"|out-File $report 

    #$results|Sort Line|Select -Object -property "Line","Expected","Actual"|ConvertedTo-HTML -Head $header -Precontent $detailedPre|Set-CellColor $col -color "red" -Filter "$col -notLike ''"|Out-File $report

    $results |Sort Line | Select-Object -Property "Line",$_.FullName,$_.FullName.Replace($folder1, $folder2) | ConvertTo-Html -Head $Header -PreContent $detailedPre | Set-CellColor $col -Color "Red" -filter "$col -notlike ''"|Out-File $report
    $results |Sort Line | Select-Object -Property "Line",$_.FullName,$_.FullName.Replace($folder1, $folder2) | ConvertTo-Html -Head $Header -PreContent $detailedPre | Set-CellColor $col -Color "Red" -filter "$col -notlike ''"|Out-File $combined -Append

            }
          }
        
        Else

        {

        $fileSuffix =$_.FullName.TrimStart($folder1)
        $failedcount= $failedcount+1
        Write-Host $_.Name + "Is Only in Folder1"

            }

        }

        $secondFolder = Get-ChildItem $folder2 -Filter "*_fl.txt"| Where-Object {-not $_.PsIsContainer}

        $i=0 

        $totalCount =$secondFolder.Count

        $secondFolder| ForEach-Object {

        $i= $i+1

        Write-Progress -Activity "Searching for files only on Second Folder" -Status "Searching File $i of $totalCount" -PercentComplete ($i/ $secondFolder.Count*100)

        #check if the file,From $folder2 ,exists with the same path under $folder1

        If (!(Test-Path($_.FullName.Replace($folder2, $folder1))))

        {

        $fileSuffix = $_.FullName.TrimStart($folder2)
        $failedCount=$failedCount+1

        Write-Host $_.Name " is only in folder 2"

        }



    }

    Write-host "Files in Folders Comparison -Complete:"

    #------------------------------------------------------------------------------------------------------------------
    #compare Report HTML -Generation 

    #$reportDir =Join-Path $folder1 "\..\reports\"
    $reportDir = Join-Path $folder3 "\reports\"

    $fol1 = Get-ChildItem $folder1 -Filter "*.pdf" | Where-Object {-not $_.PsIscontainer}
    $fol2 = Get-ChildItem $folder2 -Filter "*.pdf" | Where-Object { -not $_.PsIscontainer}

    $diffs= (Get-ChildItem $reportDir -Filter "*.html").Count -1

    $notexist =[Math]::abs($fol1.count - $fol2.Count)

    $detailedreport = "CombinedDifferences.html"


    $pre= "<h1 Style='Color:blue;'> PDF Files -Page wise comparison Details</h1>"

    $pre += "<h2 Style='Color:blue;'> Total Files in Folder: "+$folder1+" are:"+$fol1.count +"</h2>"

    $pre += "<h2 Style='Color:blue;'> Total Files in Folder : "+$folder2+" are:"+$fol2.count +"</h2>"

    $pre +="<h3 Style='Color:blue;'> Total number of differences in the files compared: <a href='$detailedreport'>"+$diff + "</a></h3>"

    $pre+="<h3 Style='Color:blue;'>Total number of files Not Compared as present in only one Folder: "+$notexist+"</h3>"

    $post= "<Br><i>Report Generated on $((Get-Date).ToString()) From $($env:Computername)</i>"


    $htmlreport1= $fol1 | ForEach-Object { 


        If( Test-path ( $_.FullName.Replace($folder1, $folder2) ) )

            {

        $col1= $_.Name
        $col2= "Exists"
        $Col3= "Exists"

        $reportfile=  $reportDir+$_.Name+ ".txt_fl.txt.html"
        $reportlink=  $_.Name+".txt_fl.txt.html"

        if ( Test-Path ($reportfile))
        
        {
        
            $col4 = "<a href ='$reportlink'>'Different'</a>"

        }

        Else
        {

        $col4="SAME"

            }
        }
        

        else {

                $col1= $_.Name
                $col2="Exists"
                $Col3="Does not Exists"
                $col4="No Comparison"

            }

       [PSCustomobject] @{

       FileName = $col1
       $folder1= $col2
       $folder2= $col3
       MatchResult= $Col4

        }}|Sort-Object -Property "MatchResult" | ConvertTo-Html -CSSUri HtmlReport.CSS -Head $Header -PreContent $Pre
        
        $htmlreport2= $fol2 | ForEach-Object { 


        If( ! (Test-path ( $_.FullName.Replace($folder2, $folder1) ) ) )

        {

      [PSCustomobject] @{

       FileName = $_.Name
       $folder1="Does Not Exists"
       $folder2="Exists"
       MatchResult="No Comparison"

                }
            }

        }|ConvertTo-Html -CSSUri HtmlReport.CSS -PostContent $Post 


        #htmlReport = $htmlReport1+$htmlReport2
        #|ConvertTO-Html -Cssuri HtmlReport.CSS -Head $Header -PreContent $Pre-PostContent $Post 

        $index=$reportDir+"Index.html"


        [System.web.HttpUtility]::HtmlDecode($htmlreport1)| Out-File $index

        [System.web.HttpUtility]::HtmlDecode($htmlreport2)| Out-File $index -Append

    #--------------------------------------------------------------------------------------------











