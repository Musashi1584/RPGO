class UISL_UIShell_RPGO extends UIScreenListener config(RPGO_NullConfig);

var config bool bDismissedNewSWO;

var localized string strCommunityHighlanderMissing;
var localized string strIncompatibleModsFound;
var localized string strSWOInfo;

event OnInit(UIScreen Screen)
{
	if(UIShell(Screen) != none)
	{
		if (!IsDLCInstalled('X2WOTCCommunityHighlander'))
		{
			Screen.SetTimer(1.5f, false, nameof(MakePopupHighlanderMissing), self);
		}
		if (!bDismissedNewSWO)
		{
			Screen.SetTimer(1.8f, false, nameof(NewSwoInfo), self);
		}

		Screen.SetTimer(1.0f, false, nameof(IncompatibleModWarning), self);
	}
}

simulated function MakePopupHighlanderMissing()
{
	local TDialogueBoxData kDialogData;
	kDialogData.eType = eDialog_Warning;
	kDialogData.strText = strCommunityHighlanderMissing;
	kDialogData.fnCallback = OKClickedGeneric;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericAccept;

	`LOG(default.class @ "ERROR Missing X2WOTCCommunityHighlander",, 'RPG');

	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function NewSwoInfo()
{
	local TDialogueBoxData kDialogData;
	kDialogData.eType = eDialog_Normal;
	kDialogData.strText = strSWOInfo;
	kDialogData.fnCallback = OKClickedSwoCB;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericAccept;

	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function IncompatibleModWarning()
{
	local TDialogueBoxData kDialogData;
	local array<string> FoundIncompatibleMods;

	FoundIncompatibleMods = GetIncompatibleMods();

	`LOG(default.class @ GetFuncName @ Join(FoundIncompatibleMods, ","),, 'RPG');

	if (FoundIncompatibleMods.Length == 0)
	{
		return;
	}

	kDialogData.eType = eDialog_Warning;
	kDialogData.strText = strIncompatibleModsFound $ Join(FoundIncompatibleMods, "\n");
	kDialogData.fnCallback = OKClickedGeneric;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericAccept;
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

simulated function array<string> GetIncompatibleMods()
{
	local string IncompatibleMod;
	local array<string> FoundIncompatibleMods;

	foreach class'X2DownloadableContentInfo_XCOM2RPGOverhaul'.default.IncompatibleMods(IncompatibleMod)
	{
		if (IsDLCInstalled(name(IncompatibleMod)))
		{
			FoundIncompatibleMods.AddItem(IncompatibleMod);
		}
	}
	return FoundIncompatibleMods;
}

static function bool IsDLCInstalled(name DLCName)
{
	local XComOnlineEventMgr EventManager;
	local int i;
		
	EventManager = `ONLINEEVENTMGR;
	for(i = 0; i < EventManager.GetNumDLC(); ++i)
	{
		if (DLCName == EventManager.GetDLCNames(i))
		{
			return true;
		}
	}
	return false;
}

function static string Join(array<string> StringArray, optional string Delimiter = ",", optional bool bIgnoreBlanks = true)
{
	local string Result;

	JoinArray(StringArray, Result, Delimiter, bIgnoreBlanks);

	return Result;
}