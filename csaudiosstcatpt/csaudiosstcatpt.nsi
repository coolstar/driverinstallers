!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "csaudiosstcatpt"
!define VERSION "1.0"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$TEMP\${DRIVERNAME}"

Var dpinst

PageEx components
  ComponentText "Select which components to install.  Click install to start the installation." "" ""
PageExEnd

Page instfiles

function .onInit
    ${If} ${RunningX64}
    	# do nothing
    ${Else}
        MessageBox MB_ICONSTOP "32-bit (x86) Windows is not supported. Please reinstall 64-bit Windows."
        Abort
    ${EndIf}
functionEnd

Section
  SetOutPath $INSTDIR
  File /r "drivers"
  StrCpy $dpinst "$INSTDIR\drivers\dpinst.exe"
SectionEnd

Section "CoolStar SST Audio"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\csaudiosstcatpt"'
SectionEnd

Section "Realtek ALC5677 Codec"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\rt5677"'
SectionEnd