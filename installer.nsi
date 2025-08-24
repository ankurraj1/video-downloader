; Video Downloader NSIS Installer Script
; This creates a professional Windows installer with ffmpeg bundled

!define APPNAME "Video Downloader"
!define COMPANYNAME "Your Company"
!define DESCRIPTION "Download videos in best quality with yt-dlp"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0
!define HELPURL "https://github.com/yourusername/video-downloader"
!define UPDATEURL "https://github.com/yourusername/video-downloader/releases"
!define ABOUTURL "https://github.com/yourusername/video-downloader"

; Request admin rights for proper installation
RequestExecutionLevel admin

; Include required headers
!include "MUI2.nsh"
!include "FileFunc.nsh"

; Define installer properties
Name "${APPNAME}"
OutFile "VideoDownloaderSetup.exe"
InstallDir "$PROGRAMFILES\${APPNAME}"
InstallDirRegKey HKLM "Software\${APPNAME}" "InstallDir"

; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Pages
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

; License file (create a simple one if needed)
!system 'echo GNU General Public License > LICENSE.txt'

; Version information
VIProductVersion "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "ProductVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
VIAddVersionKey "FileDescription" "${DESCRIPTION}"
VIAddVersionKey "FileVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.0"
VIAddVersionKey "CompanyName" "${COMPANYNAME}"
VIAddVersionKey "LegalCopyright" "© ${COMPANYNAME}"

; Default section - Core application
Section "Video Downloader (Required)" SecCore
    SectionIn RO ; Required section
    
    SetOutPath "$INSTDIR"
    
    ; Copy main application files
    File "video_downloader.py"
    File "requirements.txt"
    
    ; Create and set up virtual environment
    DetailPrint "Setting up Python virtual environment..."
    nsExec::ExecToLog 'python -m venv "$INSTDIR\venv"'
    
    ; Install Python packages
    DetailPrint "Installing required Python packages..."
    nsExec::ExecToLog '"$INSTDIR\venv\Scripts\pip.exe" install --upgrade pip'
    nsExec::ExecToLog '"$INSTDIR\venv\Scripts\pip.exe" install -r "$INSTDIR\requirements.txt"'
    nsExec::ExecToLog '"$INSTDIR\venv\Scripts\pip.exe" install pyinstaller'
    
    ; Create launcher script
    FileOpen $0 "$INSTDIR\run.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "title Video Downloader$\r$\n"
    FileWrite $0 "cd /d `"$INSTDIR`"$\r$\n"
    FileWrite $0 "set PATH=$INSTDIR\ffmpeg;%PATH%$\r$\n"
    FileWrite $0 "call venv\Scripts\activate.bat$\r$\n"
    FileWrite $0 "python video_downloader.py$\r$\n"
    FileWrite $0 "pause$\r$\n"
    FileClose $0
    
    ; Create start menu shortcuts
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\run.bat" "" "" 0
    CreateShortcut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "" 0
    
    ; Create desktop shortcut (optional)
    CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\run.bat" "" "" 0
    
    ; Write registry entries
    WriteRegStr HKLM "Software\${APPNAME}" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\run.bat"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANYNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "HelpLink" "${HELPURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMinor" ${VERSIONMINOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
    
    ; Calculate and write installation size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "EstimatedSize" "$0"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

; FFmpeg section - Essential for best quality
Section "FFmpeg (Required for Best Quality)" SecFFmpeg
    SectionIn RO ; Required section
    
    SetOutPath "$INSTDIR\ffmpeg"
    
    ; Download ffmpeg if not already present
    IfFileExists "$INSTDIR\ffmpeg\ffmpeg.exe" +3 0
    DetailPrint "Downloading FFmpeg..."
    inetc::get "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" "$TEMP\ffmpeg.zip" /END
    
    ; Extract ffmpeg
    IfFileExists "$TEMP\ffmpeg.zip" 0 +8
    DetailPrint "Extracting FFmpeg..."
    nsisunz::UnzipToLog "$TEMP\ffmpeg.zip" "$TEMP\ffmpeg-extract"
    
    ; Find and copy ffmpeg binaries
    FindFirst $0 $1 "$TEMP\ffmpeg-extract\ffmpeg-*"
    IfErrors +4 0
    CopyFiles "$TEMP\ffmpeg-extract\$1\bin\ffmpeg.exe" "$INSTDIR\ffmpeg\"
    CopyFiles "$TEMP\ffmpeg-extract\$1\bin\ffprobe.exe" "$INSTDIR\ffmpeg\"
    FindClose $0
    
    ; Clean up temporary files
    RMDir /r "$TEMP\ffmpeg-extract"
    Delete "$TEMP\ffmpeg.zip"
SectionEnd

; Uninstaller section
Section "Uninstall"
    ; Remove files
    RMDir /r "$INSTDIR\venv"
    RMDir /r "$INSTDIR\ffmpeg"
    Delete "$INSTDIR\video_downloader.py"
    Delete "$INSTDIR\requirements.txt"
    Delete "$INSTDIR\run.bat"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
    
    ; Remove shortcuts
    Delete "$DESKTOP\${APPNAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APPNAME}"
    
    ; Remove registry entries
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
    DeleteRegKey HKLM "Software\${APPNAME}"
SectionEnd

; Section descriptions
LangString DESC_SecCore ${LANG_ENGLISH} "Core application files and Python environment"
LangString DESC_SecFFmpeg ${LANG_ENGLISH} "FFmpeg for merging video and audio streams (required for best quality)"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFFmpeg} $(DESC_SecFFmpeg)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Check for Python installation
Function .onInit
    ; Check if Python is installed
    nsExec::ExecToStack 'python --version'
    Pop $0
    ${If} $0 != 0
        MessageBox MB_ICONSTOP "Python is not installed or not found in PATH.$\n$\nPlease install Python from https://www.python.org/downloads/ and make sure to check 'Add Python to PATH' during installation."
        Abort
    ${EndIf}
FunctionEnd