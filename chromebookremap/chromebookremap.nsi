!include WinVer.nsh
!include x64.nsh
!include nsProcess.nsh

!define DRIVERNAME "chromebookremap"
!define VERSION "1.0.2"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$PROGRAMFILES64\${DRIVERNAME}"

PageEx components
  ComponentText "Select the utilities you would like to install.  Click install to start the installation." "" ""
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
  ${nsProcess::KillProcess} "ChromebookRemap.exe" $R4
  File /r "utilities"
  writeUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Keyboard Remap Utility"
SectionIn RO
  SetShellVarContext all
  Exec "$INSTDIR\utilities\ChromebookRemap"
  createShortCut "$SMPROGRAMS\Startup\chromebookremap.lnk" "$INSTDIR\utilities\ChromebookRemap.exe" "" "$INSTDIR\utilities\icon.ico"
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
	${nsProcess::KillProcess} "ChromebookRemap.exe" $R4
  	delete "$SMPROGRAMS\Startup\chromebookremap.lnk"
	delete "$INSTDIR\utilities\ChromebookRemap.exe"
	rmDir /r $INSTDIR\utilities
	delete $INSTDIR\uninstall.exe
	rmDir $INSTDIR
sectionEnd