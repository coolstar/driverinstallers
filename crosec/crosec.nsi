!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "crosec"
!define VERSION "2.0"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$PROGRAMFILES64\${DRIVERNAME}"

Var dpinst

PageEx components
  ComponentText "Select which components to install.  Click install to start the installation." "" ""
PageExEnd

Page instfiles

function .onInit
    ${If} ${RunningX64}
      ${DisableX64FSRedirection}
    	# do nothing
    ${Else}
        MessageBox MB_ICONSTOP "32-bit (x86) Windows is not supported. Please reinstall 64-bit Windows."
        Abort
    ${EndIf}
functionEnd

Section
  SetOutPath $INSTDIR
  File /r "drivers"
  ${nsProcess::KillProcess} "crosecservice.exe" $R4
  File /r "utils\*.*"
  StrCpy $dpinst "$INSTDIR\drivers\dpinst.exe"
SectionEnd

Section "Coreboot Table"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\coreboot"'
SectionEnd

Section "Chrome EC Combo"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\crosec"'
SectionEnd

Section "Wilco (Dell 7410/5300/5400) EC"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\wilco"'
SectionEnd

Section "Keyboard"
  ExecWait '"$dpinst" /sw /f /path "$INSTDIR\drivers\keyboard"'
  writeUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\crosecservice" \
                 "DisplayName" "Chrome EC Service"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\crosecservice" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\crosecservice" \
                 "DisplayIcon" "$\"$INSTDIR\icon.ico$\""
  SetShellVarContext all
  Exec "$INSTDIR\crosecservice.exe"
  createShortCut "$SMPROGRAMS\Startup\crosecservice.lnk" "$INSTDIR\crosecservice.exe" "" "$INSTDIR\icon.ico"
SectionEnd

#Section "Default Keyboard Presets"
#  ${DisableX64FSRedirection}
#  CopyFiles "$INSTDIR\drivers\croskbsettings-croskb3.bin" "C:\Windows\system32\drivers\croskbsettings.bin"
#  ExecWait "$INSTDIR\utils\croskbreload.exe"
#SectionEnd

Section
  RMDir /r $INSTDIR\drivers
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
  ${nsProcess::KillProcess} "crosecservice.exe" $R4
  delete "$SMPROGRAMS\Startup\chromebookremap.lnk"
  rmDir /r $INSTDIR
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\crosecservice"
sectionEnd