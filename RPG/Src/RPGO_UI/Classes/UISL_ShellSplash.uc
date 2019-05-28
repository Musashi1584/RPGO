class UISL_ShellSplash extends UIScreenListener config(Game);

var config bool bEnableVersionDisplay;
var string RPGO_VERSION;

event OnInit(UIScreen Screen)
{
	if(UIShell(Screen) == none || !bEnableVersionDisplay)  // this captures UIShell and UIFinalShell
		return;

	RealizeVersionText(UIShell(Screen));
}

event OnReceiveFocus(UIScreen Screen)
{
	if(UIShell(Screen) == none || !bEnableVersionDisplay)  // this captures UIShell and UIFinalShell
		return;

	RealizeVersionText(UIShell(Screen));
}

event OnRemoved(UIScreen Screen)
{
	if(UIShell(Screen) == none || !bEnableVersionDisplay)  // this captures UIShell and UIFinalShell
		return;
}

function RealizeVersionText(UIShell ShellScreen)
{
	local string VersionString;
	local int i;
	local UIText VersionTextHighlander, VersionTextRPGO;
	
	VersionString = "RPGO" @ RPGO_VERSION;

	VersionTextHighlander = UIText(ShellScreen.GetChildByName('theVersionText', false));
	VersionTextRPGO = UIText(ShellScreen.GetChildByName('theVersionTextRPGO', false));
	if (VersionTextRPGO == none)
	{
		VersionTextRPGO = ShellScreen.Spawn(class'UIText', ShellScreen);
		VersionTextRPGO.InitText('theVersionTextRPGO', VersionString);
		// This code aligns the version text to the Main Menu Ticker
		VersionTextRPGO.AnchorBottomRight();
		VersionTextRPGO.SetX(VersionTextRPGO.X - VersionTextHighlander.Width - 30);
		VersionTextRPGO.SetY(-ShellScreen.TickerHeight + 10);
	}
}


defaultProperties
{
	ScreenClass = none
	HelpLink = "https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/wiki/Troubleshooting"
}
