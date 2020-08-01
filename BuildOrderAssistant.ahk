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

class Step
{
	__New(Name, Wood, Food, Gold, Stone)
	{
		this.Name := Name		
		this.Wood := Wood
		this.Food := Food
		this.Gold := Gold		
		this.Stone := Stone
	}
	
	VillCount
	{
		get {
			return this.Wood + this.Food + this.Gold + this.Stone
		}
	}
}

ArcherRushBuild := new BuildOrder([new Step("6 on food", 0, 6, 0, 0)
, new Step("get 4 on wood", 			4, 6, 0, 0)
, new Step("get 13 on food",			4, 13, 0, 0)
, new Step("get 9 on wood",		 	9, 13, 0, 0)
, new Step("Click feudal",		 	9, 13, 0, 0)
, new Step("Rebalance",				11, 8, 3, 0)
, new Step("Build rax at 66%", 		11, 8, 3, 0)
, new Step("Build Archery + Smith", 	11, 8, 3, 0)
, new Step("Get 5-6 archers+Fletching", 11, 8, 3, 0)
, new Step("+6 on gold",		 		11, 8, 9, 0)
, new Step("+10 on farms",	 		11, 18, 9, 0)]
, "Archer Rush")




FastCastleKnightsBuild := new BuildOrder([new Step("6 on food", 0, 6, 0, 0)
, new Step("4 on wood", 				4, 6, 0, 0)
, new Step("14 on food", 			4, 14, 0, 0)
, new Step("10 on wood", 			10, 14, 0, 0)
, new Step("3 on gold", 				10, 14, 3, 0)
, new Step("Loom + 8 Farms", 			10, 14, 3, 0)
, new Step("Click Feudal", 			10, 14, 3, 0)
, new Step("Barracks at 66%", 		10, 14, 3, 0)
, new Step("Build Smithy + Stable",	10, 14, 3, 0)
, new Step("+2 on gold", 			10, 14, 5, 0)
, new Step("CLick Castle", 			10, 14, 5, 0)
, new Step("Second stable before 80%",	10, 14, 5, 0)]
, "Fast Castle Knights")

ScoutRushBuild := new BuildOrder([new Step("1 -> 6 on food",	0, 6, 0, 0)
, new Step("3 on wood", 									3, 6, 0, 0)
, new Step("Vill 10 lure boar, 10 & 11 on boar" ,				3, 8, 0, 0)
, new Step("Vill 12 make 2 houses",						3, 8, 0, 0)
, new Step("Vill 12 -> 15 on berries (4)",					3, 12, 0, 0)
, new Step("Vill 16 & 17 on boar (9)",						3, 14, 0, 0)
, new Step("18 -> 20 new lumber camp (6 on wood)", 			6, 14, 0, 0)
, new Step("Click Feudal, start Barracks", 					6, 14, 0, 0)
, new Step("Rebalance: 4 sheep, 4 berries, 2 farms, 10 wood",	10, 10, 0, 0)
, new Step("Stable, 3-5 scouts, go!o",						10, 10, 0, 0)
, new Step("21 -> 28 Farms, Double-bit, Horse Collar",			10, 18, 0, 0)]
, "Scout Rush")


;-------------------------   Hot keys   -------------------------------

/*
	Hotkey to toggle the overlay on and off. Start here.
	When toggling off, any build progress is lost.
*/
^!a::
if WinExist("__Pick Build__") or WinExist("__BOA__")
	WinKill
else
	ShowPickBuild()
return

/*
	Move to the next build step.
*/
+`::
^!z::
RemoveProgress()
return

/*
	Move to the previous build step.
*/
`::
^!x:: 
AddProgress()
return

;-------------------------   Program Code   -------------------------------

StepIndex := 1			; The current build order step (AHK arrays are 1-indexed)
SelectedBuild := ""		; The picked build orer

BuildList=[ArcherRushBuild, ScoutRushBuild, FastCastleKnightsBuild ]

ShowPickBuild() {
	global 
	Gui, New, +AlwaysOnTop, % "__Pick Build__"
	Gui, Add, Button, gPickArchers, % "&" . ArcherRushBuild.Name
	Gui, Add, Button, gPickScoutRush, % "&" . ScoutRushBuild.Name	
	Gui, Add, Button, gPickFastCastleKnights, % "&" . FastCastleKnightsBuild.Name
	Gui, Add, Text, , % "Use tab and enter to pick a build"
	Gui Show
}

PickArchers() {
	global 
	SelectedBuild := ArcherRushBuild
	NowShowProgress()
}

PickScoutRush() {
	global 
	SelectedBuild := ScoutRushBuild
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
	local currentStep := SelectedBuild.Steps[StepIndex]
	Gui, BoGui:New, +AlwaysOnTop, % "__BOA__"
	Gui, Font, s12 w600, MS Sans Serif
	Gui, Add, Progress, w400 h15 Range0-%maxLen% vStepProgressGui, % StepIndex
	gui, Add, Text, vStepTextGui w420 y+2 R1, 			% currentStep.Name
	gui, Add, Text, vWoodCountGui w20 y+2 section, 		% currentStep.Wood
	gui, Add, Picture, w20 h-1 ys x+2, wood.png		
	gui, Add, Text, vFoodCountGui w20 ys, 			% currentStep.Food
	gui, Add, Picture, w20 h-1 ys x+2, food.png		
	gui, Add, Text, vGoldCountGui w20 ys, 			% currentStep.Gold
	gui, Add, Picture, w20 h-1 ys x+2, gold.png			
	gui, Add, Text, vStoneCountGui w20 ys, 			% currentStep.Stone
	gui, Add, Picture, w20 h-1 ys x+2, stone.png			
	gui, Add, Text, vTotalCountGui w40 ys, 			% "(" currentStep.VillCount ")"
	
	Gui, Show, w420 h80 x543 y65
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
	local currentStep := SelectedBuild.Steps[StepIndex]
	Gui, BoGui:Default
	GuiControl,,StepTextGui,		% currentStep.Name
	GuiControl,,StepProgressGui, 	% StepIndex
	GuiControl,,WoodCountGui, 	% currentStep.Wood
	GuiControl,,FoodCountGui, 	% currentStep.Food
	GuiControl,,GoldCountGui, 	% currentStep.Gold
	GuiControl,,StoneCountGui, 	% currentStep.Stone
	GuiControl,,TotalCountGui, 	% "(" currentStep.VillCount ")"
	
	;GuiControl,,VillCountGui, % currentStep.Wood "w  " currentStep.Food "f  " currentStep.Gold "g  " currentStep.Stone "s  (" currentStep.VillCount ")"
}