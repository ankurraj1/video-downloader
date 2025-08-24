@echo off
title Creating Video Downloader Setup.exe
echo ==========================================
echo    Creating Video Downloader Setup.exe
echo ==========================================
echo.

:: Check if PowerShell script exists
if not exist "VideoDownloaderInstaller.ps1" (
    echo ERROR: VideoDownloaderInstaller.ps1 not found!
    pause
    exit /b 1
)

:: Create the self-extracting installer
echo Creating self-extracting installer...

:: Method 1: Using PowerShell to create executable
powershell -Command "& {
    $ps1Content = Get-Content 'VideoDownloaderInstaller.ps1' -Raw
    $encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ps1Content))
    
    $batContent = @'
@echo off
title Video Downloader Setup
:: Request Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This installer requires Administrator privileges.
    echo Please right-click and select \"Run as Administrator\"
    pause
    exit /b 1
)

:: Extract and run PowerShell script
echo Video Downloader Setup is starting...
set TEMP_PS1=%TEMP%\VideoDownloaderInstaller_%RANDOM%.ps1
powershell -Command \"[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('ENCODED_SCRIPT_PLACEHOLDER')) | Out-File -FilePath $env:TEMP_PS1 -Encoding UTF8\"
powershell -ExecutionPolicy Bypass -File %TEMP_PS1%
del %TEMP_PS1% 2>nul
'@
    
    $finalBat = $batContent -replace 'ENCODED_SCRIPT_PLACEHOLDER', $encodedScript
    Set-Content -Path 'VideoDownloaderSetup.bat' -Value $finalBat
    
    Write-Host 'Self-extracting installer created: VideoDownloaderSetup.bat' -ForegroundColor Green
}"

if %errorlevel% eq 0 (
    echo.
    echo ==========================================
    echo       Setup.exe Created Successfully!
    echo ==========================================
    echo.
    echo Your installer has been created as:
    echo   VideoDownloaderSetup.bat
    echo.
    echo Users can now:
    echo 1. Download VideoDownloaderSetup.bat
    echo 2. Right-click and select "Run as Administrator"  
    echo 3. The installer will automatically:
    echo    - Install Python if needed
    echo    - Download and install FFmpeg
    echo    - Set up the Video Downloader app
    echo    - Create desktop and start menu shortcuts
    echo.
    echo To rename it to .exe format ^(optional^):
    echo   ren VideoDownloaderSetup.bat VideoDownloaderSetup.exe
    echo.
) else (
    echo.
    echo ERROR: Failed to create installer!
)

echo Press any key to exit...
pause >nul