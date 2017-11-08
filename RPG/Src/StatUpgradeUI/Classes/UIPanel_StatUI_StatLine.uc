class UIPanel_StatUI_StatLine extends UIPanel config (UI);

struct StatIconBind
{
	var ECharStatType Stat;
	var string Icon;
};

var config array<StatIconBind> StatIcons;

var ArtifactCost TotalCost, CurrentCost;
var UIButton MinusSign, PlusSign;
var UIImage Image;
var UIText StatName, UpgradeCost;
var int IconSize;

var delegate<NumResourcesForIncrease> NumResourcesForIncreaseFn;

delegate int NumResourcesForIncrease();

simulated function UIPanel InitStatLine(ECharStatType StatType, string PanelText)
{
	local name PanelName;
	local int ButtonOffsetX;

	PanelName = name(string(StatType));
	InitPanel(PanelName);
	SetSize(Width, Height);

	Image = Spawn(class'UIImage', self).InitImage(name(PanelName $ '_Image'), GetStatIcon(StatType));
	Image.SetSize(IconSize, IconSize);
	Image.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	Image.SetX(20);

	StatName = Spawn(class'UIText', self).InitText(PanelName, PanelText);
	StatName.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(PanelText, eUIState_Normal, 48));
	StatName.SetX(100);
	//StatName.SetPosition(20, 0);
	//StatName.SetSize(120, 20);

	ButtonOffsetX = 360;
	MinusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ '_Minus'), "-", OnClickedDelegate);
	MinusSign.SetFontSize(48);
	MinusSign.SetResizeToText(true);
	MinusSign.SetX(ButtonOffsetX);

	PlusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ '_Plus'), "+", OnClickedDelegate);
	PlusSign.SetFontSize(48);
	PlusSign.SetResizeToText(true);
	PlusSign.SetX(ButtonOffsetX + 155);

	`LOG(self.class.name @ GetFuncName() @ PanelName @ "finished",, 'RPG');

	return self;
}

function string GetStatIcon(ECharStatType StatType)
{
	local int Index;

	Index = default.StatIcons.Find('Stat', StatType);

	if (Index != INDEX_NONE)
	{
		`LOG(self.class.name @ GetFuncName() @ default.StatIcons[Index].Icon,, 'RPG');
		return default.StatIcons[Index].Icon;
	}

	return "";
}

function OnClickedDelegate(UIButton Button)
{
	`LOG(self.Class.name @ GetFuncName() @ Button.MCName,, 'RPG');
}

simulated function UIPanel SetPosition(float NewX, float NewY)
{
	`LOG(self.Class.name @ GetFuncName() @ NewX @ NewY,, 'RPG');
	Image.SetY(NewY);
	StatName.SetY(NewY);
	MinusSign.SetY(NewY);
	PlusSign.SetY(NewY);
	return super.SetPosition(NewX, NewY);
}

defaultproperties
{
	Width=1000
	Height=80
	IconSize=64
}