# ---------------------------------
$Credit = "Script version: 1.1
Date v1.0: 23/03/2020
Date v1.1: 24/04/2020
Author: Loïc GUYADER (froggy77)
-------
Generate a report to detect errors
with .bmp and .png images and to get
a color palette for each image
in a folder and its subfolders.
-------
Tested with:
    - PowerShell: v5.1
    - ImageMagick: v7.0.9
-------
v1.1: Correction of a bug with errors, 
because 'identify' and 'convert' commands
generate 2 errors for each object.
-------
"
# ---------------------------------


# Check if ImageMagick is in the environment variables
if ($($Env:Path -split ";") -match "ImageMagick") {

	#-------
	# Function to select a folder only and to bring to front the browser dialog box
	# Author: Digy, Source: https://stackoverflow.com/questions/25690038/how-do-i-properly-use-the-folderbrowserdialog-in-powershell/57494414#57494414
	# Author: Kaffee Krampus Source: https://stackoverflow.com/questions/54037292/folderbrowserdialog-bring-to-front/60196079#60196079
	Function Get-Folder($initialDirectory) {
		[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        # Set the browser dialog box
		$FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
		$FolderBrowserDialog.RootFolder = "MyComputer"
		$FolderBrowserDialog.Description = "ImageMagick Report - Select the folder containing the images (* .png, * .bmp)"
        # Activate it
		$Caller = [System.Windows.Forms.NativeWindow]::New()
		$Caller.AssignHandle([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
        # Action
		if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
		[void] $FolderBrowserDialog.ShowDialog($Caller)
		return $FolderBrowserDialog.SelectedPath
    }
    #-------

    # Add System.Web.HttpUtility
    Add-Type -AssemblyName System.Web

    # Select a folder
    $MainDir = [String]$(Get-Folder $PSScriptRoot)

    # Declaration of output files
    $HtmlFile = $PSScriptRoot + "\ImageMagick_Report.html"
    $LogFile = $PSScriptRoot + "\ImageMagick_Error.log"
    $LastDirName = $MainDir

	# Delete old files
	if (Test-Path $HtmlFile) {
		Remove-Item -Path $HtmlFile -ErrorAction SilentlyContinue
	}
	if (Test-Path $LogFile) {
		Remove-Item -Path $LogFile -ErrorAction SilentlyContinue
	}

	# Main
	&{
	$NbFiles = 0
	$NbErrors = 0
	$NbMaxColors = 64
	$LastErrorCount = $error.Count
	$MainContainer = "`r`n<div id=`"main-container`">`r`n"
    $Header = -join("
<div id=`"header`">
	<div id=`"logo`">
		<font>&#128056;</font>
	</div>
		<h1><span title=`"$Credit`">&#129534;</span> ImageMagick Report (*.png, *.bmp)</h1>
</div>")

	$Container = "<div id=`"container`">`r`n"
	$LinkMainDir = -join("<h2><a href=`"file:///", $MainDir, "`">&#x1f5c0;  ", $MainDir, "</a></h2>`r`n")
	$CloseDiv = "<br/>`r`n</div>`r`n</div>`r`n</div>`r`n"

	$IM_ArrayList = New-Object -TypeName "System.Collections.ArrayList"
	$IM_ArrayList.Add("`r`n<div id=`"right`">`r`n<table>`r`n") | Out-Null
	$IM_ArrayList.Add("<thead>`r`n") | Out-Null
	$IM_ArrayList.Add("<tr><th>FILE</th><th>STATUS</th><th>Nb COLORS</th><th>PALETTE</th></tr>`r`n") | Out-Null
	$IM_ArrayList.Add("</thead>`r`n") | Out-Null
	$IM_ArrayList.Add("<tbody>`r`n") | Out-Null
	$CountBMP = Get-ChildItem $DirName -Filter *.bmp | Measure-Object | ForEach-Object{$_.Count}
	$CountPNG = Get-ChildItem $DirName -Filter *.png | Measure-Object | ForEach-Object{$_.Count}
	$CountFiles = $CountBMP + $CountPNG
	if ($CountFiles -ne 0) {
		$IM_ArrayList.Add(-join("<tr class=dir><td colspan=`"4`">", "<a href=`"file:///", $LastDirName, "`">", "&#128193; ", $LastDirName, "</a>", "</td></tr>", "`r`n")) | Out-Null
	}
	Get-ChildItem -Path $LastDirName -Include @("*.png", "*.bmp") -Recurse |
		ForEach-Object {
			$BaseName = [System.IO.Path]::GetFileName($_.Fullname)
			$DirName = [System.IO.Path]::GetDirectoryName($_.Fullname)
			$NbFiles++
			$CountBMP = Get-ChildItem $DirName -Filter *.bmp | Measure-Object | ForEach-Object{$_.Count}
			$CountPNG = Get-ChildItem $DirName -Filter *.png | Measure-Object | ForEach-Object{$_.Count}
			$CountFiles = $CountBMP + $CountPNG
			$CountColors = 0
			if ($DirName -ne $LastDirName) {
				$LastDirName = $DirName
				if ($CountFiles -ne 0) {
					$IM_ArrayList.Add(-join("<tr class=`"dir`"><td colspan=`"4`">", "<a href=`"file:///", $LastDirName, "`">", "&#128193; ", $LastDirName, "</a>", "</td></tr>", "`r`n")) | Out-Null
				}
			}

			$Name = -join("<a href=`"file:///", $_.FullName, "`">", $BaseName, "</a>")
			$NbColors = identify -format %k $_.FullName
			$NbColors = [int]$NbColors
			$Palette = convert $_.FullName -format %c histogram:info:-
			if ($error.Count -gt $LastErrorCount) {
				if ($error[$LastErrorCount].Exception.Message.Contains("CRC")) {
					$Status = "KO : CRC error"
					$RowColor = " class=`"error`""
					$NbErrors++
				} else {
					$Status = "KO"
					$RowColor = " class=`"error`""
					$NbErrors++
				}
				$LastErrorCount = $error.Count
			} else {
				$Status = "OK"
				$RowColor = ""
			}
			if ($NbColors -eq 1) {
				$Regex = [Regex]::new("(?=\#)(.*?)(?=\s)")
				$Match = $Regex.Match($Palette )
				if($Match.Success) {
					$HexColor = $($Match.Value).Substring(0, 7)
					if ($HexColor -eq "#000000") {
						$HexBorW = "#fff"
						$StrBorW = "B"
						$xBorW = 8
					} else {
						$HexBorW = "#000"
						$StrBorW = "W"
						$xBorW = 6
					}
					if (($($Match.Value).Length -eq 7) -or ($($Match.Value).Length -eq 9 -and $($Match.Value).Substring(7, 2) -eq "FF")) {
						if ($HexColor -eq "#000000" -or $HexColor -eq "#FFFFFF") {
							$svg = -join("<svg width=`"24`" height=`"24`"><g><rect width=`"24`" height=`"24`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd`"/><text x=`"", $xBorW, "`" y=`"16`" fill=`"", $HexBorW, "`">", $StrBorW, "</text></g></svg>`r`n")
						} else {
							$svg = -join("<svg width=`"24`" height=`"24`"><rect width=`"24`" height=`"24`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd`"/></svg>`r`n")
						}
					} else {
						if ($HexColor -eq "#000000" -or $HexColor -eq "#FFFFFF") {
							$svg = -join("<svg width=`"24`" height=`"24`"><g><circle cx=`"12`" cy=`"12`" r=`"11`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd`"/><text x=`"", $xBorW, "`" y=`"16`" fill=`"", $HexBorW, "`">", $StrBorW, "</text></g></svg>`r`n")
						} else {
							$svg = -join("<svg width=`"24`" height=`"24`"><circle cx=`"12`" cy=`"12`" r=`"11`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd`"/></svg>`r`n")
						}
					}
				}
				$Colors = $svg
				$NbColors_span_text = -join("<span title=`"", $Palette.TrimStart(" "), "`">", [String]$NbColors, "</span>")
				$Palette_span_text = -join("<span title=`"", $Palette.TrimStart(" "), "`">", $Colors, "</span>")
			} elseif ($NbColors -gt 1 -and $NbColors -le $NbMaxColors) {
				$Colors = New-Object -TypeName "System.Collections.ArrayList"
				foreach ($elt in $Palette) {
					$elt_text = $elt.TrimStart(" ")
					$Regex = [Regex]::new("(?=\#)(.*?)(?=\s)")
					$Match = $Regex.Match($elt)   
					if($Match.Success) {
						$CountColors++
						if ($NbColors -gt 8 -and ($CountColors % 8) -eq 0) {
							$br = "<br/>`r`n"
						} else {
							$br = ""
						}
						$HexColor = $($Match.Value).Substring(0, 7)
						if ($HexColor -eq "#000000") {
							$HexBorW = "#fff"
							$StrBorW = "B"
							$xBorW = 8
						} else {
							$HexBorW = "#000"
							$StrBorW = "W"
							$xBorW = 6
						}
						if (($($Match.Value).Length -eq 7) -or ($($Match.Value).Length -eq 9 -and $($Match.Value).Substring(7, 2) -eq "FF")) {
							if ($HexColor -eq "#000000" -or $HexColor -eq "#FFFFFF") {
								$svg = -join("<span title=`"", $elt_text, "`"><svg width=`"24`" height=`"24`"><g><rect width=`"24`" height=`"24`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd", "`"/><text x=`"", $xBorW, "`" y=`"16`" fill=`"", $HexBorW, "`">", $StrBorW, "</text></g></svg></span>`r`n", $br)
							} else {
								$svg = -join("<span title=`"", $elt_text, "`"><svg width=`"24`" height=`"24`"><rect width=`"24`" height=`"24`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd", "`"/></svg></span>", "`r`n", $br)
							}
						} else {
							if ($HexColor -eq "#000000" -or $HexColor -eq "#FFFFFF") {
								$svg = -join("<span title=`"", $elt_text, "`"><svg width=`"24`" height=`"24`"><g><circle cx=`"12`" cy=`"12`" r=`"11`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd", "`"/><text x=`"", $xBorW, "`" y=`"16`" fill=`"", $HexBorW, "`">", $StrBorW,"</text></g></svg></span>`r`n", $br)
							} else {
								$svg = -join("<span title=`"", $elt_text, "`"><svg width=`"24`" height=`"24`"><circle cx=`"12`" cy=`"12`" r=`"11`" style=`"fill:", $HexColor, "; stroke-width:1; stroke:#ddd", "`"/></svg></span>`r`n", $br)
							}
						}
						$Colors.Add($svg) | Out-Null
					}
				}
				$Palette_text = $Palette.TrimStart(" ") -join "`r`n"
				$NbColors_span_text = -join("<span title=`"", $Palette_text, "`">", [String]$NbColors, "</span>")
				$Palette_span_text = [String]$Colors
			} else {
				$Palette_text = $Palette.TrimStart(" ") -join "`r`n"
				$NbColors_span_text = -join("<span title=`"", $Palette_text, "`">", [String]$NbColors, "</span>")
				$Palette_span_text = "<span title=`"Too many colors to display`">No preview</span>"
			}
			$IM_ArrayList.Add(-join("<tr", $RowColor, "><td>", $Name, "</td><td>", $Status, "</td><td>", $NbColors_span_text, "</td><td>", $Palette_span_text, "</td></tr>`r`n")) | Out-Null
			if ($Status -eq "OK") {
				Write-Host "|" -BackgroundColor Green -ForegroundColor Green -NoNewline
			} else {
				Write-Host "|" -BackgroundColor Red -ForegroundColor Red -NoNewline
			}
		}
	$IM_ArrayList.Add("</tbody>`r`n") | Out-Null
	$IM_ArrayList.Add("<tfoot>`r`n") | Out-Null
	$IM_ArrayList.Add("<tr><th>Number of files: $NbFiles</th><th>$NbErrors KO</th><th colspan=`"2`"></th></tr>`r`n") | Out-Null
	$IM_ArrayList.Add("</tfoot>`r`n") | Out-Null
	$IM_ArrayList.Add(-join("</table>", "`r`n`n")) | Out-Null

	# Log File
	if ($NbErrors -eq 0) {
		$LinkLog = -join("`r`n<br/><center><font style=`"color:#bababa; font-size: 16px; font-weight: bold; text-align:center;`">&#128462 ", "No error</font></center>`r`n")
	} else {
		$LinkLog = -join("`r`n<br/><center><a style=`"color:#ffbaba; font-size: 16px; font-weight: bold; text-align:center;`" href=`"file:///", $LogFile, "`">&#128462 ", "error.log</a></center>`r`n")
	}
	# Legend
	$Legend = -join("
<div id=`"left`">
<table>
    <thead>
        <tr><th colspan=`"2`">LEGEND</th></tr>
    </thead>
    <tbody>
        <tr><td style=`"text-align:center`"><svg width=`"24`" height=`"24`"><rect width=`"24`" height=`"24`" style=`"fill:#808080; stroke-width:1; stroke:#ddd`"/></svg></td><td>Opaque color</td></tr>
        <tr><td style=`"text-align:center`"><svg width=`"24`" height=`"24`"><circle cx=`"12`" cy=`"12`" r=`"11`" style=`"fill:#808080; stroke-width:1; stroke:#ddd`"/></svg></td><td>Color with transparency</td></tr>
        <tr><td style=`"text-align:center`">B</td><td>Black</td></tr>
        <tr><td style=`"text-align:center`">W</td><td>White</td></tr>
        <tr><td style=`"text-align:center; background-color:#ffbaba`">My File</td><td><span title=`"CRC: Cyclic Redundancy Check`">Error (such as a CRC error)</span></td></tr>
    </tbody>
</table>
$LinkLog
</div>")

		# Header including title and style
		$Style = "<style>
body {
    font-family: `"Segoe UI`", `"Trebuchet MS`", Arial, Helvetica, sans-serif;
    color:#000;
}
h1 {
    color: #000;
    text-shadow: 0px 3px #666;
	text-align: center;
}
h2 {
    color: #444;
    font-style: bold;
	text-shadow: 0px 3px #ddd;
	margin-left: 2em;
}
table {
	margin-left: auto;
	margin-right: auto;
    border: 1px solid #ddd;
    border-collapse: collapse;
	font-size: 12px;
}
th {
    border: 1px solid #ddd;
    background-color: #333;
    border: 1px solid #ddd;
    color: white;
    font-size: 14px;
    font-weight: bold;
}
tr:nth-child(even){
	background-color: #f2f2f2;
}
tr.error {
    background-color: #ffbaba;
}
tr.dir {
    background-color: #444;
    text-align: left;
	padding: 4px;
    color: #eee;
    font-size: 14px;
    font-weight: bold;
}
td {
    border: 1px solid #ddd;
    text-align: left;
	padding: 4px 4px 1px 4px;
}
td.error {
    background-color: #ffbaba;
}
a {
    color: inherit;
    text-decoration: inherit;
}
a:hover {
    text-shadow: 0 0 1px #999; 
}
<!-- input[type=text] {
    background-color: #444;
    border: 1px dashed #555;
    color: white;
    margin: 4px;
}
input[type=text]:focus {
    border: 1px dashed #777;
} -->
#main-container {
    width: 100%;
	height: 100%
}
#logo {
    width: 10%;
	overflow: hidden;
	position: fixed;
	top: 0;
	right: left;
	margin: 0;
	text-align: center;
	color: rgba(0, 0, 0, 0.2);
    font-size: 64px;
}
#header {
    width: 100%;
	overflow: hidden;
	background-color: #444;
	position: fixed;
	top: 0;
	right: 0;
}
#container {
    width: 100%;
	height: 85%;
	margin-top: 100px;
}
#left {
	float:left;
	width: 15%;
	position: fixed;
}
#right {
    float:center;
}
</style>"

	$Title = "<title>ImageMagick Report</title>"
	$Head = -join("`r`n`n", $Title, "`r`n", $Style, "`r`n")

	# Creation of the web page
	ConvertTo-HTML -Head "$Head" -Title "$Title" -Body $([System.Web.HttpUtility]::HtmlDecode("$MainContainer $Header $Container $LinkMainDir $Legend $IM_ArrayList $CloseDiv")) | Out-File -Encoding "UTF8" $HtmlFile 

	# Web page display
	Invoke-Item -Path $HtmlFile

	# Output the errors and the warnings in a log
	} 3>&1 2>&1 > $LogFile
} else {
	Write-Host "This script requires ImageMagick (https://imagemagick.org/)"
}