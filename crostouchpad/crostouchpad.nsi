!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "crostouchpad"
!define VERSION "4.1.3"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$TEMP\${DRIVERNAME}"

Var dpinst

PageEx components
  ComponentText "Select which touchpad model you have.  Click install to start the installation." "" ""
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

Section "Cypress SMBus Touchpad (Acer C710)"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\cypresssmb"'
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\cypressint"'
SectionEnd

Section "Cypress Gen3 I2C Touchpad"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\cypress"'
SectionEnd

Section "Elan I2C Touchpad"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\elan"'
SectionEnd

Section "Atmel MaxTouch I2C Touchpad"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\atmel"'
SectionEnd

Section "Synaptics I2C Touchpad"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\synaptics"'
SectionEnd