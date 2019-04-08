

Function Issu {

[CmdletBinding()]

Param(

[Parameter(Mandatory =$true)]
[String]  $txtfile

)

#As of Date: 1/4/14 12:11:02AM
$regex1="([0-9]{1,2})/+([0-9]{1,2})/+([0-9]{1,2})(\\s)([0-9]+):+([0-9]+):+([0-9]+)(?:am|AM|pm|PM)"

$regex2="([0-9]{2})/+([0-9]{2})/+([0-9]{2,4})"

#(?:[2][0-3])|(?:[0-9])):(?:[0-5][0-9])(?::[0-5][0-9])
#"((?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Tues|Thur|Thurs|Sun|Mon|Tue|Wed|Thu|Fri|Sat))(,)(\s+)((?:Jan(?:uary)?|Feb(?ruray)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Sept|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?))(\s+)((?:(?:[0-2]?\d{1})|(


(Get-Content $txtfile) | ForEach-Object {

$_ -replace $regex1,'XXXX' `
    -replace $regex2,'XXXX' `

}|Set-Content $fltrfile

}