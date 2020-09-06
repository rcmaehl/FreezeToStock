#include-once


Global Const $SERVICE_START = 0x0010
Global Const $SERVICE_STOP = 0x0020
Global Const $SERVICE_PAUSE_CONTINUE = 0x0040

Global Const $SERVICE_CONTROL_STOP = 0x00000001
Global Const $SERVICE_CONTROL_PAUSE = 0x00000002
Global Const $SERVICE_CONTROL_CONTINUE = 0x00000003

Func CloseServiceHandle($hSCObject)
	Local $avCSH = DllCall( "advapi32.dll", "int", "CloseServiceHandle", _
		"hwnd", $hSCObject )
	Return $avCSH[0]
EndFunc ;==> CloseServiceHandle

Func ControlService($hService, $iControl)
	Local $avCS = DllCall("advapi32.dll", "int", "ControlService", _
		"hwnd", $hService, _
		"dword", $iControl, _
		"str", "")
	Return $avCS[0]
EndFunc ;==> ControlService

Func GetLastError()
	Local $aiE = DllCall("kernel32.dll", "dword", "GetLastError")
	Return $aiE[0]
EndFunc ;==> GetLastError

Func OpenService($hSC, $sServiceName, $iAccess)
	Local $avOS = DllCall("advapi32.dll", "hwnd", "OpenService", _
		"hwnd", $hSC, _
		"str", $sServiceName, _
		"dword", $iAccess)
	Return $avOS[0]
EndFunc ;==> OpenService

; #FUNCTION# ====================================================================================================================
; Name ..........: _SCMStartup
; Description ...: Start a connection to SC Manager
; Syntax ........: _SCMStartup([$sHostname = ""])
; Parameters ....: $sHostname           - [optional] Hostname to control, Default is "", for localhost
; Return values .: Handle to SC Manager
; Author ........: rcmaehl (Robert Maehl) based on work by engine
; Modified.......: 09/06/2020
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-openscmanagera#return-value
; Example .......: No
; ===============================================================================================================================
Func _SCMStartup($sHostname = "")
	Local Const $SC_MANAGER_CONNECT = 0x0001

	Local $avOSCM = DllCall("advapi32.dll", "hwnd", "OpenSCManager", _
		"str", $sHostname, _
		"str", "ServicesActive", _
		"dword", $SC_MANAGER_CONNECT)
	Return $avOSCM[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _SCMShutdown
; Description ...: End a connection to SC Manager
; Syntax ........: _ServiceShutdown($hSCHandle)
; Parameters ....: $hSCHandle           - Handle to an existing open SC Manager
; Return values .: None
; Author ........: rcmaehl (Robert Maehl) based on work by engine
; Modified.......: 09/06/2020
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-closeservicehandle
; Example .......: No
; ===============================================================================================================================
Func _SCMShutdown($hSCHandle)
	Local $avCSH = DllCall("advapi32.dll", "int", "CloseServiceHandle", "hwnd", $hSCHandle)
	Return $avCSH[0]
EndFunc

; #FUNCTION# =======================================================================================================================================================
; Name...........: _ServiceContinue
; Description ...: Continues a paused service.
; Syntax.........: _ServiceContinue($hSCManager, $sServiceName)
; Parameters ....: $hSCHandle - Handle to an open SC Manager
;                  $sServiceName - Name of the service.
; Return values .: Success - 1
;                  Failure - 0
;                            Sets @error
; Author ........: rcmaehl (Robert Maehl) based on work by engine
; Modified.......: 09/06/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ==================================================================================================================================================================
Func _ServiceContinue($hSCHandle, $sService)
	Local $hService, $iCSR, $iCSRE

	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'

	$hService = OpenService($hSCHandle, $sService, $SERVICE_PAUSE_CONTINUE)
	$iCSR = ControlService($hService, $SERVICE_CONTROL_CONTINUE)
	If $iCSR = 0 Then $iCSRE = GetLastError()
	CloseServiceHandle($hService)
	Return SetError($iCSRE, 0, $iCSR)
EndFunc

; #FUNCTION# =======================================================================================================================================================
; Name...........: _ServicePause
; Description ...: Pauses a service.
; Syntax.........: _ServicePause($hSCManager, $sServiceName)
; Parameters ....: $hSCHandle - Handle to an open SC Manager
;                  $sServiceName - Name of the service.
; Return values .: Success - 1
;                  Failure - 0
;                            Sets @error
; Author ........: rcmaehl (Robert Maehl) based on work by engine
; Modified.......: 09/06/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ==================================================================================================================================================================
Func _ServicePause($hSCHandle, $sService)
	Local $hService, $iCSP, $iCSPE

	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'

	$hService = OpenService($hSCHandle, $sService, $SERVICE_PAUSE_CONTINUE)
	$iCSP = ControlService($hService, $SERVICE_CONTROL_PAUSE)
	If $iCSP = 0 Then $iCSPE = GetLastError()
	CloseServiceHandle($hService)
	Return SetError($iCSPE, 0, $iCSP)
EndFunc

; #FUNCTION# =======================================================================================================================================================
; Name...........: _ServiceStart
; Description ...: Starts a service.
; Syntax.........: _ServiceStart($hSCManager, $sServiceName)
; Parameters ....: $hSCHandle - Handle to an open SC Manager
;                  $sServiceName - Name of the service.
; Return values .: Success - 1
;                  Failure - 0
;                            Sets @error
; Author ........: rcmaehl (Robert Maehl) based on work by engine
; Modified.......: 09/06/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ==================================================================================================================================================================
Func _ServiceStart($hSCHandle, $sService)
	Local $hService, $avSS, $iSS

	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'

	$hService = OpenService($hSCHandle, $sService, $SERVICE_START)
	$avSS = DllCall("advapi32.dll", "int", "StartService", _
		"hwnd", $hService, _
		"dword", 0, _
		"ptr", 0)
	If $avSS[0] = 0 Then $iSS = GetLastError()
	CloseServiceHandle($hService)
	Return SetError($iSS, 0, $avSS[0])
EndFunc ;==> _Service_Start

; #FUNCTION# =======================================================================================================================================================
; Name...........: _ServiceStop
; Description ...: Stops a service.
; Syntax.........: _ServiceStop($hSCManager, $sServiceName)
; Parameters ....: $hSCHandle - Handle to an open SC Manager
;                  $sServiceName - Name of the service.
; Return values .: Success - 1
;                  Failure - 0
;                            Sets @error
; Author ........: rcmaehl (Robert Maehl) based on work by engine
; Modified.......: 09/06/2020
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ==================================================================================================================================================================
Func _ServiceStop($hSCHandle, $sService)
	Local $hService, $iCSS, $iCSSE

	If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'

	$hService = OpenService($hSCHandle, $sService, $SERVICE_STOP)
	$iCSS = ControlService($hService, $SERVICE_CONTROL_STOP)
	If $iCSS = 0 Then $iCSSE = GetLastError()
	CloseServiceHandle($hService)
	Return SetError($iCSSE, 0, $iCSS)
EndFunc ;==> _Service_Stop