!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "sklkblsst"
!define VERSION "1.0"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"
SetCompressor /solid /final "lzma"

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

Section "Intel SKL/KBL Audio Bus"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\sklkblaudbus"'
SectionEnd

Section "Intel SKL/KBL Smart Sound"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\sklkblsst"'
SectionEnd

Section "Maxim 98357a Amplifier"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\max98357a"'
SectionEnd

Section "Analog Devices SSM4567 Amplifier"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\ssm4567"'
SectionEnd