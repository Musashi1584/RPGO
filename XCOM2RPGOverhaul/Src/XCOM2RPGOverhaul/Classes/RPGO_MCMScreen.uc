//-----------------------------------------------------------
//	Class:	RPGO_MCMScreen
//	Author: Musashi
//	
//-----------------------------------------------------------


class RPGO_MCMScreen extends Object config(RPGO);

var MCM_API_SettingsPage Page1, Page2;
var MCM_API_SettingsGroup Group1, Group2, Group3;
var MCM_API_Label P1Label;
var MCM_API_Button P1Button;
var MCM_API_Checkbox P1Checkbox;
var MCM_API_Slider P2Slider;
var MCM_API_Slider P2SliderFloat;
var MCM_API_Dropdown P2Dropdown;
var MCM_API_Spinner P2Spinner;

var config int VERSION_CFG;
var config bool CFG_CLICKED;
var config bool CFG_CHECKBOX;
var config float CFG_SLIDER;
var config string CFG_DROPDOWN;
var config string CFG_SPINNER;

var localized string ModName;
var localized string PageTitle1;
var localized string PageTitle2;
var localized string GroupHeader1;
var localized string GroupHeader2;

`include(XCOM2RPGOverhaul/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

/***************************************
Insert `MCM_API_Auto????Vars macros here
***************************************/

`include(XCOM2RPGOverhaul/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

/********************************************************************
Insert `MCM_API_Auto????Fns and MCM_API_AutoButtonHandler macros here
********************************************************************/

event OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

//Simple one group framework code
simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{

	local array<string> Options;

	class'RPGO_MCM_Builder'.static.BuildMCM(
		ConfigAPI,
		GameMode
	);

	return;

	CFG_CLICKED=false;
	CFG_CHECKBOX=true;
	CFG_SLIDER=100;
	CFG_DROPDOWN="a";
	CFG_SPINNER="a";

	LoadSavedSettings();
	Page1 = ConfigAPI.NewSettingsPage(ModName);
	Page1.SetPageTitle(PageTitle1);
	Page1.SetSaveHandler(SaveButtonClicked);

	Page2 = ConfigAPI.NewSettingsPage(ModName);
	Page2.SetPageTitle(PageTitle2);
	Page2.SetSaveHandler(SaveButtonClicked);
	
	//Uncomment to enable reset
	//Page.EnableResetButton(ResetButtonClicked);

	Group1 = Page1.AddGroup('Group1', GroupHeader1);
	Group2 = Page1.AddGroup('Group2', GroupHeader2);
	Group3 = Page2.AddGroup('Group3', "Group 3 Test");

	P1Label = Group1.AddLabel('label', "P1Label", "P!!!Label");
	P1Button = Group1.AddButton('button', "Button", "Button", "OK", ButtonClickedHandler);
	P1Checkbox = Group1.AddCheckbox('checkbox', "Checkbox", "Checkbox", CFG_CHECKBOX, CheckboxSaveLogger);

	P2Slider = Group2.AddSlider('slider', "Slider", "Slider", -30, 30, 1, CFG_SLIDER, SliderSaveLogger);
	P2SliderFloat = Group2.AddSlider('floatslider', "Partial", "Partial", -30, 30, 0, -30.5, none);

	Options.Length = 0;
	Options.AddItem("a");
	Options.AddItem("b");
	Options.AddItem("c");
	Options.AddItem("d");
	Options.AddItem("e");
	Options.AddItem("f");
	Options.AddItem("g");

	P2Spinner = Group2.AddSpinner('spinner', "Spinner", "Spinner", Options, CFG_SPINNER, SpinnerSaveLogger);
	P2Dropdown = Group2.AddDropdown('dropdown', "Dropdown", "Dropdown", Options, CFG_DROPDOWN, DropdownSaveLogger);



	//Group2 = Page2.AddGroup('Group2', GroupHeader2);

/********************************************************
	MCM_API_AutoAdd??????? Macro's go here
********************************************************/

	Page1.ShowSettings();
	Page2.ShowSettings();
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveLogger, CFG_CHECKBOX)
`MCM_API_BasicSliderSaveHandler(SliderSaveLogger, CFG_SLIDER)
`MCM_API_BasicDropdownSaveHandler(DropdownSaveLogger, CFG_DROPDOWN)
`MCM_API_BasicSpinnerSaveHandler(SpinnerSaveLogger, CFG_SPINNER)
`MCM_API_BasicButtonHandler(ButtonClickedHandler)
{
    // Tests the slider positioning error.
    P2Slider.SetBounds(-200, 0, 20, P2Slider.GetValue(), true);

    CFG_CLICKED = true;
}

simulated function LoadSavedSettings()
{
/************************************************************************
	Use GETMCMVAR macro to assign values to the config variables here
************************************************************************/
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
/********************************************************
	MCM_API_AutoReset macros go here
********************************************************/
}


simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	VERSION_CFG = `MCM_CH_GetCompositeVersion();
	SaveConfig();
}


