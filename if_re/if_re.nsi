!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "if_re"
!define VERSION "1.0.2"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$TEMP\${DRIVERNAME}"

Var dpinst

PageEx components
  ComponentText "Select which i2c controller you have.  Click install to start the installation." "" ""
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

Section "Intel "
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\if_re"'
SectionEnd