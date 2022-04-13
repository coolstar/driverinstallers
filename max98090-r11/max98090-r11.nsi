!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "max98090-r11"
!define VERSION "1.0.0"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$TEMP\${DRIVERNAME}"

Var dpinst

PageEx components
  ComponentText "Select which audio codec model you have.  Click install to start the installation." "" ""
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

Section "Maxim 98090 + TS3A227E (R11) Audio Codec"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\max98090-r11"'
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\ts3a227e"'
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\intelsst-bsw"'
SectionEnd