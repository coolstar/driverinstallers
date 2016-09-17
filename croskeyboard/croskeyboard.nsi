!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "croskeyboard"
!define VERSION "3.5.2"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$PROGRAMFILES64\${DRIVERNAME}"

Var dpinst
Var vcdist

PageEx components
  ComponentText "Select which keyboard model you have.  Click install to start the installation." "" ""
PageExEnd

Page instfiles

function .onInit
    ${If} ${RunningX64}
    	# do nothing
    ${Else}
        MessageBox MB_ICONSTOP  "32-bit (x86) Windows is not supported. Please reinstall 64-bit Windows."
        Abort
    ${EndIf}
functionEnd

Section
  SetOutPath $INSTDIR
  ${nsProcess::KillProcess} "crostrackpadscroll.exe" $R4
  ${nsProcess::KillProcess} "CrosTrackpad Settings.exe" $R4
  File /r "drivers"
  File /r "utilities"
  StrCpy $dpinst "$INSTDIR\drivers\dpinst.exe"
  StrCpy $vcdist "$INSTDIR\utilities\vc_redist.x64.exe"
  writeUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Keyboard Driver for Haswell/Broadwell"
SectionIn RO
  ExecWait '"$dpinst" /sw /path "$INSTDIR\drivers\hswbdw"'
SectionEnd

Section "Keyboard Utilities"
SectionIn RO
  ExecWait '"$vcdist" /install /passive /norestart'
  SetShellVarContext all
  createDirectory "$SMPROGRAMS\${DRIVERNAME}"
  createShortCut "$SMPROGRAMS\${DRIVERNAME}\croskeyboard settings.lnk" "$INSTDIR\utilities\CrosKeyboard Settings.exe" "" "$INSTDIR\utilities\icon.ico"
  createShortCut "$SMPROGRAMS\${DRIVERNAME}\Uninstall croskeyboard.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\utilities\icon.ico"
  Exec "$INSTDIR\utilities\croskeyboardstartup.exe"
  createShortCut "$SMPROGRAMS\Startup\croskeyboard settings loader.lnk" "$INSTDIR\utilities\croskeyboardstartup.exe" "" "$INSTDIR\utilities\icon.ico"
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
	${nsProcess::KillProcess} "croskeyboardstartup.exe" $R4
	${nsProcess::KillProcess} "CrosKeyboard Settings.exe" $R4
	ExecWait '"$INSTDIR\drivers\dpinst.exe" /q /u "$INSTDIR\drivers\hswbdw\croskeyboard3.inf" /d'
	rmDir /r "$SMPROGRAMS\${DRIVERNAME}"
  delete "$SMPROGRAMS\Startup\croskeyboard settings loader.lnk"
	delete $INSTDIR\drivers\*
	rmDir /r $INSTDIR\drivers
	delete "$INSTDIR\utilities\CrosKeyboard Settings.exe"
	delete "$INSTDIR\utilities\croskeyboardsettingslib.dll"
	delete "$INSTDIR\utilities\croskeyboardstartup.exe"
	rmDir /r $INSTDIR\utilities
	delete $INSTDIR\uninstall.exe
	rmDir $INSTDIR
sectionEnd