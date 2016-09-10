!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "croskblight"
!define VERSION "1.0"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$PROGRAMFILES64\${DRIVERNAME}"

Var dpinst
Var vcdist

PageEx components
  ComponentText "Select which keyboard backlight model you have.  Click install to start the installation." "" ""
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
  ${nsProcess::KillProcess} "croskblighthotkey.exe" $R4
  File /r "drivers"
  File /r "utilities"
  StrCpy $dpinst "$INSTDIR\drivers\dpinst.exe"
  StrCpy $vcdist "$INSTDIR\utilities\vc_redist.x64.exe"
  writeUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Keyboard Backlight Driver for Chrome EC"
SectionIn RO
  ExecWait '"$dpinst" /sw /path "$INSTDIR\drivers\chromeec"'
SectionEnd

Section "Keyboard Backlight Hotkey"
SectionIn RO
  ExecWait '"$vcdist" /install /passive /norestart'
  SetShellVarContext all
  createDirectory "$SMPROGRAMS\${DRIVERNAME}"
  createShortCut "$SMPROGRAMS\${DRIVERNAME}\Uninstall croskblight.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\utilities\icon.ico"
  Exec "$INSTDIR\utilities\croskblighthotkey.exe"
  createShortCut "$SMPROGRAMS\Startup\croskblight hotkey.lnk" "$INSTDIR\utilities\croskblighthotkey.exe" "" "$INSTDIR\utilities\icon.ico"
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
	${nsProcess::KillProcess} "croskblighthotkey.exe" $R4
	ExecWait '"$INSTDIR\drivers\dpinst.exe" /q /u "$INSTDIR\drivers\chromeec\croskblight.inf" /d'
	rmDir /r "$SMPROGRAMS\${DRIVERNAME}"
  delete "$SMPROGRAMS\Startup\croskblight hotkey.lnk"
	delete $INSTDIR\drivers\*
	rmDir /r $INSTDIR\drivers
	delete "$INSTDIR\utilities\croskblighthotkey.exe"
	rmDir /r $INSTDIR\utilities
	delete $INSTDIR\uninstall.exe
	rmDir $INSTDIR
sectionEnd