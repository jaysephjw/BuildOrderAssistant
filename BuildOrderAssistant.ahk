/*
	____   ___     ___  ____    ___    ____ 
	/    | /   \   /  _]|    \  /   \  /    |
	|  o  ||     | /  [_ |  o  )|     ||  o  |
	|     ||  O  ||    _]|     ||  O  ||     |
	|  _  ||     ||   [_ |  O  ||     ||  _  |
	|  |  ||     ||     ||     ||     ||  |  |
	|__|__| \___/ |_____||_____| \___/ |__|__|
	
	AoE2 Build Overlay Assistant (Boa)
	Author: Jay Warrick
*/
;-------------------------   Script Settings   -------------------------------

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force ; Only ever run one of these.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;-------------------------   Data   -------------------------------

/*
	Class representing a build order. Has an string array of steps (1 indexed) and a string name.
*/
class BuildOrder
{
	__New(Steps, Name)
	{
		this.Steps := Steps
		this.Name := Name
	}
}

/*
	
*/

ArcherRushBuild := new BuildOrder(["6 on food", "4 on wood (10)", "13 total on food (17)", "9 total on wood (22)", "Click feudal", "Rebalance: 11w - 8f - 3g", "Build rax at 66%", "Build Archery + Smith", "Get 5-6 archers + Fletching", "Prep for castle age", "+6 on gold (28)", "+10 on food (38)"], "Archer Rush")

FastCastleKnightsBuild := new BuildOrder(["6 on food", "4 on wood", "14 on food", "10 on wood", "3 on gold", "Loom + 8 Farms", "Click Feudal", "Barracks at 66%", "5 on gold", "Smithy + Stable", "CLick Castle", "Second stable"], "Fast Castle Knights")


;-------------------------   Global variables   -------------------------------

; BuildList := [ArcherRushBuild, FastCastleKnightsBuild] ; TODO: dynamic number of builds

StepIndex := 1			; The current build order step (AHK arrays are 1-indexed)
SelectedBuild :=	 ""	; The picked build orer

;-------------------------   Hot keys   -------------------------------


/*
	Hotkey to toggle the overlay on and off. Start here.
	When toggling off, any build progress is lost.
*/
^!a::
if WinExist("AHK Pick Build Window") or WinExist("AHK Build Progress Window")
	WinKill
else
	ShowPickBuild()
return

/*
	Move to the next build step.
*/
!XButton1::
^!z::
RemoveProgress()
return

/*
	Move to the previous build step.
*/
!XButton2::
^!x:: 
AddProgress()
return

;-------------------------   Program Functions   -------------------------------

ShowPickBuild() {
	global 
	Gui, New,, AHK Pick Build Window
	Gui, Add, Button, Default gPickArchers, % "&" . ArcherRushBuild.Name
	Gui, Add, Button, gPickFastCastleKnights, % "&" . FastCastleKnightsBuild.Name
	Gui, Add, Text, , % "Use tab and enter to pick a build"
	Gui Show
}

PickArchers() {
	global 
	SelectedBuild := ArcherRushBuild
	NowShowProgress()
}

PickFastCastleKnights() {
	global 
	SelectedBuild := FastCastleKnightsBuild
	NowShowProgress()
}

NowShowProgress() {
	global
	Gui, Destroy 		; Destory the build picker GUI 
	ShowBuildProgress()
}

ShowBuildProgress() {
	global 
	StepIndex := 1
	local maxLen := SelectedBuild.Steps.Length()
	Gui, BoGui:New,, AHK Build Order Window
	Gui, Add, Progress, w200 h50 Range0-%maxLen% vMyProgress, %StepIndex%
	gui, Add, Text, vMyText w200, % (SelectedBuild.Steps[StepIndex])
	Gui, Show, w230 h100 x543 y65
	; Progress b w230 x543 y65 r%StepIndex%-%maxLen% p%StepIndex%, % (SelectedBuild.Steps[StepIndex]), % SelectedBuild.Name, % "AHK Build Progress Window"
}

AddProgress() {
	global
	if (StepIndex < SelectedBuild.Steps.Length()) {
		StepIndex := StepIndex + 1
	}
	UpdateProgress()
	;Progress, %StepIndex%, % (SelectedBuild.Steps[StepIndex])
}

RemoveProgress() {
	global
	if (StepIndex > 1) {
		StepIndex := StepIndex - 1
	}
	UpdateProgress()	
	;Progress, %StepIndex%, % (SelectedBuild.Steps[StepIndex])
}

UpdateProgress() {
	global
	;MsgBox % (SelectedBuild.Steps[StepIndex])
	Gui, BoGui:Default
	GuiControl,,MyText,% (SelectedBuild.Steps[StepIndex])
	GuiControl,,MyProgress, % StepIndex
}