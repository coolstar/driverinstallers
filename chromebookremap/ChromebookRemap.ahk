;
; Chromebook Keyboard remaps (for use with standard, signed PS/2 Keyboard driver)
;
; tested on an Acer C720 & C740 running Windows 10.
;
; Mappings taken from croskeyboard3's Chromebook Standard layout
;
; (C) 2017, CoolStar. All Rights Reserved
; Original Script by BitingChaos
;
; 2017-08-04
;
; Left Ctrl + Backspace = Delete
;
; Left Ctrl + F1 = Browser Back
; Left Ctrl + F2 = Browser Forward
; Left Ctrl + F3 = Browser Refresh
;
; Left Ctrl + F4 = Full Screen
; Left Ctrl + F5 = Task View
;
; Left Ctrl + F6 = Brightness Down
; Left Ctrl + F7 = Brightness Up
;
; Left Ctrl + F8 = Mute
; Left Ctrl + F9 = Volume Down
; Left Ctrl + F10 = Volume Up
;
;

#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%

; set tooltip
Menu, Tray, Tip, Chromebook Keyboard

; sources:
; https://gist.github.com/qwerty12/4b3f41eb61724cd9e8f2bb5cc15c33c2
; https://www.reddit.com/r/AutoHotkey/comments/5u2lvi/brightness_script/

; ----------

; --- brightness ---

class BrightnessSetter {
	; qwerty12 - 15/01/17
	static _WM_POWERBROADCAST := 0x218, _osdHwnd := 0

	__New() {
		if (BrightnessSetter.IsOnAc(AC))
			this._AC := AC
		if ((this.pwrAcNotifyHandle := DllCall("RegisterPowerSettingNotification", "Ptr", A_ScriptHwnd, "Ptr", BrightnessSetter._GUID_ACDC_POWER_SOURCE(), "UInt", DEVICE_NOTIFY_WINDOW_HANDLE := 0x00000000, "Ptr"))) ; Sadly the callback passed to *PowerSettingRegister*Notification runs on a new threadl
			OnMessage(this._WM_POWERBROADCAST, (this.pwrBroadcastFunc := ObjBindMethod(this, "_On_WM_POWERBROADCAST")))
	}

	__Delete() {
		if (this.pwrAcNotifyHandle) {
			OnMessage(BrightnessSetter._WM_POWERBROADCAST, this.pwrBroadcastFunc, 0)
			DllCall("UnregisterPowerSettingNotification", "Ptr", this.pwrAcNotifyHandle)
			this.pwrBroadcastFunc := ""
			this.pwrAcNotifyHandle := 0
		}
	}

	SetBrightness(increment, jump := False, showOSD := True, autoDcOrAc := -1, forceDifferentScheme := 0)
	{
		static PowerGetActiveScheme := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerGetActiveScheme", "Ptr")
		static PowerSetActiveScheme := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerSetActiveScheme", "Ptr")
		static PowerWriteACValueIndex := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerWriteACValueIndex", "Ptr")
		static PowerWriteDCValueIndex := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerWriteDCValueIndex", "Ptr")
		static PowerApplySettingChanges := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerApplySettingChanges", "Ptr")

		if (increment == 0 && !jump) {
			if (showOSD)
				BrightnessSetter._ShowBrightnessOSD()
			return
		}

		if (!forceDifferentScheme ? DllCall(PowerGetActiveScheme, "Ptr", 0, "Ptr*", currSchemeGuid, "UInt") == 0 : DllCall("powrprof\PowerDuplicateScheme", "Ptr", 0, "Ptr", forceDifferentScheme, "Ptr*", currSchemeGuid, "UInt") == 0) {
			if (autoDcOrAc == -1) {
				if (this != BrightnessSetter) {
					AC := this._AC
				} else {
					if (!BrightnessSetter.IsOnAc(AC))
						return
				}
			} else {
				AC := !!autoDcOrAc
			}
			
			currBrightness := 0
			if (jump || BrightnessSetter._GetCurrentBrightness(currSchemeGuid, AC, currBrightness)) {
				maxBrightness := BrightnessSetter.GetMaxBrightness()
				minBrightness := BrightnessSetter.GetMinBrightness()
				
				if (jump || !((currBrightness == maxBrightness && increment > 0) || (currBrightness == minBrightness && increment < minBrightness))) {
					if (currBrightness + increment > maxBrightness)
						increment := maxBrightness
					else if (currBrightness + increment < minBrightness)
						increment := minBrightness
					else
						increment += currBrightness

					if (DllCall(AC ? PowerWriteACValueIndex : PowerWriteDCValueIndex, "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt", increment, "UInt") == 0) {
						; PowerApplySettingChanges is undocumented and exists only in Windows 8+. Since both the Power control panel and the brightness slider use this, we'll do the same, but fallback to PowerSetActiveScheme if on Windows 7 or something
						if (!PowerApplySettingChanges || DllCall(PowerApplySettingChanges, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt") != 0)
							DllCall(PowerSetActiveScheme, "Ptr", 0, "Ptr", currSchemeGuid, "UInt")
					}
				}

				if (showOSD)
					BrightnessSetter._ShowBrightnessOSD()
			}
			DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
		}
	}

	IsOnAc(ByRef acStatus)
	{
		VarSetCapacity(SystemPowerStatus, 12)
		if (DllCall("GetSystemPowerStatus", "Ptr", &SystemPowerStatus)) {
			acStatus := NumGet(SystemPowerStatus, 0, "UChar") == 1
			return True
		}
		return False
	}
	
	GetDefaultBrightnessIncrement()
	{
		static ret := 10
		DllCall("powrprof\PowerReadValueIncrement", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt")
		return ret
	}

	GetMinBrightness()
	{
		static ret := -1
		if (ret == -1)
			if (DllCall("powrprof\PowerReadValueMin", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt"))
				ret := 0
		return ret
	}

	GetMaxBrightness()
	{
		static ret := -1
		if (ret == -1)
			if (DllCall("powrprof\PowerReadValueMax", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt"))
				ret := 100
		return ret
	}

	_GetCurrentBrightness(schemeGuid, AC, ByRef currBrightness)
	{
		static PowerReadACValueIndex := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerReadACValueIndex", "Ptr")
		static PowerReadDCValueIndex := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "powrprof.dll", "Ptr"), "AStr", "PowerReadDCValueIndex", "Ptr")
		return DllCall(AC ? PowerReadACValueIndex : PowerReadDCValueIndex, "Ptr", 0, "Ptr", schemeGuid, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", currBrightness, "UInt") == 0
	}
	
	_ShowBrightnessOSD()
	{
		static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
		static WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
		if A_OSVersion in WIN_VISTA,WIN_7
			return
		BrightnessSetter._RealiseOSDWindowIfNeeded()
		; Thanks to YashMaster @ https://github.com/YashMaster/Tweaky/blob/master/Tweaky/BrightnessHandler.h for realising this could be done:
		if (BrightnessSetter._osdHwnd)
			DllCall(PostMessagePtr, "Ptr", BrightnessSetter._osdHwnd, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
	}

	_RealiseOSDWindowIfNeeded()
	{
		static IsWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", "IsWindow", "Ptr")
		if (BrightnessSetter._osdHwnd && DllCall(IsWindow, "Ptr", BrightnessSetter._osdHwnd))
			return
		BrightnessSetter._FindAndSetOSDWindow()
		if (BrightnessSetter._osdHwnd) {
			return
		} else {
			succeeded := False
			BrightnessSetter._osdHwnd := 0
			try shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
			if (shellProvider) {
				try flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}")
				if (flyoutDisp) {
					if ((succeeded := DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0) == 0))
						BrightnessSetter._FindAndSetOSDWindow()
					ObjRelease(flyoutDisp)
				}
				ObjRelease(shellProvider)
			}
			if (!succeeded) {
				; who knows if the SID & IID above will work for future versions of Windows 10. Fall back to this if needs must
				Loop 5
				{
					Loop 2
						SendEvent {Volume_Mute}
					BrightnessSetter._FindAndSetOSDWindow()
					if (BrightnessSetter._osdHwnd)
						break
					Sleep 100
				}
			}
		}
	}
	
	_FindAndSetOSDWindow()
	{
		static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
		BrightnessSetter._osdHwnd := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	}

	_On_WM_POWERBROADCAST(wParam, lParam)
	{
		;OutputDebug % &this
		if (wParam == 0x8013 && lParam && NumGet(lParam+0, 0, "UInt") == NumGet(BrightnessSetter._GUID_ACDC_POWER_SOURCE()+0, 0, "UInt")) { ; PBT_POWERSETTINGCHANGE and a lazy comparison
			this._AC := NumGet(lParam+0, 20, "UChar") == 0
			return True
		}
	}

	_GUID_VIDEO_SUBGROUP()
	{
		static GUID_VIDEO_SUBGROUP__
		if (!VarSetCapacity(GUID_VIDEO_SUBGROUP__)) {
			VarSetCapacity(GUID_VIDEO_SUBGROUP__, 16)
			,NumPut(0x7516B95F, GUID_VIDEO_SUBGROUP__, 0, "UInt"), NumPut(0x4464F776, GUID_VIDEO_SUBGROUP__, 4, "UInt")
			,NumPut(0x1606538C, GUID_VIDEO_SUBGROUP__, 8, "UInt"), NumPut(0x99CC407F, GUID_VIDEO_SUBGROUP__, 12, "UInt")
		}
		return &GUID_VIDEO_SUBGROUP__
	}

	_GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS()
	{
		static GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__
		if (!VarSetCapacity(GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__)) {
			VarSetCapacity(GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 16)
			NumPut(0xADED5E82, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 0, "UInt"), NumPut(0x4619B909, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 4, "UInt")
		   ,NumPut(0xD7F54999, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 8, "UInt"), NumPut(0xCB0BAC1D, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 12, "UInt")
		}
		return &GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__
	}

	_GUID_ACDC_POWER_SOURCE()
	{
		static GUID_ACDC_POWER_SOURCE_
		if (!VarSetCapacity(GUID_ACDC_POWER_SOURCE_)) {
			VarSetCapacity(GUID_ACDC_POWER_SOURCE_, 16)
			NumPut(0x5D3E9A59, GUID_ACDC_POWER_SOURCE_, 0, "UInt"), NumPut(0x4B00E9D5, GUID_ACDC_POWER_SOURCE_, 4, "UInt")
		   ,NumPut(0x34FFBDA6, GUID_ACDC_POWER_SOURCE_, 8, "UInt"), NumPut(0x486551FF, GUID_ACDC_POWER_SOURCE_, 12, "UInt")
		}
		return &GUID_ACDC_POWER_SOURCE_
	}
}

; ----------

BS := new BrightnessSetter()

<^F1::
	Send {LAlt down}{Left}{LAlt up}
	Return

<^F2::
	Send {LAlt down}{Right}{LAlt up}
	Return

<^F3::
	Send {F5}
	Return

; ----------

<^F4::
	Send {F11}
	Return

<^+F4::
	Send {LWin down}{P}{LWin Up}
	Return

<^F5::
	Send {LWin down}{Tab}{LWin up}
	Return

<^+F5::
	Send {LWin down}{PrintScreen}{LWin up}
	Return

; ----------

; brightness down = Ctrl+F6
<^F6::
	BS.SetBrightness(-10)
	Return

; brightness up = Ctrl+F7
<^F7::
	BS.SetBrightness(10)
	Return

; -----


; mute = Ctrl+F8
<^F8::Volume_Mute

; volume down = Ctrl+F9
<^F9::Volume_Down

; volume up = Ctrl+F10
<^F10::Volume_Up

; -----

; delete = Ctrl+Shift+Backspace
<^+BS::
	Send {LShift down}{Del}{LShift up}
	Return

; delete = Ctrl+Backspace
<^BS::
	Send {Del}
	Return

; ------

<^Up::
	Send {PgUp}
	Return

<^Down::
	Send {PgDn}
	Return

<^Left::
	Send {Home}
	Return

<^Right::
	Send {End}
	Return

; -------

>^1::
	Send {Blind}{RCtrl up}{F1}{RCtrl down}
	Return

>^2::
	Send {Blind}{RCtrl up}{F2}{RCtrl down}
	Return

>^3::
	Send {Blind}{RCtrl up}{F3}{RCtrl down}
	Return

>^4::
	Send {Blind}{RCtrl up}{F4}{RCtrl down}
	Return

>^5::
	Send {Blind}{RCtrl up}{F5}{RCtrl down}
	Return

>^6::
	Send {Blind}{RCtrl up}{F6}{RCtrl down}
	Return

>^7::
	Send {Blind}{RCtrl up}{F7}{RCtrl down}
	Return

>^8::
	Send {Blind}{RCtrl up}{F8}{RCtrl down}
	Return

>^9::
	Send {Blind}{RCtrl up}{F9}{RCtrl down}
	Return

>^0::
	Send {Blind}{RCtrl up}{F10}{RCtrl down}
	Return

>^vkBD::
	Send {F11}
	Return

>^vkBB::
	Send {F12}
	Return