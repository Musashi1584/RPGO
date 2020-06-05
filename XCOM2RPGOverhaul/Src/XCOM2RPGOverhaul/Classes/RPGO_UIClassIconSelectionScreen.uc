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
	ImageSelector.InitImageSelector(, 0, 70, m_kContainer.Width - 10, m_kContainer.height - 80, GetAllClassIcons(), , SetClassIcon, SelectedIndex);
}

function array<string> GetAllClassIcons()
{
	local X2SoldierClassTemplateManager Manager;
	local array<X2SoldierClassTemplate> ClassTemplates; 
	local X2SoldierClassTemplate ClassTemplate;
	local array<string> AllClassIconImagePaths;
	local array<X2UniversalSoldierClassInfo> SpecTemplates;
	local X2UniversalSoldierClassInfo SpecTemplate;
	local string ClassIcon;

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();

	ClassTemplates = Manager.GetAllSoldierClassTemplates(true);
	foreach ClassTemplates(ClassTemplate)
	{
		if (ClassTemplate.IconImage != "")
		{
			ClassIcon = Repl(ClassTemplate.IconImage, "img://", "");
			if (AllClassIconImagePaths.Find(ClassIcon) == INDEX_NONE)
			{
				AllClassIconImagePaths.AddItem(ClassIcon);
			}
		}
	}

	SpecTemplates = class'X2SoldierClassTemplatePlugin'.static.GetAllAvailableSpecializationTemplates();
	foreach SpecTemplates(SpecTemplate)
	{
		if (SpecTemplate.ClassSpecializationIcon != "")
		{
			ClassIcon= Repl(SpecTemplate.ClassSpecializationIcon, "img://", "");
			if (AllClassIconImagePaths.Find(ClassIcon) == INDEX_NONE)
			{
				AllClassIconImagePaths.AddItem(ClassIcon);
			}
		}
	}

	foreach default.ClassIconImagePaths(ClassIcon)
	{
		if (AllClassIconImagePaths.Find(ClassIcon) == INDEX_NONE)
		{
			AllClassIconImagePaths.AddItem(ClassIcon);
		}
	}

	return AllClassIconImagePaths;
}

function SetClassIcon(int iImageIndex)
{
	local XComGameState NewGameState;
	local XComGameState_CustomClassInsignia CustomClassInsigniaGameState;
	local array<string> AllIcons;

	if (SelectedIndex == iImageIndex)
	{
		OnCancel();
		return;
	}

	AllIcons = GetAllClassIcons();
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Change Class ImagePath");
	CustomClassInsigniaGameState = class'XComGameState_CustomClassInsignia'.static.GetGameState();
	CustomClassInsigniaGameState = XComGameState_CustomClassInsignia(NewGameState.ModifyStateObject(CustomClassInsigniaGameState.Class, CustomClassInsigniaGameState.ObjectID));
	CustomClassInsigniaGameState.SetClassIconForUnit(AllIcons[iImageIndex], UnitStateObjectId);
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