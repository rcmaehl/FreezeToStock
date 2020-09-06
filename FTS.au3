#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=.\icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Freeze To Stock
#AutoIt3Wrapper_Res_Fileversion=0.1
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <GUIStatusBar.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

Main()

Func Main()

	Local $aStatusSize[2] = [75, -1]

	Local $bSuspended = False

	Local $aProcessExclusions[0] = []
	Local $aServicesExclusions[0]

	Local $hGUI = GUICreate("Freeze To Stock", 320, 240, -1, -1, BitOr($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))

	Local $hFile = GUICtrlCreateMenu("File")
		Local $hExport = GUICtrlCreateMenuItem("Export", $hFile)
		GUICtrlCreateMenuItem("", $hFile)
		Local $hQuit = GUICtrlCreateMenuItem("Quit", $hFile)

	Local $hExclude = GUICtrlCreateMenu("Exclusions")
		Local $hAntiCheat = GUICtrlCreateMenu("Anti-Cheats", $hExclude)
			Local $hBE = GUICtrlCreateMenuItem("BattlEye", $hAntiCheat)
			Local $hEAC = GUICtrlCreateMenuItem("EasyAntiCheat", $hAntiCheat)
		Local $hBroadcasters = GUICtrlCreateMenu("Broadcasters", $hExclude)
			Local $hAMD = GUICtrlCreateMenuItem("AMD ReLive", $hBroadcasters)
			Local $hNvidia = GUICtrlCreateMenuItem("Nvidia ShadowPlay", $hBroadcasters)
			Local $hOBS = GUICtrlCreateMenuItem("OBS", $hBroadcasters)
			Local $hSLOBS = GUICtrlCreateMenuItem("StreamLabs OBS", $hBroadcasters)
			Local $hVMix = GUICtrlCreateMenuItem("VMix", $hBroadcasters)
			Local $hWirecast = GUICtrlCreateMenuItem("Wirecast", $hBroadcasters)
			Local $hWinDVR = GUICtrlCreateMenuItem("Windows DVR", $hBroadcasters)
			Local $hXSplit = GUICtrlCreateMenuItem("XSplit", $hBroadcasters)
		Local $hBrowsers = GUICtrlCreateMenu("Browsers", $hExclude)
			Local $hChrome = GUICtrlCreateMenuItem("Chrome", $hBrowsers)
			Local $hEdge = GUICtrlCreateMenuItem("Edge (New)", $hBrowsers)
			Local $hFirefox = GUICtrlCreateMenuItem("Firefox", $hBrowsers)
			Local $hMSIE = GUICtrlCreateMenuItem("IE", $hBrowsers)
		Local $hHardware = GUICtrlCreateMenu("Hardware", $hExclude)
			Local $hCorsiar = GUICtrlCreateMenuItem("Corsair iCUE", $hHardware)
			Local $hMSMK = GUICtrlCreateMenuItem("Microsft Mouse && Keyboard", $hHardware)
		Local $hLaunchers = GUICtrlCreateMenu("Launchers", $hExclude)
			Local $hEpik = GUICtrlCreateMenuItem("Epic Games", $hLaunchers)
			Local $hParsec = GUICtrlCreateMenuItem("Parsec", $hLaunchers)
			Local $hSteam = GUICtrlCreateMenuItem("Steam", $hLaunchers)
			Local $hHTCVP = GUICtrlCreateMenuItem("VivePort", $hLaunchers)
			Local $hXbox = GUICtrlCreateMenuItem("Xbox", $hLaunchers)
		Local $hSocial = GUICtrlCreateMenu("Social", $hExclude)
			Local $hDiscord = GUICtrlCreateMenuItem("Discord", $hSocial)
		Local $hVirtualR = GUICtrlCreateMenu("Virtual Reality", $hExclude)
			Local $hOculus = GUICtrlCreateMenuItem("Oculus", $hVirtualR)
			Local $hSteamVR = GUICtrlCreateMenuItem("SteamVR (+ HTC)", $hVirtualR)
			Local $hWinMR = GUICtrlCreateMenuItem("Windows Mixed Reality", $hVirtualR)
		GUICtrlCreateMenuItem("", $hExclude)
		Local $hAddCustom = GUICtrlCreateMenuItem("Add Custom", $hExclude)
		Local $hRemCustom = GUICtrlCreateMenuItem("Remove Custom", $hExclude)

	GUICtrlCreateGroup("Options", 5, 5, 310, 190)
		Local $hToggle = GUICtrlCreateButton(" FREEZE SYSTEM", 10, 20, 300, 60)
			GUICtrlSetFont(-1, 20)
			GUICtrlSetImage(-1, ".\Includes\freeze_small.ico", -1, 0)

		Local $hAggressive = GUICtrlCreateCheckbox("Stop Services instead of just Pausing", 12, 85, 300, 20)
			GUICtrlSetTip(-1, "This is recommended for more users with more extreme resource needs")

	$hStatus = _GUICtrlStatusBar_Create($hGUI, $aStatusSize)
	GUISetState(@SW_SHOW, $hGUI)

	While 1

		$hMsg = GUIGetMsg()

		Switch $hMsg

			Case $GUI_EVENT_CLOSE
				_GUICtrlStatusBar_Destroy($hGUI)
				GUIDelete($hGUI)
				Exit

			Case $hExport
				FileDelete(".\export.csv")
				FileWrite(".\export.csv", "[Processes]" & @CRLF)
				FileWrite(".\export.csv", _ArrayToString(ProcessList(), ",") & @CRLF)
				FileWrite(".\export.csv", "[SERVICES]" & @CRLF)
				FileWrite(".\export.csv", _ArrayToString(_ServicesList(), ",") & @CRLF)

			Case $hBE, $hEAC, $hAMD To $hXSplit, $hChrome to $hMSIE, $hCorsiar, $hMSMK, $hEpik to $hXbox, $hDiscord, $hOculus To $hWinMR
				If _IsChecked($hMsg) Then
					GUICtrlSetState($hMsg, $GUI_UNCHECKED)
					Switch $hMsg
						Case $hBE
							_ArrayRemove($aProcessExclusions, "BEService.exe")
							_ArrayRemove($aServicesExclusions, "BEService")
						Case $hEAC
							_ArrayRemove($aProcessExclusions, "EasyAntiCheat.exe")
							_ArrayRemove($aServicesExclusions, "EasyAntiCheat")
						Case $hAMD
							_ArrayRemove($aProcessExclusions, "RadeonSoftware.exe")
							_ArrayRemove($aProcessExclusions, "FacebookClient.exe")
							_ArrayRemove($aProcessExclusions, "GfycatWrapper.exe")
							_ArrayRemove($aProcessExclusions, "QuanminTVWrapper.exe")
							_ArrayRemove($aProcessExclusions, "RestreamAPIWrapper.exe")
							_ArrayRemove($aProcessExclusions, "SinaWeiboWrapper.exe")
							_ArrayRemove($aProcessExclusions, "StreamableAPIWrapper.exe")
							_ArrayRemove($aProcessExclusions, "TwitchClient.exe")
							_ArrayRemove($aProcessExclusions, "TwitterWrapperClient.exe")
							_ArrayRemove($aProcessExclusions, "YoukuWrapper.exe")
							_ArrayRemove($aProcessExclusions, "YoutubeAPIWrapper.exe")
						Case $hNvidia
							_ArrayRemove($aProcessExclusions, "nvcontainer.exe")
							_ArrayRemove($aProcessExclusions, "nvscaphelper.exe")
							_ArrayRemove($aProcessExclusions, "nvsphelper.exe")
							_ArrayRemove($aProcessExclusions, "nvsphelper64.exe")
							_ArrayRemove($aProcessExclusions, "GFExperience.exe")
						Case $hOBS
							_ArrayRemove($aProcessExclusions, "obs.exe")
							_ArrayRemove($aProcessExclusions, "obs32.exe")
							_ArrayRemove($aProcessExclusions, "obs64.exe")
							_ArrayRemove($aProcessExclusions, "obs-ffmpeg-mux.exe")
						Case $hSLOBS
							_ArrayRemove($aProcessExclusions, "Streamlabs OBS.exe")
							_ArrayRemove($aProcessExclusions, "obs32.exe")
							_ArrayRemove($aProcessExclusions, "obs64.exe")
							_ArrayRemove($aProcessExclusions, "obs-ffmpeg-mux.exe")
						Case $hVMix
							_ArrayRemove($aProcessExclusions, "vMixService.exe")
							_ArrayRemove($aProcessExclusions, "vMix.exe")
							_ArrayRemove($aProcessExclusions, "vMix64.exe")
							_ArrayRemove($aProcessExclusions, "vMixDesktopCapture.exe")
							_ArrayRemove($aProcessExclusions, "vMixNDIHelper.exe")
							_ArrayRemove($aProcessExclusions, "ffmpeg.exe")
							_ArrayRemove($aServicesExclusions, "vMixService")
						Case $hWirecast
							_ArrayRemove($aProcessExclusions, "CEFChildProcess.exe")
							_ArrayRemove($aProcessExclusions, "Wirecast.exe")
							_ArrayRemove($aProcessExclusions, "wirecastd.exe")
						Case $hWinDVR
							_ArrayRemove($aServicesExclusions, "BcastDVRUserService")
						Case $hXSplit
							_ArrayRemove($aProcessExclusions, "XGS32.exe")
							_ArrayRemove($aProcessExclusions, "XGS64.exe")
							_ArrayRemove($aProcessExclusions, "XSplit.Core.exe")
							_ArrayRemove($aProcessExclusions, "XSplit.xbcbp.exe")
						Case $hChrome
							_ArrayRemove($aProcessExclusions, "chrome.exe")
						Case $hEdge
							_ArrayRemove($aProcessExclusions, "msedge.exe")
						Case $hFirefox
							_ArrayRemove($aProcessExclusions, "firefox.exe")
						Case $hMSIE
							_ArrayRemove($aProcessExclusions, "iexplore.exe")
						Case $hCorsiar
							_ArrayRemove($aProcessExclusions, "Corsair.Service.CpuIdRemote64.exe")
							_ArrayRemove($aProcessExclusions, "Corsair.Service.DisplayAdapter.exe")
							_ArrayRemove($aProcessExclusions, "Corsair.Service.exe")
							_ArrayRemove($aProcessExclusions, "CorsairGamingAudioCfgService64.exe")
							_ArrayRemove($aServicesExclusions, "CorsairGamingAudioConfig")
							_ArrayRemove($aServicesExclusions, "CorsairLLAService")
							_ArrayRemove($aServicesExclusions, "CorsairService")
						Case $hMSMK
							_ArrayRemove($aProcessExclusions, "MKCHelper.exe")
							_ArrayRemove($aProcessExclusions, "ipoint.exe")
							_ArrayRemove($aProcessExclusions, "itype.exe")
						Case $hEpik
							_ArrayRemove($aProcessExclusions, "EpicGamesLauncher.exe")
						Case $hParsec
							_ArrayRemove($aProcessExclusions, "pservice.exe")
							_ArrayRemove($aProcessExclusions, "parsecd.exe")
							_ArrayRemove($aServicesExclusions, "Parsec")
						Case $hSteam
							_ArrayRemove($aProcessExclusions, "Steam.exe")
							_ArrayRemove($aProcessExclusions, "SteamService.exe")
							_ArrayRemove($aProcessExclusions, "steamwebhelper.exe")
							_ArrayRemove($aServicesExclusions, "Steam Client Service")
						Case $hHTCVP
							_ArrayRemove($aProcessExclusions, "ViveportDesktopService.exe")
							_ArrayRemove($aServicesExclusions, "ViveportDesktopService")
						Case $hXbox
							_ArrayRemove($aServicesExclusions, "XboxGipSvc")
							_ArrayRemove($aServicesExclusions, "XblAuthManager")
							_ArrayRemove($aServicesExclusions, "XblGameSave")
							_ArrayRemove($aServicesExclusions, "XboxNetApiSvc")
						Case $hDiscord
							_ArrayRemove($aProcessExclusions, "Discord.exe")
						Case $hOculus
							_ArrayRemove($aProcessExclusions, "OVRLibraryService.exe")
							_ArrayRemove($aProcessExclusions, "OVRServiceLauncher.exe")
							_ArrayRemove($aProcessExclusions, "oculus-platform-runtime.exe")
							_ArrayRemove($aProcessExclusions, "OculusClient.exe")
							_ArrayRemove($aProcessExclusions, "OculusDash.exe")
							_ArrayRemove($aProcessExclusions, "OVRRedir.exe")
							_ArrayRemove($aProcessExclusions, "OVRServer_x64.exe")
							_ArrayRemove($aServicesExclusions, "OVRLibraryService")
							_ArrayRemove($aServicesExclusions, "OVRService")
						Case $hSteamVR
							_ArrayRemove($aProcessExclusions, "vrcompositor.exe")
							_ArrayRemove($aProcessExclusions, "vrdashboard.exe")
							_ArrayRemove($aProcessExclusions, "vrmonitor.exe")
							_ArrayRemove($aProcessExclusions, "vrserver.exe")
							_ArrayRemove($aProcessExclusions, "vrwebhelper.exe")
						Case $hWinMR
							_ArrayRemove($aProcessExclusions, "Cortanalistenui.exe")
							_ArrayRemove($aProcessExclusions, "DesktopView.exe")
							_ArrayRemove($aProcessExclusions, "EnvironmentsApp.exe")
					EndSwitch
				Else
					GUICtrlSetState($hMsg, $GUI_CHECKED)
					Switch $hMsg
						Case $hBE
							_ArrayAdd($aProcessExclusions, "BEService.exe")
							_ArrayAdd($aServicesExclusions, "BEService")
						Case $hEAC
							_ArrayAdd($aProcessExclusions, "EasyAntiCheat.exe")
							_ArrayAdd($aServicesExclusions, "EasyAntiCheat")
						Case $hAMD
							_ArrayAdd($aProcessExclusions, "RadeonSoftware.exe")
							_ArrayAdd($aProcessExclusions, "FacebookClient.exe")
							_ArrayAdd($aProcessExclusions, "GfycatWrapper.exe")
							_ArrayAdd($aProcessExclusions, "QuanminTVWrapper.exe")
							_ArrayAdd($aProcessExclusions, "RestreamAPIWrapper.exe")
							_ArrayAdd($aProcessExclusions, "SinaWeiboWrapper.exe")
							_ArrayAdd($aProcessExclusions, "StreamableAPIWrapper.exe")
							_ArrayAdd($aProcessExclusions, "TwitchClient.exe")
							_ArrayAdd($aProcessExclusions, "TwitterWrapperClient.exe")
							_ArrayAdd($aProcessExclusions, "YoukuWrapper.exe")
							_ArrayAdd($aProcessExclusions, "YoutubeAPIWrapper.exe")
						Case $hNvidia
							_ArrayAdd($aProcessExclusions, "nvcontainer.exe")
							_ArrayAdd($aProcessExclusions, "nvscaphelper.exe")
							_ArrayAdd($aProcessExclusions, "nvsphelper.exe")
							_ArrayAdd($aProcessExclusions, "nvsphelper64.exe")
							_ArrayAdd($aProcessExclusions, "GFExperience.exe")
						Case $hOBS
							_ArrayAdd($aProcessExclusions, "obs.exe")
							_ArrayAdd($aProcessExclusions, "obs32.exe")
							_ArrayAdd($aProcessExclusions, "obs64.exe")
							_ArrayAdd($aProcessExclusions, "obs-ffmpeg-mux.exe")
						Case $hSLOBS
							_ArrayAdd($aProcessExclusions, "Streamlabs OBS.exe")
							_ArrayAdd($aProcessExclusions, "obs32.exe")
							_ArrayAdd($aProcessExclusions, "obs64.exe")
							_ArrayAdd($aProcessExclusions, "obs-ffmpeg-mux.exe")
						Case $hVMix
							_ArrayAdd($aProcessExclusions, "vMixService.exe")
							_ArrayAdd($aProcessExclusions, "vMix.exe")
							_ArrayAdd($aProcessExclusions, "vMix64.exe")
							_ArrayAdd($aProcessExclusions, "vMixDesktopCapture.exe")
							_ArrayAdd($aProcessExclusions, "vMixNDIHelper.exe")
							_ArrayAdd($aProcessExclusions, "ffmpeg.exe")
							_ArrayAdd($aServicesExclusions, "vMixService")
						Case $hWirecast
							_ArrayAdd($aProcessExclusions, "CEFChildProcess.exe")
							_ArrayAdd($aProcessExclusions, "Wirecast.exe")
							_ArrayAdd($aProcessExclusions, "wirecastd.exe")
						Case $hWinDVR
							_ArrayAdd($aServicesExclusions, "BcastDVRUserService")
						Case $hXSplit
							_ArrayAdd($aProcessExclusions, "XGS32.exe")
							_ArrayAdd($aProcessExclusions, "XGS64.exe")
							_ArrayAdd($aProcessExclusions, "XSplit.Core.exe")
							_ArrayAdd($aProcessExclusions, "XSplit.xbcbp.exe")
						Case $hChrome
							_ArrayAdd($aProcessExclusions, "chrome.exe")
						Case $hEdge
							_ArrayAdd($aProcessExclusions, "msedge.exe")
						Case $hFirefox
							_ArrayAdd($aProcessExclusions, "firefox.exe")
						Case $hMSIE
							_ArrayAdd($aProcessExclusions, "iexplore.exe")
						Case $hCorsiar
							_ArrayAdd($aProcessExclusions, "Corsair.Service.CpuIdRemote64.exe")
							_ArrayAdd($aProcessExclusions, "Corsair.Service.DisplayAdapter.exe")
							_ArrayAdd($aProcessExclusions, "Corsair.Service.exe")
							_ArrayAdd($aProcessExclusions, "CorsairGamingAudioCfgService64.exe")
							_ArrayAdd($aServicesExclusions, "CorsairGamingAudioConfig")
							_ArrayAdd($aServicesExclusions, "CorsairLLAService")
							_ArrayAdd($aServicesExclusions, "CorsairService")
						Case $hMSMK
							_ArrayAdd($aProcessExclusions, "MKCHelper.exe")
							_ArrayAdd($aProcessExclusions, "ipoint.exe")
							_ArrayAdd($aProcessExclusions, "itype.exe")
						Case $hEpik
							_ArrayAdd($aProcessExclusions, "EpicGamesLauncher.exe")
						Case $hParsec
							_ArrayAdd($aProcessExclusions, "pservice.exe")
							_ArrayAdd($aProcessExclusions, "parsecd.exe")
							_ArrayAdd($aServicesExclusions, "Parsec")
						Case $hSteam
							_ArrayAdd($aProcessExclusions, "Steam.exe")
							_ArrayAdd($aProcessExclusions, "SteamService.exe")
							_ArrayAdd($aProcessExclusions, "steamwebhelper.exe")
							_ArrayAdd($aServicesExclusions, "Steam Client Service")
						Case $hHTCVP
							_ArrayAdd($aProcessExclusions, "ViveportDesktopService.exe")
							_ArrayAdd($aServicesExclusions, "ViveportDesktopService")
						Case $hXbox
							_ArrayAdd($aServicesExclusions, "XboxGipSvc")
							_ArrayAdd($aServicesExclusions, "XblAuthManager")
							_ArrayAdd($aServicesExclusions, "XblGameSave")
							_ArrayAdd($aServicesExclusions, "XboxNetApiSvc")
						Case $hDiscord
							_ArrayAdd($aProcessExclusions, "Discord.exe")
						Case $hOculus
							_ArrayAdd($aProcessExclusions, "OVRLibraryService.exe")
							_ArrayAdd($aProcessExclusions, "OVRServiceLauncher.exe")
							_ArrayAdd($aProcessExclusions, "oculus-platform-runtime.exe")
							_ArrayAdd($aProcessExclusions, "OculusClient.exe")
							_ArrayAdd($aProcessExclusions, "OculusDash.exe")
							_ArrayAdd($aProcessExclusions, "OVRRedir.exe")
							_ArrayAdd($aProcessExclusions, "OVRServer_x64.exe")
							_ArrayAdd($aServicesExclusions, "OVRLibraryService")
							_ArrayAdd($aServicesExclusions, "OVRService")
						Case $hSteamVR
							_ArrayAdd($aProcessExclusions, "vrcompositor.exe")
							_ArrayAdd($aProcessExclusions, "vrdashboard.exe")
							_ArrayAdd($aProcessExclusions, "vrmonitor.exe")
							_ArrayAdd($aProcessExclusions, "vrserver.exe")
							_ArrayAdd($aProcessExclusions, "vrwebhelper.exe")
						Case $hWinMR
							_ArrayAdd($aProcessExclusions, "Cortanalistenui.exe")
							_ArrayAdd($aProcessExclusions, "DesktopView.exe")
							_ArrayAdd($aProcessExclusions, "EnvironmentsApp.exe")
					EndSwitch
				EndIf

			Case $hToggle
				GUICtrlSetState($hToggle, $GUI_DISABLE)
				If Not $bSuspended Then
					GUICtrlSetState($hAggressive, $GUI_DISABLE)
					$aServicesSnapshot = _ServicesList()
					_FreezeToStock($aProcessExclusions, $aServicesExclusions, _IsChecked($hAggressive), $hStatus)
					$bSuspended = Not $bSuspended
					GUICtrlSetData($hToggle, " UNFREEZE SYSTEM")
				Else
					_ThawFromStock($aProcessExclusions, $aServicesSnapshot, _IsChecked($hAggressive), $hStatus)
					$bSuspended = Not $bSuspended
					GUICtrlSetState($hAggressive, $GUI_ENABLE)
					GUICtrlSetData($hToggle, " FREEZE SYSTEM")
				EndIf
				GUICtrlSetState($hToggle, $GUI_ENABLE)

			Case Else
				;;;

		EndSwitch

	WEnd

EndFunc

Func _ArrayRemove(ByRef $aArray, $sRemString)
	$sTemp = "," & _ArrayToString($aArray, ",") & ","
	$sTemp = StringReplace($sTemp, "," & $sRemString & ",", ",")
	If StringLeft($sTemp, 1) = "," Then $sTemp = StringTrimLeft($sTemp, 1)
	If StringRight($sTemp, 1) = "," Then $sTemp = StringTrimRight($sTemp, 1)
	If $sTemp = "" Then
		$aArray = StringSplit($sTemp, ",", $STR_NOCOUNT)
		_ArrayDelete($aArray, 0)
	Else
		$aArray = StringSplit($sTemp, ",", $STR_NOCOUNT)
	EndIF
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _FreezeToStock
; Description ...: Suspend unneeded processes, excluding minialistic required system processes
; Syntax ........: _FreezeToStock($aExclusions, $hOutput = False]])
; Parameters ....: $aProcessExclusions  - Array of Processes to Exclude
;                  $aServicesExclusions - Array of Services to Exclude
;                  $bAggressive         - Boolean for Whether or not sc stop should be used
;                  $hOutput             - Handle of the GUI Console
; Return values .: 1                    - An error has occured
; Author ........: rcmaehl (Robert Maehl)
; Modified ......: 09/05/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _FreezeToStock($aProcessExclusions, $aServicesExclusions, $bAggressive, $hOutput)

	_GUICtrlStatusBar_SetText($hOutput, "Freezing...", 0)

	If @Compiled Then
		Local $aSelf[1] = ["FTS.exe"]
	Else
		Local $aSelf[3] = ["AutoIt3.exe", "AutoIt3_x64.exe", "SciTE.exe"]
	EndIf
	Local $aSystemProcesses[32] = ["ApplicationFrameHost.exe", _
									"backgroundTaskHost.exe", _
									"csrss.exe", _ ; Runtime System Service
									"dllhost.exe", _ ; COM Host
									"dwm.exe", _ ; Desktop Window Manager / Compositer
									"explorer.exe", _ ; Windows Explorer
									"fontdrvhost.exe", _
									"lsass.exe", _
									"MsMpEng.exe", _ ; Defender
									"NisSrv.exe", _
									"RuntimeBroker.exe", _
									"SecurityHealthService.exe", _
									"SecurityHealthSystray.exe", _
									"services.exe", _ ; Windows Services
									"SgrmBroker.exe", _
									"ShellExperienceHost.exe", _; UWP Apps
									"sihost.exe", _
									"smartscreen.exe", _
									"smss.exe", _
									"StartMenuExperienceHost.exe", _
									"svchost.exe", _ ; Service Host
									"taskhostw.exe", _ ; Task Host
									"taskmgr.exe", _ ; Task Manager
									"TextInputHost.exe", _
									"unsecapp.exe", _ ; WMI
									"VSSVC.exe", _
									"wininit.exe", _
									"winlogon.exe", _ ; Windows Logon
									"wlanext.exe", _ ; WLAN
									"WmiPrvSE.exe", _ ; WMI
									"WUDFHost.exe", _ ; Windows Usermode Drivers
									"WWAHost.exe"]

	Local $aSystemServices[71] = ["Appinfo", _ ; Application Information
									"AudioEndpointBuilder", _ ; Windows Audio Endpoint Builder
									"Audiosrv", _ ; Windows Audio
									"BFE", _ ; Base Filtering Engine
									"BrokerInfrastructure", _ ; Background Tasks Infrastructure Service
									"camsvc", _ ; Capability Access Manager Service
									"CertPropSvc", _ ; Certificate Propagation
									"CoreMessagingRegistrar", _ ; CoreMessaging
									"CryptSvc", _ ; Cryptographic Services
									"DcomLaunch", _ ; DCOM Server Process Launcher
									"Dhcp", _ ; DHCP Client
									"DispBrokerDesktopSvc", _ ; Display Policy Service
									"Dnscache", _ ; DNS Client
									"DPS", _ ; Diagnostic Policy Service
									"DusmSvc", _ ; Data Usage
									"EventLog", _ ; Windows Event Log
									"EventSystem", _ ; COM+ Event System
									"FontCache", _ ; Windows Font Cache Service
									"gpsvc", _ ; Group Policy Client
									"iphlpsvc", _ ; IP Helper
									"KeyIso", _ ; CNG Key Isolation
									"LanmanServer", _ ; Server
									"LanmanWorkstation", _ ; Workstation
									"lmhosts", _ ; TCP/IP NetBIOS Helper
									"LSM", _ ; Local Session Manager
									"mpssvc", _ ; Windows Defender Firewall
									"NcbService", _ ; Network Connection Broker
									"netprofm", _ ; Network List Service
									"NlaSvc", _ ; Network Location Awareness
									"nsi", _ ; Network Store Interface Service
									"PcaSvc", _ ; Program Compatibility Assistant Service
									"PlugPlay", _ ; Plug and Play
									"Power", _ ; Power
									"ProfSvc", _ ; User Profile Service
									"RmSvc", _ ; Radio Management Service
									"RpcEptMapper", _ ; RPC Endpoint Mapper
									"RpcSs", _ ; Remote Procedure Call
									"SamSs", _ ; Security Accounts Manager
									"Schedule", _ ; Task Scheduler
									"SecurityHealthService", _ ; Windows Security Service
									"SENS", _ ; System Event Notification Service
									"SessionEvc", _ ; Remote Desktop Configuration
									"SgrmBroker", _ ; System Guard Runtime Monitor Broker
									"ShellHWDetection", _ ; Shell Hardware Detection
									"StateRepository", _ ; State Repository Service
									"StorSvc", _ ; Storage Service
									"swprv", _ ; Microsoft Software Shadow Copy Provider
									"SysMain", _ ; SysMain
									"SystemEventsBroker", _ ; System Events Broker
									"TabletInputService", _ ; Touch Keyboard and Handwriting Panel Service
									"TermService", _ ; Remote Desktop Services
									"Themes", _ ; Themes
									"TimeBrokerSvc", _ ; Time Broker
									"TokenBroker", _ ; Web Account Manager
									"TrkWks", _ ; Distributed Link Tracking Client"
									"UmRdpService", _ ; Remote Desktop Services UserMode Port Redirector
									"UserManager", _ ; User Manager
									"UsoSvc", _ ; Update Orchestreator Service
									"VaultSvc", _ ; Credential Manager
									"VSS", _ ; Volume Shadow Copy
									"WarpJITSvc", _ ; WarpJITSvc
									"WbioSrvc", _ ; Windows Biometric Service
									"Wcmsvc", _ ; Windows Connection Manager
									"WdiServiceHost", _ ; Diagnostic Service Host
									"WdiSystemHost", _ ; Diagnostic System Host
									"WdNisSvc", _ ; Windows Defender Antivirus Network Inspection Service
									"WinDefend", _ ; Windows Defender Antivirus Service
									"WinHttpAutoProxySvc", _ ; WinHTTP Web Proxy Auto-Discovery Service
									"Winmgmt", _ ; Windows Management Instrumentation
									"WpnService", _ ; Windows Push Notifications System Service
									"wscsvc"] ; Security Center

	_ArrayConcatenate($aProcessExclusions, $aSelf)
	_ArrayConcatenate($aProcessExclusions, $aSystemProcesses)

	_ArrayConcatenate($aServicesExclusions, $aSystemServices)

	$aProcesses = ProcessList()
	For $iLoop = 0 to $aProcesses[0][0] Step 1
		If _ArraySearch($aProcessExclusions, $aProcesses[$iLoop][0]) = -1 Then
			_GUICtrlStatusBar_SetText($hOutput, "Process: " & $aProcesses[$iLoop][0], 1)
			_ProcessSuspend($aProcesses[$iLoop][1])
		Else
			ConsoleWrite("Skipped " & $aProcesses[$iLoop][0] & @CRLF)
		EndIf
	Next

	$aServices = _ServicesList()
	For $iLoop0 = 0 To 2 Step 1 ; Account for process dependencies
		For $iLoop1 = 0 to $aServices[0][0] Step 1
			If $aServices[$iLoop1][1] = "RUNNING" Then
				If _ArraySearch($aServicesExclusions, $aServices[$iLoop1][0]) = -1 Then
					If $bAggressive Then
						_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServices[$iLoop1][0], 1)
						_ServiceStop($aServices[$iLoop1][0])
					Else
						_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServices[$iLoop1][0], 1)
						_ServiceSuspend($aServices[$iLoop1][0])
					EndIf
					Sleep(100)
				Else
					ConsoleWrite("Skipped " & $aServices[$iLoop1][0] & @CRLF)
				EndIf
			EndIf
		Next
	Next

	_GUICtrlStatusBar_SetText($hOutput, "", 0)
	_GUICtrlStatusBar_SetText($hOutput, "", 1)

EndFunc

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

; #FUNCTION# ====================================================================================================================
; Name ..........: _ServicesList
; Description ...: Get a list of Services and their current state
; Syntax ........: _ServicesList()
; Parameters ....:
; Return values .: An Array containing [0][0] Services Count, [x][0] Service name, [x][1] Service State
; Author ........: rcmaehl (Robert Maehl) based on work by Kyan
; Modified ......: 9/5/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ServicesList() ;
    Local $iExitCode, $st,$a,$aServicesList[1][2],$x
    $iExitCode = Run(@ComSpec & ' /C sc queryex type= service state= all', '', @SW_HIDE, 0x2)
    While 1
        $st &= StdoutRead($iExitCode)
        If @error Then ExitLoop
        Sleep(10)
    WEnd
    $a = StringRegExp($st,'(?m)(?i)(?s)(?:SERVICE_NAME|NOME_SERVI€O)\s*?:\s+?(\w+).+?(?:STATE|ESTADO)\s+?:\s+?\d+?\s+?(\w+)',3)
    For $x = 0 To UBound($a)-1 Step 2
        ReDim $aServicesList[UBound($aServicesList)+1][2]
        $aServicesList[UBound($aServicesList)-1][0]=$a[$x]
        $aServicesList[UBound($aServicesList)-1][1]=$a[$x+1]
    Next
    $aServicesList[0][0] = UBound($aServicesList)-1
    Return $aServicesList
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _ThawFromStock
; Description ...: Unsuspend all processes
; Syntax ........: _FreezeToStock(Byref $aExclusions, $hOutput = False]])
; Parameters ....: $aProcessExclusions  - Array of Processes to Exclude
;                  $aServicesSnapshot   - Array of Previously Running Services
;                  $bAggressive         - Boolean for Whether or not sc stop was used
;                  $hOutput             - [optional] Handle of the GUI Console. Default is False, for none.
; Return values .: 1                    - An error has occured
; Author ........: rcmaehl (Robert Maehl)
; Modified ......: 09/5/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ThawFromStock($aProcessExclusions, $aServicesSnapshot, $bAggressive = False, $hOutput = False)

	_GUICtrlStatusBar_SetText($hOutput, "Thawing...", 0)

	$aProcesses = ProcessList()
	For $iLoop = 0 to $aProcesses[0][0] Step 1
		If _ArraySearch($aProcessExclusions, $aProcesses[$iLoop][0]) = -1 Then
			_GUICtrlStatusBar_SetText($hOutput, "Process: " & $aProcesses[$iLoop][0], 1)
			_ProcessResume($aProcesses[$iLoop][1])
		Else
			;;;
		EndIf
	Next

	For $iLoop0 = 0 To 2 Step 1 ; Account for process dependencies
		For $iLoop1 = 0 to $aServicesSnapshot[0][0] Step 1
			If $aServicesSnapshot[$iLoop1][1] = "RUNNING" Then
				If $bAggressive Then
					_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServicesSnapshot[$iLoop1][0], 1)
					_ServiceStart($aServicesSnapshot[$iLoop1][0])
				Else
					_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServicesSnapshot[$iLoop1][0], 1)
					_ServiceResume($aServicesSnapshot[$iLoop1][0])
				EndIf
				Sleep(100)
			Else
				;;;
			EndIf
		Next
	Next

	_GUICtrlStatusBar_SetText($hOutput, "", 0)
	_GUICtrlStatusBar_SetText($hOutput, "", 1)

EndFunc

Func _ProcessSuspend($iPID)
	$ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPID)
	$i_success = DllCall("ntdll.dll","int","NtSuspendProcess","int",$ai_Handle[0])
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $ai_Handle)
	If IsArray($i_success) Then
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc

Func _ProcessResume($iPID)
	$ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPID)
	$i_success = DllCall("ntdll.dll","int","NtResumeProcess","int",$ai_Handle[0])
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $ai_Handle)
	If IsArray($i_success) Then
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc

Func _ServiceResume($sService)
	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
	Run("sc \\localhost continue " & $sService, "", @SW_HIDE)
EndFunc

Func _ServiceStart($sService)
	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
	Run("sc \\localhost start " & $sService, "", @SW_HIDE)
EndFunc

Func _ServiceStop($sService)
	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
	Run("sc \\localhost stop " & $sService, "", @SW_HIDE)
EndFunc

Func _ServiceSuspend($sService)
	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
	Run("sc \\localhost pause " & $sService, "", @SW_HIDE)
EndFunc