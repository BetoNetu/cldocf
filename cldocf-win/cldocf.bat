@echo off
title cldocf - Clean Document Metadata

@echo off
title cldocf - Clean Document Metadata

REM ------------------------------------------------------------------
REM If no arguments were passed (double-click, no drag-drop), show header and ask for file
REM ------------------------------------------------------------------
if "%~1"=="" (
    powershell -NoProfile -Command "Write-Host @'
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
'@"
    echo.
    echo Please drag and drop your DOCX or ODT file onto this window.
    set /p "file=File path: "
    powershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File "%~dp0cldocf.ps1" "%file%"
) else (
    REM Arguments passed (e.g., drag-drop), run without re-printing the header
    powershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File "%~dp0cldocf.ps1" %*
)

pause