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
set "FILE_COUNT=0"

if "%~1"=="" (
    echo No file path provided.
    set /p "SINGLE_FILE=Enter the file path (relative or absolute): "
    for %%X in ("!SINGLE_FILE!") do set "FILE_0=%%~fX"
    set "FILE_COUNT=1"
    goto :validate
)

:parse_args
if "%~f1"=="" goto :validate
set "FILE_!FILE_COUNT!=%~f1"
set /a FILE_COUNT+=1
shift
goto :parse_args

:validate
set "VALID_COUNT=0"
for /l %%i in (0,1,9) do (
    if %%i lss !FILE_COUNT! (
        set "F=!FILE_%%i!"
        if exist "!F!" (
            set /a VALID_COUNT+=1
        ) else (
            echo WARNING: File not found, skipping: !FILE_%%i!
        )
    )
)

if !VALID_COUNT!==0 (
    echo ERROR: No valid files found to process.
    pause
    exit /b 1
)

echo Found !VALID_COUNT! valid file(s) to process.
echo.

:: ==========================================
:: Process each file
:: ==========================================
set "PROCESSED=0"
set "FAILED=0"

for /l %%i in (0,1,9) do (
    if %%i lss !FILE_COUNT! (
        set "F=!FILE_%%i!"
        if exist "!F!" (
            call :analyze_file "!F!"
        )
    )
)

echo.
echo ==========================================
echo  Batch Complete: !PROCESSED! succeeded, !FAILED! failed
echo ==========================================
pause
exit /b 0

:: ==========================================
:: Subroutine: analyze_file
:: ==========================================
:analyze_file
set "INPUT_FILE=%~1"
set "FILE_DIR=%~dp1"
set "FULL_FILENAME=%~nx1"
set "TOOL_ERRORS=0"

pushd "%FILE_DIR%"

echo ==========================================
echo  Analyzing: %FULL_FILENAME%
echo  Location:  %CD%
echo ==========================================
echo.

:: 1. FLOSS
echo [1/4] Running FLOSS...
call %FLOSS_CMD% "%INPUT_FILE%" -j > "%FULL_FILENAME%_floss.json"
if errorlevel 1 (
    echo WARNING: FLOSS failed or returned non-zero exit code.
    set /a TOOL_ERRORS+=1
) else (
    echo FLOSS completed.
)

:: 2. CAPA
echo [2/4] Running CAPA...
call capa.exe -r "%CAPA_RULES%" "%INPUT_FILE%" -j > "%FULL_FILENAME%_capa.json"
if errorlevel 1 (
    echo WARNING: CAPA failed or returned non-zero exit code.
    set /a TOOL_ERRORS+=1
) else (
    echo CAPA completed.
)

:: 3. DIE (Detect It Easy)
echo [3/4] Running DIE...
call "%DIE_PATH%" -b -j "%INPUT_FILE%" > "%FULL_FILENAME%_die.json"
if errorlevel 1 (
    echo WARNING: DIE failed or returned non-zero exit code.
    set /a TOOL_ERRORS+=1
) else (
    echo DIE completed.
)

:: 4. PEStats (Python)
echo [4/4] Running PEStats...
call python "%PESTATS_PATH%" "%INPUT_FILE%" > "%FULL_FILENAME%_pestats.json"
if errorlevel 1 (
    echo WARNING: PEStats failed or returned non-zero exit code.
    set /a TOOL_ERRORS+=1
) else (
    echo PEStats completed.
)

popd

echo.
echo Generated files for %FULL_FILENAME%:
pushd "%FILE_DIR%"
dir "%FULL_FILENAME%_*.json" /b 2>nul
popd

if !TOOL_ERRORS!==0 (
    set /a PROCESSED+=1
    echo Status: SUCCESS
) else (
    set /a FAILED+=1
    echo Status: COMPLETED WITH !TOOL_ERRORS! WARNING(S)
)
echo.
goto :eof