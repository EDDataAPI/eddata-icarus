!define APP_NAME "ICARUS Terminal"
!define COMP_NAME "ICARUS"
!define VERSION "${PRODUCT_VERSION}"
!define COPYRIGHT "ICARUS"
!define DESCRIPTION "Application"
!define INSTALLER_NAME "../../dist/ICARUS Setup.exe"
!define MAIN_APP_EXE "ICARUS Terminal.exe"
!define SERVICE_EXE "ICARUS Service.exe"
!define INSTALL_TYPE "SetShellVarContext current"
!define REG_ROOT "HKCU"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_EXE}"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

######################################################################

VIProductVersion  "${VERSION}"
VIAddVersionKey "ProductName"  "${APP_NAME}"
VIAddVersionKey "CompanyName"  "${COMP_NAME}"
VIAddVersionKey "LegalCopyright"  "${COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${VERSION}"

######################################################################

SetCompressor ZLIB
Name "${APP_NAME}"
Caption "${APP_NAME}"
OutFile "${INSTALLER_NAME}"
BrandingText "${APP_NAME}"
XPStyle on
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
InstallDir "$PROGRAMFILES\ICARUS Terminal"

######################################################################

!include "MUI.nsh"
!include "webview2.nsh"

!addplugindir "./"

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

!define MUI_WELCOMEFINISHPAGE_BITMAP "panel.bmp"  # 164x314px
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "header.bmp" # 150x57px

!insertmacro MUI_PAGE_WELCOME

!ifdef LICENSE_TXT
!insertmacro MUI_PAGE_LICENSE "${LICENSE_TXT}"
!endif

!ifdef REG_START_MENU
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "ICARUS Terminal"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${REG_START_MENU}"
!insertmacro MUI_PAGE_STARTMENU Application $SM_Folder
!endif

!insertmacro MUI_PAGE_INSTFILES

# Pass the flag "--install" to let the app know it is being run by the installer
# after install/update as an easy way to trigger any 'first run' actions.
# There are better ways to do this, but it's much easier to do it this way.
!define MUI_FINISHPAGE_RUN "$INSTDIR\${MAIN_APP_EXE}"
!define MUI_FINISHPAGE_RUN_PARAMETERS "--install"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

######################################################################

# Check if application is running before install
Function .onInit
	# Check if ICARUS Terminal is running
	FindWindow $0 "" "${APP_NAME}"
	StrCmp $0 0 checkService
		MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
			"${APP_NAME} is currently running. Please close it before continuing." \
			/SD IDCANCEL IDOK checkService
		Abort

	checkService:
	# Check if ICARUS Service is running
	nsExec::ExecToStack 'tasklist /FI "IMAGENAME eq ${SERVICE_EXE}" /NH'
	Pop $0
	Pop $1
	StrCmp $0 0 0 done
	# Check if service name is in output (if not found, tasklist returns "INFO: No tasks...")
	StrCmp $1 "INFO: No tasks are running which match the specified criteria." done
		MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
			"${SERVICE_EXE} is currently running. Please close ${APP_NAME} before continuing." \
			/SD IDCANCEL IDOK done
		Abort

	done:
FunctionEnd

######################################################################

Section -MainProgram
${INSTALL_TYPE}
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
File "..\..\build\bin\ICARUS Service.exe"
File "..\..\build\bin\ICARUS Terminal.exe"
File "..\..\build\bin\WebView2Loader.dll"
File "..\assets\icon.ico"
Call installWebView2
SectionEnd

######################################################################

Section -Icons_Reg
SetOutPath "$INSTDIR"
WriteUninstaller "$INSTDIR\uninstall.exe"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
CreateDirectory "$SMPROGRAMS\$SM_Folder"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!insertmacro MUI_STARTMENU_WRITE_END
!endif

!ifndef REG_START_MENU
CreateDirectory "$SMPROGRAMS\ICARUS Terminal"
CreateShortCut "$SMPROGRAMS\ICARUS Terminal\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\ICARUS Terminal\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!endif

WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayName" "${APP_NAME}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "UninstallString" "$INSTDIR\uninstall.exe"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayIcon" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayVersion" "${VERSION}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "Publisher" "${COMP_NAME}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "InstallLocation" "$INSTDIR"
WriteRegDWORD ${REG_ROOT} "${UNINSTALL_PATH}" "NoModify" 1
WriteRegDWORD ${REG_ROOT} "${UNINSTALL_PATH}" "NoRepair" 1

!ifdef WEB_SITE
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "URLInfoAbout" "${WEB_SITE}"
!endif
SectionEnd

######################################################################

Section Uninstall
${INSTALL_TYPE}

# Terminate running processes
DetailPrint "Checking for running processes..."
nsExec::ExecToLog 'taskkill /F /IM "${MAIN_APP_EXE}" /T'
nsExec::ExecToLog 'taskkill /F /IM "${SERVICE_EXE}" /T'
Sleep 1000

# Delete files
Delete "$INSTDIR\ICARUS Service.exe"
Delete "$INSTDIR\ICARUS Terminal.exe"
Delete "$INSTDIR\WebView2Loader.dll"
Delete "$INSTDIR\icon.ico"
Delete "$INSTDIR\uninstall.exe"
!ifdef WEB_SITE
Delete "$INSTDIR\${APP_NAME} website.url"
!endif

RmDir "$INSTDIR"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_GETFOLDER "Application" $SM_Folder
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\$SM_Folder"
!endif

!ifndef REG_START_MENU
Delete "$SMPROGRAMS\ICARUS Terminal\${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\ICARUS Terminal\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\ICARUS Terminal"
!endif

DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
SectionEnd

######################################################################

