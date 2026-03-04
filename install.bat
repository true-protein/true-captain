@echo off
REM
REM True Captain Installer (Windows)
REM
REM Installs Claude Code skills to %USERPROFILE%\.claude\skills\
REM so they work from any directory. Run this once after downloading.
REM

echo.
echo   True Captain Installer  (v%VERSION%)
echo   ========================
echo.

set "SCRIPT_DIR=%~dp0"
set "SKILLS_SOURCE=%SCRIPT_DIR%.claude\skills"
set "SKILLS_TARGET=%USERPROFILE%\.claude\skills"
set "VERSION_FILE=%SCRIPT_DIR%VERSION"

set "VERSION=unknown"
if exist "%VERSION_FILE%" (
    set /p VERSION=<"%VERSION_FILE%"
)

if not exist "%SKILLS_SOURCE%" (
    echo   Error: Could not find skills in %SKILLS_SOURCE%
    echo   Make sure you're running this from the true-captain directory.
    exit /b 1
)

if not exist "%SKILLS_TARGET%" mkdir "%SKILLS_TARGET%"

set INSTALLED=0

for %%S in (true triage mail reply reply-with-availability weekly) do (
    if exist "%SKILLS_SOURCE%\%%S" (
        if exist "%SKILLS_TARGET%\%%S" (
            echo   Updating: /%%S
        ) else (
            echo   Installing: /%%S
        )
        xcopy /E /I /Y /Q "%SKILLS_SOURCE%\%%S" "%SKILLS_TARGET%\%%S" >nul
        set /a INSTALLED+=1
    )
)

REM Copy version file
copy /Y "%VERSION_FILE%" "%SKILLS_TARGET%\.true-utils-version" >nul

echo.
echo   Installed skills (v%VERSION%) to %SKILLS_TARGET%
echo.
echo   Next steps:
echo   1. Open Claude Code (from any directory)
echo   2. Run /true setup to configure your preferences
echo   3. Run /triage to start triaging your inbox
echo   4. Run /true to see all commands
echo.
pause
