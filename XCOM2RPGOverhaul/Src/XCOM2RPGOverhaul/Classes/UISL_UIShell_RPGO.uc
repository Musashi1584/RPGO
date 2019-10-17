class UISL_UIShell_RPGO extends UIScreenListener config(RPGO_NullConfig);

var config bool bDismissedNewSWO;

var localized string strCommunityHighlanderMissing;
var localized string strIncompatibleModsFound;
var localized string strSWOInfo;
var localized string strTitleCommunityHighlanderMissing;
var localized string strTitleIncompatibleMod;
var localized string strTitleSWOInfo;
var localized string strTitleRequiredMod;
var localized string strRequiredModsMissing;

event OnInit(UIScreen Screen)
{
	if(UIShell(Screen) != none)
	{
		if (!class'RPGO_UI_Helper'.static.IsDLCInstalled('X2WOTCCommunityHighlander'))
		{
			Screen.SetTimer(1.5f, false, nameof(MakePopupHighlanderMissing), self);
		}
		if (!bDismissedNewSWO)
		{
			Screen.SetTimer(1.8f, false, nameof(NewSwoInfo), self);
		}

		//Screen.SetTimer(2.0f, false, nameof(IncompatibleModWarning), self);
		//Screen.SetTimer(2.1f, false, nameof(RequiredModWarning), self);
	}
}

simulated function MakePopupHighlanderMissing()
{
	local TDialogueBoxData kDialogData;
	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = strTitleCommunityHighlanderMissing;
	kDialogData.strText = strCommunityHighlanderMissing;
	kDialogData.fnCallback = OKClickedGeneric;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;

	`LOG("ERROR -------------------------------------------------------------------------",, 'RPG');
	`LOG("ERROR --------------- Missing X2WOTCCommunityHighlander -----------------------",, 'RPG');
	`LOG("ERROR -------------------------------------------------------------------------",, 'RPG');

	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function NewSwoInfo()
{
	local TDialogueBoxData kDialogData;
	kDialogData.eType = eDialog_Normal;
	kDialogData.strTitle = strTitleSWOInfo;
	kDialogData.strText = strSWOInfo;
	kDialogData.fnCallback = OKClickedSwoCB;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;

	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function IncompatibleModWarning()
{
	local TDialogueBoxData kDialogData;
	local array<string> FoundIncompatibleMods;

	FoundIncompatibleMods = class'RPGO_UI_Helper'.static.GetIncompatibleMods();

	if (FoundIncompatibleMods.Length == 0)
	{
		return;
	}

	`LOG(GetFuncName() @ class'RPGO_UI_Helper'.static.Join(FoundIncompatibleMods, ","),, 'RPG');

	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = strTitleIncompatibleMod;
	kDialogData.strText = class'UIUtilities_Text'.static.GetColoredText(strIncompatibleModsFound, eUIState_Header) @
						  class'UIUtilities_Text'.static.GetColoredText(class'RPGO_UI_Helper'.static.MakeBulletList(FoundIncompatibleMods), eUIState_Bad);
	kDialogData.fnCallback = OKClickedGeneric;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;
	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function RequiredModWarning()
{
	local TDialogueBoxData kDialogData;
	local array<string> RequiredMods;

	RequiredMods = class'RPGO_UI_Helper'.static.GetRequiredModsMissing();

	if (RequiredMods.Length == 0)
	{
		return;
	}

	`LOG(GetFuncName() @ class'RPGO_UI_Helper'.static.Join(RequiredMods, ","),, 'RPG');

	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = strTitleRequiredMod;
	kDialogData.strText = class'UIUtilities_Text'.static.GetColoredText(strRequiredModsMissing, eUIState_Header) @
						  class'UIUtilities_Text'.static.GetColoredText(class'RPGO_UI_Helper'.static.MakeBulletList(RequiredMods), eUIState_Bad);
	kDialogData.fnCallback = OKClickedGeneric;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;
	`PRESBASE.UIRaiseDialog(kDialogData);
}


simulated function OKClickedGeneric(Name eAction)
{
	`PRESBASE.PlayUISound(eSUISound_MenuSelect);
}

simulated function OKClickedSwoCB(Name eAction)
{
	`PRESBASE.PlayUISound(eSUISound_MenuSelect);
	bDismissedNewSWO = true;
	self.SaveConfig();
}
