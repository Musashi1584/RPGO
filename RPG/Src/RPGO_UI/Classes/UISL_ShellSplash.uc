class UISL_ShellSplash extends UIScreenListener config(Game);

var config bool bEnableVersionDisplay;
var localized string strRequiredModsTooltip;
var localized string strIncompatibleModsTooltip;
var localized string strRequiredLoadedModsTooltip;

event OnInit(UIScreen Screen)
{
	if(UIShell(Screen) == none || !bEnableVersionDisplay)  // this captures UIShell and UIFinalShell
		return;

	// This is a circular problem: The main menu info accessible on controller
	// using this input hook is most useful when the HL *isn't* working -- but then,
	// this input hook doesn't exist. Not much we can do other than ensuring the
	// user makes it to the main menu screen, sees the error message and checks the log.
	if (Function'XComGame.UIScreenStack.SubscribeToOnInput' != none)
	{
		Screen.Movie.Stack.SubscribeToOnInput(OnInputHook);
	}

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

	if (Function'XComGame.UIScreenStack.UnsubscribeFromOnInput' != none)
	{
		Screen.Movie.Stack.UnsubscribeFromOnInput(OnInputHook);
	}
}

function EUIState ColorForStatus(bool bIncompatibleModsFound, bool bRequiredModsMissing)
{

	if (bIncompatibleModsFound || bRequiredModsMissing)
	{
		return eUIState_Bad;
	}

	return eUIState_Normal;
}

function RealizeVersionText(UIShell ShellScreen)
{
	local string VersionString, TooltipString;
	local UIText VersionTextRPGO;
	local X2StrategyElementTemplateManager Manager;
	local X2StrategyElementTemplate StrategyTemplate;
	local RPGOVersionTemplate VersionTemplate;
	local UIBGBox TooltipHitbox;
	local UIBGBox TooltipBG;
	local UIText TooltipText;
	local array<string> IncompatibleMods;
	local array<string> RequiredModsMissing;
	local array<string> RequiredModsLoaded;

	RequiredModsMissing = class'RPGO_UI_Helper'.static.GetRequiredModsMissing();
	RequiredModsLoaded = class'RPGO_UI_Helper'.static.GetRequiredModsLoaded();
	IncompatibleMods = class'RPGO_UI_Helper'.static.GetIncompatibleMods();

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	StrategyTemplate = Manager.FindStrategyElementTemplate('RPGOVersion');
	
	VersionTemplate = RPGOVersionTemplate(StrategyTemplate);
	VersionString = class'UIUtilities_Text'.static.GetColoredText(
		VersionTemplate.GetSemanticVersionString(),
		ColorForStatus(IncompatibleMods.Length > 0, RequiredModsMissing.Length > 0),
		22
	);

	`log("Showing version" @ VersionString @ "on shell screen...", , 'RPG');

	VersionTextRPGO = UIText(ShellScreen.GetChildByName('theVersionTextRPGO', false));
	if (VersionTextRPGO == none)
	{
		VersionTextRPGO = ShellScreen.Spawn(class'UIText', ShellScreen);
		VersionTextRPGO.InitText('theVersionTextRPGO');
		// This code aligns the version text to the Main Menu Ticker
		VersionTextRPGO.AnchorBottomCenter();
		VersionTextRPGO.SetY(-ShellScreen.TickerHeight + 10);
	}

	if (`ISCONTROLLERACTIVE)
	{
		VersionTextRPGO.SetHTMLText(class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Input'.static.GetGamepadIconPrefix() 
								$ class'UIUtilities_Input'.const.ICON_RSCLICK_R3, 20, 20, -10) 
								@ VersionString, OnTextSizeRealized);
	}
	else
	{
		VersionTextRPGO.SetHTMLText(VersionString, OnTextSizeRealized);
	}

	TooltipString = "";

	// Add a tooltip
	if (RequiredModsLoaded.Length > 0)
	{
		TooltipString $= 
			class'UIUtilities_Text'.static.GetColoredText(strRequiredLoadedModsTooltip, eUIState_Normal, 28) @
			class'UIUtilities_Text'.static.GetColoredText(class'RPGO_UI_Helper'.static.MakeBulletList(RequiredModsLoaded), eUIState_Good, 22);
	}

	if (RequiredModsMissing.Length > 0)
	{
		TooltipString $= 
			class'UIUtilities_Text'.static.GetColoredText(strRequiredModsTooltip, eUIState_Header, 28) @
			class'UIUtilities_Text'.static.GetColoredText(class'RPGO_UI_Helper'.static.MakeBulletList(RequiredModsMissing), eUIState_Bad, 22);
	}

	if (IncompatibleMods.Length > 0)
	{
		TooltipString $= 
			class'UIUtilities_Text'.static.GetColoredText(strIncompatibleModsTooltip, eUIState_Header, 28) @
			class'UIUtilities_Text'.static.GetColoredText(class'RPGO_UI_Helper'.static.MakeBulletList(IncompatibleMods), eUIState_Bad, 22);
	}

	TooltipHitbox = UIBGBox(ShellScreen.GetChildByName('theVersionHitboxRPGO', false));
	if (TooltipHitbox == none)
	{
		// Create an invisible hitbox above the text with a tooltip
		TooltipHitbox = ShellScreen.Spawn(class'UIBGBox', ShellScreen);
		TooltipHitbox.InitBG('theVersionHitboxRPGO', 0, 0, 1, 1);
		TooltipHitbox.AnchorBottomCenter();
		TooltipHitbox.SetAlpha(0.00001f);
		TooltipHitbox.ProcessMouseEvents(OnHitboxMouseEvent);
	}

	TooltipBG = UIBGBox(ShellScreen.GetChildByName('theTooltipBG_RPGO', false));
	if (TooltipBG == none)
	{
		TooltipBG = ShellScreen.Spawn(class'UIBGBox', ShellScreen);
		TooltipBG.InitBG('theTooltipBG_RPGO', 0, 0, 1, 1);
		TooltipBG.AnchorBottomCenter();
		TooltipBG.Hide();
	}

	TooltipText = UIText(ShellScreen.GetChildByName('theTooltipTextRPGO', false));
	if (TooltipText == none)
	{
		TooltipText = ShellScreen.Spawn(class'UIText', ShellScreen);
		TooltipText.InitText('theTooltipTextRPGO');
		TooltipText.AnchorBottomCenter();
		TooltipText.Hide();
	}

	TooltipText.SetHTMLText(TooltipString, OnTooltipTextSizeRealized);
}

function OnTextSizeRealized()
{
	local UIText VersionText;
	local UIShell ShellScreen;
	local UIPanel TooltipHitbox;

	ShellScreen = UIShell(`SCREENSTACK.GetFirstInstanceOf(class'UIShell'));
	VersionText = UIText(ShellScreen.GetChildByName('theVersionTextRPGO'));
	//VersionText.SetX(-10 - VersionText.Width);
	// this makes the ticker shorter -- if the text gets long enough to interfere, it will automatically scroll
	//ShellScreen.TickerText.SetWidth(ShellScreen.Movie.m_v2ScaledFullscreenDimension.X - VersionText.Width - 20);

	TooltipHitbox = ShellScreen.GetChildByName('theVersionHitboxRPGO');
	TooltipHitbox.SetPosition(VersionText.X, VersionText.Y);
	TooltipHitbox.SetSize(VersionText.Width, VersionText.Height);
}

function OnTooltipTextSizeRealized()
{
	local UIText TooltipText;
	local UIBGBox TooltipBG;
	local UIShell ShellScreen;

	ShellScreen = UIShell(`SCREENSTACK.GetFirstInstanceOf(class'UIShell'));
	TooltipBG = UIBGBox(ShellScreen.GetChildByName('theTooltipBG_RPGO', false));
	TooltipText = UIText(ShellScreen.GetChildByName('theTooltipTextRPGO', false));

	TooltipBG.SetSize(TooltipText.Width + 20, TooltipText.Height + 20);

	//TooltipText.SetPosition(-TooltipBG.Width - 10, -TooltipBG.Height - 10 - ShellScreen.TickerHeight);
	TooltipText.SetY(-TooltipBG.Height - 10 - ShellScreen.TickerHeight);
	//TooltipBG.SetPosition(-TooltipBG.Width - 15, -TooltipBG.Height - 15 - ShellScreen.TickerHeight);
	TooltipBG.SetY(-TooltipBG.Height - 15 - ShellScreen.TickerHeight);
}

function OnHitboxMouseEvent(UIPanel control, int cmd)
{
	local UIText TooltipText;
	local UIBGBox TooltipBG;
	local UIShell ShellScreen;

	ShellScreen = UIShell(`SCREENSTACK.GetFirstInstanceOf(class'UIShell'));
	TooltipBG = UIBGBox(ShellScreen.GetChildByName('theTooltipBG_RPGO', false));
	TooltipText = UIText(ShellScreen.GetChildByName('theTooltipTextRPGO', false));

	switch (cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
		TooltipText.Show();
		TooltipBG.Show();
		break;
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
		TooltipText.Hide();
		TooltipBG.Hide();
		break;
	}
}

function bool OnInputHook(int iInput, int ActionMask)
{
	local UIText TooltipText;
	local UIBGBox TooltipBG;
	local UIShell ShellScreen;

	if (iInput == class'UIUtilities_Input'.const.FXS_BUTTON_R3 && (ActionMask & class'UIUtilities_Input'.const.FXS_ACTION_RELEASE) != 0
		&& `SCREENSTACK.IsCurrentScreen(class'UIShell'.Name))
	{
		ShellScreen = UIShell(`SCREENSTACK.GetFirstInstanceOf(class'UIShell'));

		TooltipBG = UIBGBox(ShellScreen.GetChildByName('theTooltipBG_RPGO', false));
		TooltipText = UIText(ShellScreen.GetChildByName('theTooltipTextRPGO', false));

		TooltipBG.ToggleVisible();
		TooltipText.ToggleVisible();

		return true;
	}
	return false;
}

defaultProperties
{
	ScreenClass = none
	HelpLink = "https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/wiki/Troubleshooting"
}
