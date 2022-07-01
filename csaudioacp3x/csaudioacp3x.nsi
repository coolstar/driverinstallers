!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "csaudioacp3x"
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

Section "CoolStar ACP Audio"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\csaudioacp3x"'
SectionEnd

Section "Realtek ALC5682 Codec"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\alc5682"'
SectionEnd

Section "Maxim 98357a Amplifier"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\max98357a"'
SectionEnd

Section "CoolStar Audio AutoSwitch"
  SetOutPath $INSTDIR
  ExecWait 'net.exe STOP "csaudioswitcher"'
  File /r "utils"
  writeUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\csaudioswitcher" \
                 "DisplayName" "CoolStar Audio AutoSwitch"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\csaudioswitcher" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\csaudioswitcher" \
                 "DisplayIcon" "$\"$INSTDIR\utils\icon.ico$\""
  ExecWait 'sc create csaudioswitcher error="severe" displayname="csaudioswitcher" type="own" start="delayed-auto" binpath="$INSTDIR\utils\csaudioendpointswitcher.exe"'
  Exec 'net.exe START "csaudioswitcher"'
SectionEnd

###############
#             #
# Uninstaller #
#             #
###############

function un.onInit
  SetShellVarContext all
  MessageBox MB_OKCANCEL "Are you sure you want to uninstall ${DRIVERNAME}?" IDOK next
    Abort
  next:
functionEnd
 
section "uninstall"
  ExecWait 'net.exe STOP "csaudioswitcher"'
  ${nsProcess::KillProcess} "csaudioendpointswitcher.exe" $R4
  ExecWait 'sc delete csaudioswitcher'
  delete "$INSTDIR\utils\csaudioendpointswitcher.exe"
  rmDir /r $INSTDIR\utils
  delete $INSTDIR\uninstall.exe
  rmDir $INSTDIR

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\csaudioswitcher"
sectionEnd