class RPGO_UIClassIconSelectionScreen extends UIScreen config(RPGO_ClassIcons);

var int UnitStateObjectId, SelectedIndex;

var UIPanel m_kContainer;
var UIX2PanelHeader m_kTitleHeader;
var UIBGBox m_kBG;

var RPGO_UIImageSelector ImageSelector;

var config int iWidth, iHeight;

var config array<string> ClassIconImagePaths;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local float initX, initY;
	local float initWidth, initHeight;
	
	super.InitScreen(InitController, InitMovie, InitName);

	initX = (1920 - iWidth) / 2;
	initY = (1080 - iHeight) / 2;
	initWidth = iWidth;
	initHeight = iHeight;
	
	m_kContainer = Spawn(class'UIPanel', self);
	m_kContainer.InitPanel('');
	m_kContainer.SetPosition(initX, initY);
	m_kContainer.SetSize(initWidth, initHeight);

	m_kBG = Spawn(class'UIBGBox', m_kContainer);
	m_kBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	m_kBG.InitBG('', 0, 0, m_kContainer.Width, m_kContainer.Height);
	m_kBG.DisableNavigation();

	m_kTitleHeader = Spawn(class'UIX2PanelHeader', m_kContainer);
	m_kTitleHeader.InitPanelHeader('', Caps(class'XGLocalizedData_RPG'.default.SelectClassIcon), "");
	m_kTitleHeader.SetHeaderWidth(m_kContainer.width - 20);
	m_kTitleHeader.SetPosition(10, 20);

	ImageSelector = Spawn(class'RPGO_UIImageSelector', m_kContainer);
	ImageSelector.InitImageSelector(, 0, 70, m_kContainer.Width - 10, m_kContainer.height - 80, default.ClassIconImagePaths, , SetClassIcon, SelectedIndex);
}

function SetClassIcon(int iImageIndex)
{
	local XComGameState NewGameState;
	local XComGameState_CustomClassInsignia CustomClassInsigniaGameState;

	if (SelectedIndex == iImageIndex)
	{
		OnCancel();
		return;
	}
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Change Class ImagePath");
	CustomClassInsigniaGameState = class'XComGameState_CustomClassInsignia'.static.GetGameState();
	CustomClassInsigniaGameState = XComGameState_CustomClassInsignia(NewGameState.ModifyStateObject(CustomClassInsigniaGameState.Class, CustomClassInsigniaGameState.ObjectID));
	CustomClassInsigniaGameState.SetClassIconForUnit(default.ClassIconImagePaths[iImageIndex], UnitStateObjectId);
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	
	UpdatePromotionScreen();
	OnCancel();
} 

private function UpdatePromotionScreen()
{
	local UIArmory_PromotionHero Promotion;

	Promotion = UIArmory_PromotionHero(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_PromotionHero'));

	if (Promotion != none)
	{
		Promotion.CycleToSoldier(Promotion.GetUnit().GetReference());
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	// Only pay attention to presses or repeats; ignoring other input types
	// NOTE: Ensure repeats only occur with arrow keys
	if ( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	bHandled = true;
	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			OnCancel();
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

simulated function OnCancel()
{
	CloseScreen();
}


defaultproperties
{
	bConsumeMouseEvents = true
	InputState = eInputState_Consume;
}