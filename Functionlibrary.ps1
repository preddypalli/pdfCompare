#=================================================================================================================================
#Name : Common FuncitonLibrary for Powershell PDF comparison
 
#Funtion Purpose : Get Data from PDF to Test file using itextsharp

#==================================================================================================================================

#Function to import itextsharp.dll  and Filter report types 

    Add-Type -Path .\itextsharp.dll
    Import-Module .\IncludeReports.ps1
#==================================================================================================================================


#Using itextsharp.dll (Open Source) ,Extract Data From PDF to Text Format and Save Files 


Function Get-PdfText

    {
        [CmdletBinding()]

        Param (

        [Parameter(Mandatory=$true)]
        [String] $pdfpath,
        [String] $txtpath

        )

        $reader=$null
        $pdfpath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($pdfpath)

            try   
         {
       
        $reader= New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $pdfpath
                
             }

             Catch
          {
             
             throw 

            }
    
    $prevpage=$null
    $text=$null

    #SimpleText Stratefy is fast and Easy to format 
    #Strategy = new-object 'itextsharp.text.pdf.parser.LocationTextExtrationStratefy

    $strategy = New-Object 'iTextsharp.text.pdf.parser.SimpleTextExtractionStrategy'

    #write-host "Total Pages:"Reader.Numberof Pages

    For ($page=1; $page  -le $reader.NumberofPages; $page++)

        {

        #write-host "Page :"$Page
        $s= [itextsharp.text.pdf.parser.pdfTextExtractor]::GetTextFromPage($reader,$page,$strategy)#.Split([Char]0X000A)

        if ($prevpage -ne $s)
        {
            $text= $s;
        }

        $prevpage = $s;
        }

        $text| Out-File $txtpath

        $reader.Close()
    }

#---------------------------------------------------------------------------------------------------
#Function Name : Compare-File (Comparing two text files)
#Purpose : This function will compare two text files and write the difference in another text file
 
#---------------------------------------------------------------------------------------------------

function Compare-Files {
<#
    .SYNOPSIS
        A wrapper and extension foir the built-in Compare-Object cmdlet to compare two txt based files and receive a side-by-side comparison (including Line numbes).
#>
	param(

        [Parameter(Mandatory=$true)]
        [String] $file1,
        [String] $file2)

    $col1=$file1
    $col2=$file2

	$content1 = Get-Content $file1
	$content2 = Get-Content $file2

    $comparedLines = Compare-Object $content1 $content2 | group { $_.InputObject.ReadCount } | Sort Name
	
	#$comparedLines = Compare-Object $content1 $content2 -IncludeEqual:$IncludeEqual -ExcludeDifferent:$ExcludeDifferent -SyncWindow 1 |
	  #  group { $_.InputObject.ReadCount } | sort Name

    
	$comparedLines | foreach {
		$curr=$_
		switch ($_.Group[0].SideIndicator){


			"==" 
                { $right=$left= $curr.Group[0].InputObject;
                break
                } 

			"=>" 
                 { 
					$right,$left = $curr.Group[0].InputObject,$curr.Group[1].InputObject;
					break 
				 }

			"<=" 
                   { 
					$right,$left = $curr.Group[1].InputObject,$curr.Group[0].InputObject;
					
					break 
				 }                                                                  
		}


        [PsCustomobject] @{

        Line=[int]$_.Name
        $col1=$left
        $col2=$right


        } 
	} 
}


#=============================================================================================================
#Function to Convert PDF files directory to Txt Files Directory
#=============================================================================================================

Function ProcessPDFFiles {

    [CmdletBinding()]

    Param(
        
        [Parameter(Mandatory=$true)]
        [String] $dir 
        )

        #Removing Any Existing text Files in PDF Directories,If Running Scripts Again to Generate textFiles on same folders

        Get-ChildItem $dir -Include *.txt  -Recurse| Foreach ($_) {Remove-Item $_.FullName}

        $files= Get-ChildItem $dir | Where {$_.Extension -eq ".pdf"}

        For ($i=0; $i -lt $files.count; $i++) {

        $pdffile= $files[$i].FullName
        $txtfile= $files[$i].FullName +".txt"

        Get-PDFText $pdffile $txtfile

        }
    }

#===================================================================================================================================

#-----------------------------------------------------------------------------------------------------------------------
#Function Name : Filter files 
#Purpose : This function will compare two text files and write the difference in another text file
#Author: Rajesh AG
#Date : 03/10/2017
#-----------------------------------------------------------------------------------------------------------------------

Function Filter-files {

[CmdletBinding()]

Param( [Parameter(Mandatory= $true)]
        [String] $dir         
)

$files = Get-ChildItem $dir | where {$_.extension -eq ".txt"}

Write-Host "Files in Folder" $files.count

for ($i=0; $i -lt $files.count; $i++) {

$fileprefix=$files[$i].Name.Substring(0,4)
$txtFile =$files[$i].FullName
$fltrfile= $txtFile + "_fl.txt"
$tmpfile=$txtFile + "_tmp.txt"
write-host $txtFile
Switch ($fileprefix)


{


   "Power" {
           
           Issu $txtFile

           }
           

           Default{
            
            #1/4/14 12:11:02AM
            #$fileprefix=$files[$i].Name.Substring(0,4)
            #$txtFile =$files[$i].FullName
            #$fltrfile= $txtFile+ "_f1.txt"
            #$tmpfile=$txtFile+ "_tmp.txt"

            $regex1= ":( )([0-9]{1})/+([0-9]{2})/+([0-9]{2})( )"
            $regex2="([0-9]{2})/+([0-9]{2})/+([0-9]{2,4})"
            $regex3="( )([0-9]{9})( )"
            $regex4="( )([0-9]+):+([0-9]+):+([0-9]+)(?:am|AM|pm|PM)"
            $regex5="( )( )([0-9]+):+([0-9]+)(?:am|AM|pm|PM)( )"
            $regex6=":( )([0-9]{1,2})/+([0-9]{2})/+([0-9]{2})( )( )"
            $regex7="( )"
            $regex8="([0-9]{9})"
            $regex9="([0-9]{2})/+([0-9]{2})/+([0-9]{2})"
             $regex10="([0-9]{1,2})/+([0-9]{2})/+([0-9]{4})"


            (Get-Content $txtFile) |ForEach-Object {

            $_   -replace $regex1,''`
                 -replace $regex2,''`
                 -replace $regex3,''`
                  -replace $regex4,''`
                 -replace $regex5,''`
                 -replace $regex6,''`
                   -replace $regex7,''`
                    -replace $regex8,''`
                      -replace $regex9,''`
                      -replace $regex10,''`

            } | Set-Content $tmpfile  | Get-Content $tmpfile |where {$_ -ne ""}| Set-Content $tmpfile
       # gc $tmpfile 

        $lines = (Get-Content $tmpfile)
        Foreach ($line in $lines) {

        if ( $line.StartsWith("Date/Tme Created"))  {

        #doubt

        $line=$line.Substring($line.IndexOf("Page"),9).Substring(0,$line.Substring($line.Indexof("Page"),9).LastIndexOf(" "))


        $line |Out-File $fltrfile -Append
        }

        Else{

        $line |Out-File $fltrfile -Append 

            }
        }
        rm $tmpfile
                      }
                 }
            }
        }


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Function remove-dups {

    [cmdletBinding()]

    Param(

    [Parameter(Mandatory=$true)]
    [String] $dir

    )

                $tmpdir =New-Item -ItemType Directory -Force -Path ($dir+"\temp\")

                $count = (Get-ChildItem -Filter "*.pdf" -Path $dir ).Count
                $temp=$null
                $oldfile=$null
                $fileprefix=$null
                $file=Get-ChildItem -Filter "*.pdf" -path $dir

     For($i=0; $i -lt $count; $i++) {

        $fileprefix=($file[$i].Name).Split(".")

    If ( $fileprefix[0] -eq $temp) {

            Move-Item -Path $oldfile -Destination $tmpdir

         }

            $temp=$fileprefix[0]
            $oldfile=$file[$i].FullName

    }

            $getfiles= Get-ChildItem -Filter "*.pdf" -Path $dir

            #write-host $getfiles.count 

    For ($i=0; $i -lt $getfiles.count; $i++) {

                $newfile= $dir+"\"+(($getfiles[$i].BaseName).Split(".")[0])+".pdf"

                #write-host $newfile 

                Rename-Item -path $getfiles[$i].FullName -NewName $newfile #-WhatIf
        
           }

    }


    #==================================================================================================================================================================================

















