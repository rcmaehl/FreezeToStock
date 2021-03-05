#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=.\icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Compiled 03/05/2021 @ ~17:30 EST
#AutoIt3Wrapper_Res_Description=Freeze To Stock
#AutoIt3Wrapper_Res_Fileversion=1.3.0
#AutoIt3Wrapper_Res_ProductVersion=1.3.0
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Included in AutoIt
#include <File.au3>
#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <WinAPIProc.au3>
#include <GUIStatusBar.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <UpDownConstants.au3>
#include <WindowsConstants.au3>

; Manual Includes
#include ".\Includes\Services.au3"

Opt("WinTitleMatchMode", 4)

Main()

Func Main()

	Local $sVersion = "1.3.0"

	Local $aStatusSize[2] = [75, -1]

	Local $bSuspended = False
	Local $hActive, $hLastActive
	Local $hFreezeTimer, $bThawing = False, $hThawTimer

	Local $aAfter, $aBefore, $aFinal[0]

	Local $aServicesSnapshot
	Local $aProcessExclusions[0], $aServicesExclusions[0]

	Local $hState = _GetStateFile()

	Switch $hState

		Case False
			;;;

		Case True
			If IsString($hState) Then ContinueCase
			If MsgBox($MB_YESNO+$MB_ICONWARNING+$MB_TOPMOST, "State File could not be read", "A previous unthawed session was detected but its details could not be read. " & _
				"This may cause issues with freezing or thawing. Please delete the '.frozen' file or run the application as an administrator to resolve. " & _
				"Would you like to continue?") = $IDYES Then ;;;
			Else
				Exit 1
			EndIf

		Case Else
			Switch MsgBox($MB_YESNOCANCEL+$MB_ICONQUESTION+$MB_TOPMOST, "Previous Session Exists", "A previous unthawed session from " & $hState & " was found." & @CRLF & _
				@CRLF & _
				"Would you like to thaw it?" & @CRLF & _
				"The session will be deleted to prevent conflicts." & @CRLF & _
				"To exit immediately and take other action, choose Cancel.")

				Case $IDYES
					If FileReadLine(".frozen", 2) = "True" Then
						$aServicesSnapshot = _ReadStateFile()
						If $aServicesSnapshot = False Then
							MsgBox($MB_OK+$MB_ICONERROR+$MB_TOPMOST, "State File could not be recovered", "Unable to recover previous system state. A computer reboot is highly recommended.")
							Exit 1
						Else
							_ThawFromStock("", True, $aServicesSnapshot, False, "")
							_ThawFromStock("", True, $aServicesSnapshot, True, "")
						EndIf
					Else
						_ThawFromStock("", False, "", False, "")
					EndIf

				Case $IDNO
					_RemoveStateFile()

				Case $IDCancel
					Exit 1


			EndSwitch

	EndSwitch

	Local $hGUI = GUICreate("FreezeToStock", 320, 240, -1, -1, BitOr($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))

	Local $hFile = GUICtrlCreateMenu("File")
;		Local $hDebug  = GUICtrlCreateMenu("Recovery", $hFile)
;			Local $hThawAll = GUICtrlCreateMenuItem("Thaw All", $hDebug)
;			Local $hThawProc = GUICtrlCreateMenuItem("Thaw Processes", $hDebug)
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
			Local $hOpera = GUICtrlCreateMenuItem("Opera", $hBrowsers)
		Local $hHardware = GUICtrlCreateMenu("Hardware", $hExclude)
			Local $hCorsiar = GUICtrlCreateMenuItem("Corsair iCUE", $hHardware)
			Local $hLogi = GUICtrlCreateMenuItem("Logitech", $hHardware)
			Local $hMSMK = GUICtrlCreateMenuItem("Microsft Mouse && Keyboard", $hHardware)
		Local $hLaunchers = GUICtrlCreateMenu("Launchers", $hExclude)
			Local $hEpik = GUICtrlCreateMenuItem("Epic Games", $hLaunchers)
			Local $hParsec = GUICtrlCreateMenuItem("Parsec", $hLaunchers)
			Local $hSteam = GUICtrlCreateMenuItem("Steam", $hLaunchers)
			Local $hHTCVP = GUICtrlCreateMenuItem("VivePort", $hLaunchers)
			Local $hXbox = GUICtrlCreateMenuItem("Xbox", $hLaunchers)
		Local $hSocial = GUICtrlCreateMenu("Social", $hExclude)
			Local $hDiscord = GUICtrlCreateMenuItem("Discord", $hSocial)
			Local $hTelegram = GUICtrlCreateMenuItem("Telegram", $hSocial)
		Local $hTools = GUICtrlCreateMenu("Tools", $hExclude)
			Local $hMSPT = GUICtrlCreateMenuItem("Microsoft Powertoys", $hTools)
			Local $hNBFC = GUICtrlCreateMenuItem("NoteBook FanControl", $hTools)
			Local $hTStop = GUICtrlCreateMenuItem("ThrottleStop", $hTools)
		Local $hVirtualR = GUICtrlCreateMenu("Virtual Reality", $hExclude)
			Local $hOculus = GUICtrlCreateMenuItem("Oculus", $hVirtualR)
			Local $hSteamVR = GUICtrlCreateMenuItem("SteamVR (+ HTC)", $hVirtualR)
			Local $hWinMR = GUICtrlCreateMenuItem("Windows Mixed Reality", $hVirtualR)
		GUICtrlCreateMenuItem("", $hExclude)
		Local $hCustom = GUICtrlCreateMenu("Custom", $hExclude)
			Local $hAddCustom = GUICtrlCreateMenuItem("Add Custom", $hCustom)
			Local $hNewCustom = GUICtrlCreateMenuItem("Create Custom", $hCustom)
				GUICtrlSetState(-1, $GUI_DISABLE)
			Local $hRemCustom = GUICtrlCreateMenuItem("Remove Custom", $hCustom)

	Local $hHelp = GUICtrlCreateMenu("Help")
	Local $hGithub = GUICtrlCreateMenuItem("Github", $hHelp)
	Local $hDisWeb = GUICtrlCreateMenuItem("Discord", $hHelp)
	GUICtrlCreateMenuItem("", $hHelp)
	Local $hDonate = GUICtrlCreateMenuItem("Donate", $hHelp)
	GUICtrlCreateMenuItem("", $hHelp)
	Local $hUpdate = GUICtrlCreateMenuItem("Update", $hHelp)

	GUICtrlCreateGroup("Options", 5, 5, 310, 190)
		Local $hToggle = GUICtrlCreateButton(" FREEZE SYSTEM", 10, 20, 300, 60)
			GUICtrlSetFont(-1, 20)
			GUICtrlSetImage(-1, ".\Includes\freeze_small.ico", -1, 0)

		Local $hServices = GUICtrlCreateCheckbox("Freeze Services as well as Processes", 12, 85, 296, 15)
			GUICtrlSetTip(-1, "This Pauses known unneeded System Services")
			GUICtrlCreateLabel(Chrw(9625), 12, 100, 15, 15, $SS_CENTER)
			GUICtrlSetState(-1, $GUI_DISABLE)
			Local $hAggressive = GUICtrlCreateCheckbox("Stop Services instead of just Pausing", 27, 100, 286, 15)
				GUICtrlSetState(-1, $GUI_DISABLE)
				GUICtrlSetTip(-1, _
					"This will give stronger results for lower powered devices," & _
					@CRLF & "Services will automatically be restarted for you.")

		Local $hThawTop = GUICtrlCreateCheckbox("Dynamically Thaw Active Window (Coming Soon)", 12, 120, 296, 15)
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlCreateLabel(Chrw(9625), 12, 135, 15, 15, $SS_CENTER)
			GUICtrlSetState(-1, $GUI_DISABLE)
			Local $hReFreeze = GUICtrlCreateCheckbox("Refreeze Inactive Thawed Windows", 27, 135, 286, 15)
				GUICtrlSetState(-1, $GUI_DISABLE)

		Local $hThawCycle = GUICtrlCreateCheckbox("Periodically Thaw Frozen Processes", 12, 155, 296, 15)
			GUICtrlSetTip(-1, "This allows frozen processes to process any pending data")
			GUICtrlCreateLabel(Chrw(9625), 12, 170, 15, 15, $SS_CENTER)
			GUICtrlCreateLabel("Every", 27, 171, 30, 15)
			Local $hCycle = GUICtrlCreateInput("60", 57, 170, 40, 15, $ES_READONLY)
				GUICtrlCreateUpdown(-1,$UDS_ARROWKEYS+$UDS_SETBUDDYINT)
				GUICtrlSetLimit(-1, 360, 1)
			GUICtrlCreateLabel("Minute(s) for", 101, 171, 60, 15)
			Local $hPeriod = GUICtrlCreateInput("5", 165, 170, 40, 15, $ES_READONLY)
				GUICtrlCreateUpdown(-1,$UDS_ARROWKEYS+$UDS_SETBUDDYINT)
				GUICtrlSetLimit(-1, 60, 5)
			GUICtrlCreateLabel("Seconds", 206, 171, 45, 15)
			For $iLoop = 1 To 8 Step 1
				GUICtrlSetState($hThawCycle + $iLoop, $GUI_DISABLE)
				GUICtrlSetTip($hThawCycle + $iLoop, _
					"How often to thaw processes and for how long, " & _
					@CRLF & "This setting can be modified during Freeze.")
			Next

	$hStatus = _GUICtrlStatusBar_Create($hGUI, $aStatusSize)
	GUISetState(@SW_SHOW, $hGUI)

	While 1

		$hMsg = GUIGetMsg()

		If $bSuspended And _IsChecked($hThawTop) Then
			$hActive = WinActive("[ACTIVE]")
			If Not $hActive = $hLastActive Then
				_ProcessResume(WinGetProcess($hActive))
				$hLastActive = $hActive
			EndIf
		EndIf

		If $bSuspended And _IsChecked($hThawCycle) Then
			If $bThawing Then
				If TimerDiff($hThawTimer) >= GUICtrlRead($hPeriod) * 1000 Then
					_FreezeToStock($aProcessExclusions, _IsChecked($hServices), $aServicesExclusions, _IsChecked($hAggressive), $hStatus)
					$bThawing = False
					$hFreezeTimer = TimerInit()
				EndIf
			ElseIf TimerDiff($hFreezeTimer) >= GUICtrlRead($hCycle) * 60000 Then
				_ThawFromStock($aProcessExclusions, _IsChecked($hServices), $aServicesSnapshot, _IsChecked($hAggressive), $hStatus)
				$bThawing = True
				$hThawTimer = TimerInit()
			EndIf
		EndIf

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

			Case $hBE, $hEAC, $hAMD To $hXSplit, $hChrome to $hOpera, $hCorsiar to $hMSMK, $hEpik to $hXbox, $hDiscord to $hTelegram, $hMSPT to $hTStop, $hOculus To $hWinMR
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
						Case $hOpera
							_ArrayRemove($aProcessExclusions, "opera.exe")
						Case $hCorsiar
							_ArrayRemove($aProcessExclusions, "Corsair.Service.CpuIdRemote64.exe")
							_ArrayRemove($aProcessExclusions, "Corsair.Service.DisplayAdapter.exe")
							_ArrayRemove($aProcessExclusions, "Corsair.Service.exe")
							_ArrayRemove($aProcessExclusions, "CorsairGamingAudioCfgService64.exe")
							_ArrayRemove($aServicesExclusions, "CorsairGamingAudioConfig")
							_ArrayRemove($aServicesExclusions, "CorsairLLAService")
							_ArrayRemove($aServicesExclusions, "CorsairService")
						Case $hLogi
							_ArrayRemove($aProcessExclusions, "KHALMNPR.exe")
							_ArrayRemove($aProcessExclusions, "SetPoint.exe")
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
						Case $hTelegram
							_ArrayRemove($aProcessExclusions, "Telegram.exe")
						Case $hMSPT
							_ArrayRemove($aProcessExclusions, "PowerToys.exe")
							_ArrayRemove($aProcessExclusions, "PowerToysSettings.exe")
							_ArrayRemove($aProcessExclusions, "ColorPicker.exe")
							_ArrayRemove($aProcessExclusions, "ColorPickerUI.exe")
							_ArrayRemove($aProcessExclusions, "FancyZonesEditor.exe")
							_ArrayRemove($aProcessExclusions, "ImageResizer.exe")
							_ArrayRemove($aProcessExclusions, "PowerLauncher.exe")
						Case $hNBFC
							_ArrayRemove($aProcessExclusions, "NoteBookFanControl.exe")
							_ArrayRemove($aServicesExclusions, "NbfcService")
						Case $hTStop
							_ArrayRemove($aProcessExclusions, "ThrottleStop.exe")
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
						Case $hOpera
							_ArrayAdd($aProcessExclusions, "opera.exe")
						Case $hCorsiar
							_ArrayAdd($aProcessExclusions, "Corsair.Service.CpuIdRemote64.exe")
							_ArrayAdd($aProcessExclusions, "Corsair.Service.DisplayAdapter.exe")
							_ArrayAdd($aProcessExclusions, "Corsair.Service.exe")
							_ArrayAdd($aProcessExclusions, "CorsairGamingAudioCfgService64.exe")
							_ArrayAdd($aServicesExclusions, "CorsairGamingAudioConfig")
							_ArrayAdd($aServicesExclusions, "CorsairLLAService")
							_ArrayAdd($aServicesExclusions, "CorsairService")
						Case $hLogi
							_ArrayAdd($aProcessExclusions, "KHALMNPR.exe")
							_ArrayAdd($aProcessExclusions, "SetPoint.exe")
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
						Case $hTelegram
							_ArrayAdd($aProcessExclusions, "Telegram.exe")
						Case $hMSPT
							_ArrayAdd($aProcessExclusions, "PowerToys.exe")
							_ArrayAdd($aProcessExclusions, "PowerToysSettings.exe")
							_ArrayAdd($aProcessExclusions, "ColorPicker.exe")
							_ArrayAdd($aProcessExclusions, "ColorPickerUI.exe")
							_ArrayAdd($aProcessExclusions, "FancyZonesEditor.exe")
							_ArrayAdd($aProcessExclusions, "ImageResizer.exe")
							_ArrayAdd($aProcessExclusions, "PowerLauncher.exe")
						Case $hNBFC
							_ArrayAdd($aProcessExclusions, "NoteBookFanControl.exe")
							_ArrayAdd($aServicesExclusions, "NbfcService")
						Case $hTSTOP
							_ArrayAdd($aProcessExclusions, "ThrottleStop.exe")
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

			Case $hAddCustom
				$hFile = FileOpenDialog("Select Definition File to Load", @WorkingDir, "Exclusions Definition (*.def)", $FD_FILEMUSTEXIST, "exclusion.def", $hGUI)
				If @error Then
					;;;
				Else
					_LoadCustom($hFile, $aProcessExclusions, $aServicesExclusions)
				EndIf

#cs
			Case $hNewCustom
				$aFinal = StringSplit("", ",", $STR_NOCOUNT)
				_ArrayDelete($aFinal, 0)
				If MsgBox($MB_OKCANCEL+$MB_ICONINFORMATION+$MB_TOPMOST, "Creating new Exclusion", "Please close the application you want to exclude, wait a few seconds, then click OK") = $IDOK Then
					$aBefore = ProcessList()
					_ArrayColDelete($aBefore, 1)
					If MsgBox($MB_OKCANCEL+$MB_ICONINFORMATION+$MB_TOPMOST, "Creating new Exclusion", "Snapshot created. Please launch the application you want to exclude, wait a few seconds, then click OK") = $IDOK Then
						$aAfter = ProcessList()
						_ArrayColDelete($aAfter, 1)
						For $iLoop = 1 To $aBefore[0][0] Step 1
							_ArrayRemove($aAfter, $aBefore[$iLoop][0])
							ProgressSet(Round($iLoop/$aBefore[0][0]))
						Next
						ProgressOff()
						_ArrayDisplay($aAfter)
					EndIf
				EndIf
#ce


			Case $hRemCustom
				$hFile = FileOpenDialog("Select Definition File to Unload", @WorkingDir, "Exclusions Definition (*.def)", $FD_FILEMUSTEXIST, "exclusion.def", $hGUI)
				If @error Then
					;;;
				Else
					_RemoveCustom($hFile, $aProcessExclusions, $aServicesExclusions)
				EndIf


			Case $hToggle
				GUICtrlSetState($hToggle, $GUI_DISABLE)
				If Not $bSuspended Then
					If Not _IsChecked($hThawCycle) Then GUICtrlSetState($hExclude, $GUI_DISABLE)
					GUICtrlSetState($hServices, $GUI_DISABLE)
					GUICtrlSetState($hAggressive, $GUI_DISABLE)
					GUICtrlSetState($hThawCycle, $GUI_DISABLE)
					$aServicesSnapshot = _ServicesList()
					_FreezeToStock($aProcessExclusions, _IsChecked($hServices), $aServicesExclusions, _IsChecked($hAggressive), $hStatus)
					$bSuspended = Not $bSuspended
					GUICtrlSetData($hToggle, " UNFREEZE SYSTEM")
					$hFreezeTimer = TimerInit()
				Else
					_ThawFromStock($aProcessExclusions, _IsChecked($hServices), $aServicesSnapshot, _IsChecked($hAggressive), $hStatus)
					$bSuspended = Not $bSuspended
					GUICtrlSetState($hServices, $GUI_ENABLE)
					If _IsChecked($hServices) Then GUICtrlSetState($hAggressive, $GUI_ENABLE)
					GUICtrlSetState($hThawCycle, $GUI_ENABLE)
					If _IsChecked($hThawCycle) Then GUICtrlSetState($hThawCycle + 1, $GUI_ENABLE)
					GUICtrlSetData($hToggle, " FREEZE SYSTEM")
					GUICtrlSetState($hExclude, $GUI_ENABLE)
				EndIf
				GUICtrlSetState($hToggle, $GUI_ENABLE)

			Case $hServices
				If _IsChecked($hServices) Then
					GUICtrlSetState($hAggressive - 1, $GUI_ENABLE)
					GUICtrlSetState($hAggressive, $GUI_ENABLE)
				Else
					GUICtrlSetState($hAggressive - 1, $GUI_DISABLE)
					GUICtrlSetState($hAggressive, $GUI_DISABLE)
				EndIf

			Case $hThawTop
				If _IsChecked($hThawTop) Then
					GUICtrlSetState($hReFreeze - 1, $GUI_ENABLE)
					GUICtrlSetState($hReFreeze, $GUI_ENABLE)
				Else
					GUICtrlSetState($hReFreeze - 1, $GUI_DISABLE)
					GUICtrlSetState($hReFreeze, $GUI_DISABLE)
				EndIf

			Case $hThawCycle
				If _IsChecked($hThawCycle) Then
					For $iLoop = 1 To 8 Step 1
						GUICtrlSetState($hThawCycle + $iLoop, $GUI_ENABLE)
					Next
				Else
					For $iLoop = 1 To 8 Step 1
						GUICtrlSetState($hThawCycle + $iLoop, $GUI_DISABLE)
					Next
				EndIf
			Case $hGithub
				ShellExecute("https://github.com/rcmaehl/FreezeToStock")

			Case $hDisWeb
				ShellExecute("https://discord.gg/uBnBcBx")

			Case $hDonate
				ShellExecute("https://www.paypal.me/rhsky")

			Case $hUpdate
				If $bSuspended Then
					MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Please thaw the system to check for updates", 10)
				Else
					Switch _GetLatestRelease($sVersion)
						Case -1
							MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Test Build?", "You're running a newer build than publically available!", 10)
						Case 0
							Switch @error
								Case 0
									MsgBox($MB_OK+$MB_ICONINFORMATION+$MB_TOPMOST, "Up to Date", "You're running the latest build!", 10)
								Case 1
									MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Unable to load release data.", 10)
								Case 2
									MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Invalid Data Received!", 10)
								Case 3
									Switch @extended
										Case 0
											MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Invalid Release Tags Received!", 10)
										Case 1
											MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, "Unable to Check for Updates", "Invalid Release Types Received!", 10)
									EndSwitch
							EndSwitch
						Case 1
							If MsgBox($MB_YESNO+$MB_ICONINFORMATION+$MB_TOPMOST, "Update Available", "An Update is Availabe, would you like to download it?", 10) = $IDYES Then ShellExecute("https://github.com/rcmaehl/FreezeToStock/releases")
					EndSwitch
				EndIf


			Case Else
				;;;

		EndSwitch

	WEnd

EndFunc

Func _ArrayRemove(ByRef $aArray, $sRemString)
	$sTemp = "," & _ArrayToString($aArray, ",") & ","
	$sTemp = StringReplace($sTemp, "," & $sRemString & ",", ",")
	$sTemp = StringReplace($sTemp, ",,", ",")
	If StringLeft($sTemp, 1) = "," Then $sTemp = StringTrimLeft($sTemp, 1)
	If StringRight($sTemp, 1) = "," Then $sTemp = StringTrimRight($sTemp, 1)
	If $sTemp = "" Or $sTemp = "," Then
		$aArray = StringSplit($sTemp, ",", $STR_NOCOUNT)
		_ArrayDelete($aArray, 0)
	Else
		$aArray = StringSplit($sTemp, ",", $STR_NOCOUNT)
	EndIf
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _FreezeToStock
; Description ...: Suspend unneeded processes, excluding minialistic required system processes
; Syntax ........: _FreezeToStock($aExclusions, $hOutput = False]])
; Parameters ....: $aProcessExclusions  - Array of Processes to Exclude
;                  $bIncludeServices    - Boolean for whether or not services should be included
;                  $aServicesExclusions - Array of Services to Exclude
;                  $bAggressive         - Boolean for whether or not sc stop should be used
;                  $hOutput             - Handle of the GUI Console
; Return values .: 1                    - An error has occured
; Author ........: rcmaehl (Robert Maehl)
; Modified ......: 03/05/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _FreezeToStock($aProcessExclusions, $bIncludeServices, $aServicesExclusions, $bAggressive, $hOutput)

	_GUICtrlStatusBar_SetText($hOutput, "Freezing...", 0)

	If @Compiled Then
		Local $aSelf[1] = ["FTS.exe"]
	Else
		Local $aSelf[3] = ["AutoIt3.exe", "AutoIt3_x64.exe", "SciTE.exe"]
	EndIf

	Local $aCantBeSuspended[6] = ["Memory Compression", _
									"Registry", _
									"Secure System", _
									"System", _
									"System Idle Process", _
									"System Interrupts"]

	Local $aSystemProcesses[33] = ["ApplicationFrameHost.exe", _
									"backgroundTaskHost.exe", _
									"csrss.exe", _ ; Runtime System Service
									"ctfmon.exe", _ ; Alternative Input
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
									"camsvc", _ ; Capability Access Manager Service...Stoppable?
									"CertPropSvc", _ ; Certificate Propagation....Stoppable?
									"CoreMessagingRegistrar", _ ; CoreMessaging
									"CryptSvc", _ ; Cryptographic Services
									"DcomLaunch", _ ; DCOM Server Process Launcher
									"Dhcp", _ ; DHCP Client
									"DispBrokerDesktopSvc", _ ; Display Policy Service...Stoppable?
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
									"RmSvc", _ ; Radio Management Service...Stoppable?
									"RpcEptMapper", _ ; RPC Endpoint Mapper
									"RpcSs", _ ; Remote Procedure Call
									"SamSs", _ ; Security Accounts Manager
									"Schedule", _ ; Task Scheduler
									"SecurityHealthService", _ ; Windows Security Service
									"SENS", _ ; System Event Notification Service
									"SessionEvc", _ ; Remote Desktop Configuration...Stoppable?
									"SgrmBroker", _ ; System Guard Runtime Monitor Broker
									"ShellHWDetection", _ ; Shell Hardware Detection
									"StateRepository", _ ; State Repository Service
									"StorSvc", _ ; Storage Service...Stoppable?
									"swprv", _ ; Microsoft Software Shadow Copy Provider....Stoppable?
									"SysMain", _ ; SysMain
									"SystemEventsBroker", _ ; System Events Broker
									"TabletInputService", _ ; Touch Keyboard and Handwriting Panel Service
									"TermService", _ ; Remote Desktop Services...Stoppable?
									"Themes", _ ; Themes
									"TimeBrokerSvc", _ ; Time Broker
									"TokenBroker", _ ; Web Account Manager
									"TrkWks", _ ; Distributed Link Tracking Client
									"UmRdpService", _ ; Remote Desktop Services UserMode Port Redirector...Stoppable?
									"UserManager", _ ; User Manager
									"UsoSvc", _ ; Update Orchestreator Service
									"VaultSvc", _ ; Credential Manager
									"VSS", _ ; Volume Shadow Copy
									"WarpJITSvc", _ ; WarpJITSvc...Stoppable
									"WbioSrvc", _ ; Windows Biometric Service...Stoppable
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
	_ArrayConcatenate($aProcessExclusions, $aCantBeSuspended)
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

	FileWrite(".frozen", @HOUR & ":" & @MIN & " - " & @MDAY & "/" & @MON & "/" & @YEAR & @CRLF)

	If $bIncludeServices Then
		Local $hSCM = _SCMStartup()
		$aServices = _ServicesList()
		For $iLoop0 = 0 To 2 Step 1 ; Account for process dependencies
			For $iLoop1 = 0 to $aServices[0][0] Step 1
				If $aServices[$iLoop1][1] = "RUNNING" Then
					If _ArraySearch($aServicesExclusions, $aServices[$iLoop1][0]) = -1 Then
						If $bAggressive Then
							_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServices[$iLoop1][0], 1)
							_ServiceStop($hSCM, $aServices[$iLoop1][0])
						Else
							_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServices[$iLoop1][0], 1)
							_ServicePause($hSCM, $aServices[$iLoop1][0])
						EndIf
						Sleep(10)
					Else
						ConsoleWrite("Skipped " & $aServices[$iLoop1][0] & @CRLF)
					EndIf
				EndIf
			Next
		Next
		_SCMShutdown($hSCM)
		FileWrite(".frozen", "True" & @CRLF)
		FileWrite(".frozen", _ArrayToString($aServices, ","))
	EndIf

	_GUICtrlStatusBar_SetText($hOutput, "", 0)
	_GUICtrlStatusBar_SetText($hOutput, "", 1)

EndFunc

Func _GetLatestRelease($sCurrent)

	Local $dAPIBin
	Local $sAPIJSON

	$dAPIBin = InetRead("https://api.github.com/repos/rcmaehl/FreezeToStock/releases")
	If @error Then Return SetError(1, 0, 0)
	$sAPIJSON = BinaryToString($dAPIBin)
	If @error Then Return SetError(2, 0, 0)

	Local $aReleases = _StringBetween($sAPIJSON, '"tag_name":"', '",')
	If @error Then Return SetError(3, 0, 0)
	Local $aRelTypes = _StringBetween($sAPIJSON, '"prerelease":', ',')
	If @error Then Return SetError(3, 1, 0)
	Local $aCombined[UBound($aReleases)][2]

	For $iLoop = 0 To UBound($aReleases) - 1 Step 1
		$aCombined[$iLoop][0] = $aReleases[$iLoop]
		$aCombined[$iLoop][1] = $aRelTypes[$iLoop]
	Next

	Return _VersionCompare($aCombined[0][0], $sCurrent)

EndFunc

Func _GetStateFile()
	If FileExists(".frozen") Then
		Local $hStateFile = FileOpen(".frozen", $FO_READ)
		If $hStateFile = -1 Then
			Return True
		EndIf
		Return FileReadLine($hStateFile, 1)
	Else
		Return False
	EndIf
EndFunc


Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _LoadCustom($sFile, ByRef $aProcessExclusions, ByRef $aServicesExclusions)

	Local $hFile
	Local $aLine

	If FileExists($sFile) Then
		$hFile = FileOpen($sFile)
		If @error Then SetError(2,0,0)
	Else
		SetError(2,1,0)
	EndIf

	Local $iLines = _FileCountLines($sFile)

	For $iLine = 1 to $iLines Step 1
		$sLine = FileReadLine($hFile, $iLine)
		If @error = -1 Then ExitLoop
		$aLine = StringSplit($sLine, ",", $STR_NOCOUNT)
		If UBound($aLine) <> 2 Then ContinueLoop
		Switch $aLine[0]

			Case "Process"
				_ArrayAdd($aProcessExclusions, $aLine[1])

			Case "Service"
				_ArrayAdd($aServicesExclusions, $aLine[1])

			Case Else
				ContinueLoop

		EndSwitch
	Next

	FileClose($hFile)

EndFunc

Func _ProcessSuspend($iPID)
	$hProcess = _WinAPI_OpenProcess($PROCESS_SUSPEND_RESUME, False, $iPID)
	$iSuccess = DllCall("ntdll.dll", "int", "NtSuspendProcess", "int", $hProcess)
	_WinAPI_CloseHandle($hProcess)
	If IsArray($iSuccess) Then
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc

Func _ProcessResume($iPID)
	$hProcess = _WinAPI_OpenProcess($PROCESS_SUSPEND_RESUME, False, $iPID)
	$iSuccess = DllCall("ntdll.dll", "int", "NtResumeProcess", "int", $hProcess)
	_WinAPI_CloseHandle($hProcess)
	If IsArray($iSuccess) Then
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc

Func _ReadStateFile()
	Local $aFullArray
	_FileWriteToLine(".frozen", 1, ",", True) ; Replace Date
	_FileWriteToLine(".frozen", 2, ",", True) ; Replace "True"
	_FileReadToArray(".frozen", $aFullArray, 0, ",") ; Convert to 2D array
	If @error Then Return False
	_ArrayDelete($aFullArray, 0) ; Remove Empty Element
	_ArrayDelete($aFullArray, 0) ; Remove Empty Element
	Return $aFullArray
EndFunc

Func _RemoveStateFile()
	FileDelete(".frozen")
EndFunc


Func _RemoveCustom($sFile, ByRef $aProcessExclusions, ByRef $aServicesExclusions)

	Local $hFile
	Local $aLine

	If FileExists($sFile) Then
		$hFile = FileOpen($sFile)
		If @error Then SetError(2,0,0)
	Else
		SetError(2,1,0)
	EndIf

	Local $iLines = _FileCountLines($sFile)

	For $iLine = 1 to $iLines Step 1
		$sLine = FileReadLine($hFile, $iLine)
		If @error = -1 Then ExitLoop
		$aLine = StringSplit($sLine, ",", $STR_NOCOUNT)
		If UBound($aLine) <> 2 Then ContinueLoop
		Switch $aLine[0]

			Case "Process"
				_ArrayRemove($aProcessExclusions, $aLine[1])

			Case "Service"
				_ArrayRemove($aServicesExclusions, $aLine[1])

			Case Else
				ContinueLoop

		EndSwitch
	Next

	FileClose($hFile)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _ServicesList
; Description ...: Get a list of Services and their current state
; Syntax ........: _ServicesList()
; Parameters ....:
; Return values .: An Array containing [0][0] Services Count, [x][0] Service name, [x][1] Service State
; Author ........: rcmaehl (Robert Maehl) based on work by Kyan
; Modified ......: 09/05/2020
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
    $a = StringRegExp($st,'(?m)(?i)(?s)(?:SERVICE_NAME|NOME_SERVIO)\s*?:\s+?(\w+).+?(?:STATE|ESTADO)\s+?:\s+?\d+?\s+?(\w+)',3)
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
;                  $bIncludeServices    - Boolean for whether or not services should be included
;                  $aServicesSnapshot   - Array of Previously Running Services
;                  $bAggressive         - Boolean for Whether or not sc stop was used
;                  $hOutput             - [optional] Handle of the GUI Console. Default is False, for none.
; Return values .: 1                    - An error has occured
; Author ........: rcmaehl (Robert Maehl)
; Modified ......: 03/05/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ThawFromStock($aProcessExclusions, $bIncludeServices, $aServicesSnapshot, $bAggressive, $hOutput)

	_GUICtrlStatusBar_SetText($hOutput, "Thawing...", 0)

	If $bIncludeServices Then
		Local $hSCM = _SCMStartup()
		For $iLoop0 = 0 To 2 Step 1 ; Account for process dependencies
			For $iLoop1 = 0 to $aServicesSnapshot[0][0] Step 1
				If $aServicesSnapshot[$iLoop1][1] = "RUNNING" Then
					If $bAggressive Then
						_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServicesSnapshot[$iLoop1][0], 1)
						_ServiceStart($hSCM, $aServicesSnapshot[$iLoop1][0])
					Else
						_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServicesSnapshot[$iLoop1][0], 1)
						_ServiceContinue($hSCM, $aServicesSnapshot[$iLoop1][0])
					EndIf
					Sleep(10)
				Else
					;;;
				EndIf
			Next
		Next
		_SCMShutdown($hSCM)
	EndIf

	$aProcesses = ProcessList()
	For $iLoop = 0 to $aProcesses[0][0] Step 1
		If _ArraySearch($aProcessExclusions, $aProcesses[$iLoop][0]) = -1 Then
			_GUICtrlStatusBar_SetText($hOutput, "Process: " & $aProcesses[$iLoop][0], 1)
			_ProcessResume($aProcesses[$iLoop][1])
		Else
			;;;
		EndIf
	Next

	_RemoveStateFile()

	_GUICtrlStatusBar_SetText($hOutput, "", 0)
	_GUICtrlStatusBar_SetText($hOutput, "", 1)

EndFunc

Func WriteStateFile()
EndFunc