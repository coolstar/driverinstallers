!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "crostrackpad"
!define VERSION "3.0"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.3.0-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$PROGRAMFILES64\${DRIVERNAME}"

Var dpinst
Var vcdist

PageEx components
  ComponentText "Select which Trackpad model you have.  Click install to start the installation." "" ""
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

Section /o "Trackpad Driver for Cypress"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\drivers\cypress"'
SectionEnd

Section /o "Trackpad Driver for Elan"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\drivers\elan"'
SectionEnd

Section /o "Trackpad Driver for Atmel"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\drivers\atmel"'
SectionEnd

Section /o "Trackpad Driver for Synaptics"
  ExecWait '"$dpinst" /sw /path "$INSTDIR\drivers\synaptics"'
SectionEnd

Section "Trackpad Utilities"
SectionIn RO
  ExecWait '"$vcdist" /install /passive /norestart'
  SetShellVarContext all
  createDirectory "$SMPROGRAMS\${DRIVERNAME}"
  createShortCut "$SMPROGRAMS\${DRIVERNAME}\crostrackpad scrolling helper.lnk" "$INSTDIR\utilities\crostrackpadscroll.exe" "" "$INSTDIR\utilities\icon.ico"
  createShortCut "$SMPROGRAMS\${DRIVERNAME}\crostrackpad settings.lnk" "$INSTDIR\utilities\CrosTrackpad Settings.exe" "" "$INSTDIR\utilities\icon.ico"
  createShortCut "$SMPROGRAMS\${DRIVERNAME}\Uninstall crostrackpad.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\utilities\icon.ico"
  Exec "$INSTDIR\utilities\crostrackpadscroll.exe"
  createShortCut "$SMPROGRAMS\Startup\crostrackpad scrolling helper.lnk" "$INSTDIR\utilities\crostrackpadscroll.exe" "" "$INSTDIR\utilities\icon.ico"
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
	${nsProcess::KillProcess} "crostrackpadscroll.exe" $R4
	${nsProcess::KillProcess} "CrosTrackpad Settings.exe" $R4
	ExecWait '"$INSTDIR\drivers\dpinst.exe" /q /u "$INSTDIR\drivers\cypress\crostrackpad.inf" /d'
	ExecWait '"$INSTDIR\drivers\dpinst.exe" /q /u "$INSTDIR\drivers\synaptics\crostrackpad3-synaptics.inf" /d'
	ExecWait '"$INSTDIR\drivers\dpinst.exe" /q /u "$INSTDIR\drivers\elan\crostrackpad3elan.inf" /d'
	rmDir /r "$SMPROGRAMS\${DRIVERNAME}"
  delete "$SMPROGRAMS\Startup\crostrackpad scrolling helper.lnk"
	delete $INSTDIR\drivers\*
	rmDir /r $INSTDIR\drivers
	delete "$INSTDIR\utilities\CrosTrackpad Settings.exe"
	delete "$INSTDIR\utilities\crostrackpadsettingslib.dll"
	delete "$INSTDIR\utilities\crostrackpadscroll.exe"
	rmDir /r $INSTDIR\utilities
	delete $INSTDIR\uninstall.exe
	rmDir $INSTDIR
sectionEnd