@echo off
setlocal enabledelayedexpansion

:: ==========================================
:: Configuration: Define your tool paths here
:: ==========================================
set "CAPA_RULES=C:\Tools\capa-rules"
set "DIE_PATH=C:\Tools\die\diec.exe"
set "PESTATS_PATH=C:\Tools\pestats.py"
set "FLOSS_CMD=floss"

:: ==========================================
:: Input Handling
:: ==========================================

:: Check if a file path was passed as an argument (%~1)
if "%~1"=="" (
    echo No file path provided.
    set /p "INPUT_FILE=Enter the file path (relative or absolute): "
) else (
    set "INPUT_FILE=%~1"
)

:: Validate that the file exists
if not exist "%INPUT_FILE%" (
    echo ERROR: File not found: %INPUT_FILE%
    pause
    exit /b 1
)

:: Extract the directory and the FULL filename (with extension)
:: %~dp1 = Drive and Path
:: %~nx1 = Name and Extension (e.g., mssecsvc.exe)
set "FILE_DIR=%~dp1"
set "FULL_FILENAME=%~nx1"

:: Change to the directory of the input file so relative tools work if needed
:: But we will pass the FULL path to the tools to be safe
pushd "%FILE_DIR%"

echo.
echo Starting analysis for: %FULL_FILENAME%
echo Location: %CD%
echo.

:: ==========================================
:: Execution
:: ==========================================

:: 1. FLOSS
:: We pass the FULL path ("%INPUT_FILE%") to ensure it finds the file anywhere
echo [1/4] Running FLOSS...
call %FLOSS_CMD% "%INPUT_FILE%" -j > "%FULL_FILENAME%_floss.json"
if errorlevel 1 (
    echo WARNING: FLOSS failed or returned non-zero exit code.
) else (
    echo FLOSS completed.
)

:: 2. CAPA
echo [2/4] Running CAPA...
call capa.exe -r "%CAPA_RULES%" "%INPUT_FILE%" -j > "%FULL_FILENAME%_capa.json"
if errorlevel 1 (
    echo WARNING: CAPA failed or returned non-zero exit code.
) else (
    echo CAPA completed.
)

:: 3. DIE (Detect It Easy)
echo [3/4] Running DIE...
:: Using "%INPUT_FILE%" ensures the full path and extension are passed
call "%DIE_PATH%" -b -j "%INPUT_FILE%" > "%FULL_FILENAME%_die.json"
if errorlevel 1 (
    echo WARNING: DIE failed or returned non-zero exit code.
) else (
    echo DIE completed.
)

:: 4. PEStats (Python)
echo [4/4] Running PEStats...
call python "%PESTATS_PATH%" "%INPUT_FILE%" > "%FULL_FILENAME%_pestats.json"
if errorlevel 1 (
    echo WARNING: PEStats failed or returned non-zero exit code.
) else (
    echo PEStats completed.
)

:: ==========================================
:: Cleanup
:: ==========================================
popd

echo.
echo Analysis complete!
echo Generated files:
dir "%FULL_FILENAME%_*.json" /b
echo.
pause