#===================================================================================
#                             ooooooooooo                                                  
#        ,,,,,,,,,, ,,,,,       ooo      ooo                                 ;;;;;;        
#   ,,,,    ,,,,,  ,,,,,,       ooo       ooo                                ;;;;          
#  ,,,,,           ,,,,,        ooo        ooo      ooooo         ooooo     ;;;;;;;        
# ,,,,,           ,,,,,         ooo        ooo    oo     oo     oo    ooo   ;;;;;;;        
# ,,,,,            ,,,,         ooo        ooo   oo       oo   ooo           ;;;;          
# ,,,,,          ,              ooo        ooo  ooo       ooo  oo            ;;;;          
# ,,,,,,,,,,,,,  ,,,    ,,,,,,  ooo       ooo   ooo       oo   ooo           ;;;;          
#   ,,,,,,,,,,  ,,,,,,,    ,,,  ooo      ooo     ooo     ooo    ooo    oo    ;;;;          
#      ,,,,,,  ,,,,,,,,,,     ooooooooooo           ooooo         oooooo     ;;;;          
#===================================================================================
# Clear Document files (aka cldocf) is a (stupidly) symple Shell (bash) Script that
# uses native zip and unzip UNIX commands to edit ODT's and DOCX's metadata by 
# replacing the content of some XML files and repacking the docs. It is meant for 
# simple use: like sending a "fully anonimized" copy of a file to a Journal that asks
# for clean metadata.
#
# Warning!!!
# This file is the Windows port of the bash version for powershell. In order for it to work
# just drag the ODT or DOCX file inside this window
#
# Developed by: betor (https://github.com/BetoNetu)
# License: GNU/AGPL-V3 (https://www.gnu.org/licenses/agpl-3.0.en.html)

$script:IsCompiled = [System.IO.Path]::GetExtension((Get-Process -Id $pid).MainModule.FileName) -eq '.exe'

#==================================================================================
#                                 Options functions
#==================================================================================

param(
    [Alias("v", "verbose")]          # ON if compiled (.exe), OFF if raw (.ps1)
    [bool]$Verbose = $script:IsCompiled,
    
    [Alias("l", "logging")]          # ON if compiled (.exe), OFF if raw (.ps1)
    [bool]$Logging = $script:IsCompiled,
    
    [Alias("d", "data")]             # Show metadata info (always off by default)
    [switch]$Data,
    
    [Alias("h", "help")]            # Show help (always off by default)
    [switch]$Help,
    
    [string[]]$Files
)

# Assign the parameters to script-scoped variables
$script:VerboseMode = $Verbose
$script:Logging = $Logging
$script:ShowData = $Data
$script:ShowHelp = $Help

# ANSI colours (PowerShell 7+ supports them natively, for Windows PowerShell we use plain text)
$script:Bold = if ($Host.UI.RawUI.ForegroundColor) { "`e[1m" } else { "" }
$script:Reset = if ($Host.UI.RawUI.ForegroundColor) { "`e[0m" } else { "" }

$script:LOGO = @"
                             ooooooooooo                                                  
        ,,,,,,,,,, ,,,,,       ooo      ooo                                 ;;;;;;        
   ,,,,    ,,,,,  ,,,,,,       ooo       ooo                                ;;;;          
  ,,,,,           ,,,,,        ooo        ooo      ooooo         ooooo     ;;;;;;;        
 ,,,,,           ,,,,,         ooo        ooo    oo     oo     oo    ooo   ;;;;;;;        
 ,,,,,            ,,,,         ooo        ooo   oo       oo   ooo           ;;;;          
 ,,,,,          ,              ooo        ooo  ooo       ooo  oo            ;;;;          
 ,,,,,,,,,,,,,  ,,,    ,,,,,,  ooo       ooo   ooo       oo   ooo           ;;;;          
   ,,,,,,,,,,  ,,,,,,,    ,,,  ooo      ooo     ooo     ooo    ooo    oo    ;;;;          
      ,,,,,,  ,,,,,,,,,,     ooooooooooo           ooooo         oooooo     ;;;;          
"@

$script:SAY = "Try ${script:Bold}cldocf -h${script:Reset} | ${script:Bold}--help${script:Reset} for more info.`n"

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
function Write-Msg {
    param($Message)
    if ($script:VerboseMode) {
        Write-Host $Message
        if ($script:Logging -and $script:LogFile) {
            Add-Content -Path $script:LogFile -Value $Message
        }
    }
}

function Write-OutputLog {
    param($Message)
    Write-Host $Message
    if ($script:Logging -and $script:LogFile) {
        Add-Content -Path $script:LogFile -Value $Message
    }
}

function Handle-Error {
    param($Type)
    Write-Host "Error: $Type"
    if ($script:Files.Count -gt 1) {
        Write-Msg "Skipping to next file..."
        $script:ErrorCount++
        return $false
    }
    else {
        $script:ErrorCount++
        if ($script:Logging) {
            Write-Host "Log saved at: $($script:LogFile)"
        }
        Write-Host "Total files processed: 1. Success:0. ERRORS:1."
        Write-Host "Exiting..."
        exit 1
    }
}

function Show-Help {
    Write-Host "`n$script:LOGO"
    Write-Host "${script:Bold}Cl${script:Reset}ear ${script:Bold}Doc${script:Reset}ument ${script:Bold}f${script:Reset}iles - Remove metadata from DOCX and ODT internal XML files using zip`n"
    Write-Host "Usage: ${script:Bold}$(Split-Path $MyInvocation.ScriptName -Leaf)${script:Reset} [options] file.extension"
    Write-Host "  -v, --verbose   Enable verbose output"
    Write-Host "  -l, --logging   Enable verbose logging"
    Write-Host "  -d, --data      Show the replaced metadata files and new content"
    Write-Host "  -h, --help      Show this help"
}

function Show-Data {
    Write-Host "`n${script:Bold}Files Metadata information`n"
    Write-Host "${script:Bold}DOCX Metadata Info`n"
    Write-Host "${script:Bold}core.xml${script:Reset}:`n"
    @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://openxmlformats.org" xmlns:dc="http://purl.org" xmlns:dcterms="http://purl.org" xmlns:dcmitype="http://purl.org" xmlns:xsi="http://w3.org">
</cp:coreProperties>
'@
    Write-Host "`n${script:Bold}app.xml${script:Reset}:`n"
    @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://openxmlformats.org" xmlns:vt="http://openxmlformats.org">
	<TotalTime>0</TotalTime>
	<Application></Application>
	<AppVersion>0</AppVersion>
	<Company></Company>
</Properties>
'@
    Write-Host "`nRemoves ${script:Bold}custom.xml${script:Reset}.`n"
    Write-Host "${script:Bold}ODT Metadata Info`n"
    Write-Host "${script:Bold}meta.xml${script:Reset}:`n"
    @'
<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:dc="http://purl.org" office:version="1.3">
  <office:meta>
    <meta:editing-duration>PT0S</meta:editing-duration>
    <meta:editing-cycles>0</meta:editing-cycles>
  </office:meta>
</office:document-meta>
'@
}

function Start-Logging {
    $script:LogDir = Join-Path (Get-Location) "cldocf_logs"
    if (-not (Test-Path $script:LogDir)) {
        New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null
    }
    $timestamp = [DateTime]::Now.ToFileTime()
    $script:LogFile = Join-Path $script:LogDir "log_$timestamp.txt"
    try {
        Add-Content -Path $script:LogFile -Value "=============================="
        Add-Content -Path $script:LogFile -Value "=== Log started at $(Get-Date) ==="
        Add-Content -Path $script:LogFile -Value "=============================="
    }
    catch {
        Write-Host "Error: Failed to start logging! Proceeding anyway..."
        $script:Logging = $false
    }
}

function Write-FileWithoutBOM {
    param($Path, $Content)
    # Write UTF-8 without BOM to play nice with XML parsers
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# ----------------------------------------------------------------------
# Main logic
# ----------------------------------------------------------------------

# Handle help / data flags early
if ($script:ShowHelp) {
    Show-Help
    exit 0
}
if ($script:ShowData) {
    Show-Data
    exit 0
}

# Validate inputs
if (-not $Files -or $Files.Count -eq 0) {
    Write-Host "Error: No files specified. $script:SAY"
    exit 1
}

$script:ErrorCount = 0
$script:SuccessCount = 0
$script:Run = 0
$script:Files = $Files

# Start logging if requested
if ($script:Logging) {
    Start-Logging
}

# Process each file
foreach ($file in $Files) {
    if (-not (Test-Path -Path $file -PathType Leaf)) {
        Write-Host "Error: File '$file' not found."
        continue
    }

    $script:Run = 1
    Write-Msg "Processing started at $(Get-Date)"

    # Resolve full path to avoid issues with relative paths
    $InputFile = Resolve-Path -Path $file
    $Filename = Split-Path $InputFile -Leaf
    $Extension = [System.IO.Path]::GetExtension($Filename).TrimStart('.')
    $FilenameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($Filename)
    
    # Safe name for temp folder (remove problematic chars)
    $SafeName = $Filename -replace '[\(\)\[\]\{\}\s]', '_'
    $OutputFile = "${FilenameNoExt}_clean.${Extension}"
    $TempDir = Join-Path (Get-Location) "tmp_doc_$(Get-Date -Format 'yyyyMMddHHmmss')_$SafeName"

    # Log / verbose header
    if ($script:Logging -and $script:VerboseMode) {
        Write-OutputLog "================================"
        Write-OutputLog "Processing: $InputFile"
        Write-OutputLog "================================"
    }
    elseif ($script:Logging) {
        Add-Content -Path $script:LogFile -Value "================================"
        Add-Content -Path $script:LogFile -Value "Processing: $InputFile"
        Add-Content -Path $script:LogFile -Value "================================"
    }
    elseif ($script:VerboseMode) {
        Write-Msg "================================"
        Write-Msg "Processing: $InputFile"
        Write-Msg "================================"
    }

    Write-Msg "Variables defined"

    # --- Format-specific logic ---
    Write-Msg "Checking '$file' extension"

    try {
        switch ($Extension.ToLower()) {
            "docx" {
                Write-Msg "Trying to unpack .docx file..."

                # Create temp dir
                if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
                New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
                Write-Msg "Temp directory created: $TempDir"

                # Unpack
                Write-Msg "Unpacking $InputFile ..."
                if ($script:VerboseMode) {
                    Expand-Archive -Path $InputFile -DestinationPath $TempDir -Force -Verbose
                }
                else {
                    Expand-Archive -Path $InputFile -DestinationPath $TempDir -Force
                }
                Write-Msg "$InputFile unpacked!"

                # Write DOCX metadata
                Write-Msg "Editing metadata from $InputFile..."
                $corePath = Join-Path $TempDir "docProps\core.xml"
                $appPath = Join-Path $TempDir "docProps\app.xml"
                $customPath = Join-Path $TempDir "docProps\custom.xml"

                Write-Msg "Editing $corePath ..."
                $coreContent = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://openxmlformats.org" xmlns:dc="http://purl.org" xmlns:dcterms="http://purl.org" xmlns:dcmitype="http://purl.org" xmlns:xsi="http://w3.org">
</cp:coreProperties>
'@
                Write-FileWithoutBOM -Path $corePath -Content $coreContent

                Write-Msg "Editing $appPath ..."
                $appContent = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://openxmlformats.org" xmlns:vt="http://openxmlformats.org"><TotalTime>0</TotalTime>
    <Application></Application>
    <AppVersion>0</AppVersion>
    <Company></Company>
</Properties>
'@
                Write-FileWithoutBOM -Path $appPath -Content $appContent

                Write-Msg "Deleting $customPath ..."
                if (Test-Path $customPath) {
                    Remove-Item -Path $customPath -Force
                }
                Write-Msg "docProps edited!"
            }

            "odt" {
                Write-Msg "Trying to unpack .odt file..."

                # Create temp dir
                if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
                New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
                Write-Msg "Temp directory created: $TempDir"

                # Unpack
                Write-Msg "Unpacking $InputFile ..."
                if ($script:VerboseMode) {
                    Expand-Archive -Path $InputFile -DestinationPath $TempDir -Force -Verbose
                }
                else {
                    Expand-Archive -Path $InputFile -DestinationPath $TempDir -Force
                }
                Write-Msg "$InputFile unpacked!"

                # Write ODT metadata
                Write-Msg "Editing metadata from $InputFile..."
                $metaPath = Join-Path $TempDir "meta.xml"
                $metaContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:dc="http://purl.org" office:version="1.3">
<office:meta>
    <meta:editing-duration>PT0S</meta:editing-duration>
    <meta:editing-cycles>0</meta:editing-cycles>
</office:meta>
</office:document-meta>
'@
                Write-FileWithoutBOM -Path $metaPath -Content $metaContent
                Write-Msg "$metaPath edited!"
            }

            default {
                Handle-Error ".$Extension not supported."
                continue
            }
        }

        # --- Repack ---
        Write-Msg "Packing into $OutputFile ..."
        $OutputPath = Join-Path (Get-Location) $OutputFile
        if (Test-Path $OutputPath) { Remove-Item -Path $OutputPath -Force }

        if ($script:VerboseMode) {
            Compress-Archive -Path "$TempDir\*" -DestinationPath $OutputPath -Force -CompressionLevel Optimal -Verbose
        }
        else {
            Compress-Archive -Path "$TempDir\*" -DestinationPath $OutputPath -Force -CompressionLevel Optimal
        }

        # Test integrity (simple: try to open it)
        try {
            $test = Expand-Archive -Path $OutputPath -DestinationPath "$TempDir\_test" -ErrorAction Stop
            Remove-Item -Path "$TempDir\_test" -Recurse -Force
            Write-Msg "Integrity ok!"
        }
        catch {
            Write-Host "Warning: Repacked file may be corrupt, but keeping it."
        }

        Write-Msg "$OutputFile packed!"

        # --- Cleanup ---
        Write-Msg "Removing temp directory $TempDir ..."
        try {
            Remove-Item -Path $TempDir -Recurse -Force -ErrorAction Stop
            Write-Msg "$TempDir deleted!"
        }
        catch {
            Write-Host "Failed to delete $TempDir. The folder will remain in current directory."
        }

        Write-Host "Success! Clean file saved as: ${script:Bold}$OutputFile${script:Reset}."
        $script:SuccessCount++
    }
    catch {
        Handle-Error "Failed to process $file : $_"
        # Cleanup partial temp if exists
        if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue }
        continue
    }
}

# Final summary
if ($script:Run -eq 0) {
    Handle-Error "No valid file found. $script:SAY"
}
else {
    if ($script:Logging) {
        Write-Host "Log saved at: $($script:LogFile)."
    }
    $total = $script:SuccessCount + $script:ErrorCount
    Write-Host "Total files processed: $total. Success:$($script:SuccessCount). ERRORS:$($script:ErrorCount)."
}