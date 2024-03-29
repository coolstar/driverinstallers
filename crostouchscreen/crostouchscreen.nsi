!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "crostouchscreen"
!define VERSION "2.9.5"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$TEMP\${DRIVERNAME}"

Var dpinst

PageEx components
  ComponentText "Select which touchscreen model you have.  Click install to start the installation." "" ""
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

Section "Atmel MaxTouch Touchscreen"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\atmel"'
SectionEnd

Section "Elan Touchscreen"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\elan"'
SectionEnd

Section "Melfas Touchscreen"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\melfas"'
SectionEnd

Section "Raydium Touchscreen"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\raydium"'
SectionEnd