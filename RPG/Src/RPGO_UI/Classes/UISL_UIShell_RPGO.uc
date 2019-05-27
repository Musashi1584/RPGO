class UISL_UIShell_RPGO extends UIScreenListener config(RPGO_NullConfig);

var config bool bDismissedNewSWO;

var localized string strCommunityHighlanderMissing;
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
	}
}

simulated function MakePopupHighlanderMissing()
{
	local TDialogueBoxData kDialogData;
	kDialogData.eType = eDialog_Warning;
	kDialogData.strText = strCommunityHighlanderMissing;
	kDialogData.fnCallback = OKClickedHLCB;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericAccept;

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

simulated function OKClickedHLCB(Name eAction)
{
	`PRESBASE.PlayUISound(eSUISound_MenuSelect);
}

simulated function OKClickedSwoCB(Name eAction)
{
	`PRESBASE.PlayUISound(eSUISound_MenuSelect);
	bDismissedNewSWO = true;
	self.SaveConfig();
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