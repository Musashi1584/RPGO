class UIScreen_StatUI extends UIArmory config(UI);

var UIPanel Container;
var UIBGBox PanelBG;
var UIBGBox FullBG;
var array<UIPanel> StatLines;

var XComGameState_Unit ThisUnitState;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local UIPanel StatLine;
	local int Index, OffsetX, OffsetY;
	local string color;

	super.InitScreen(InitController, InitMovie, InitName);

	Container = Spawn(class'UIPanel', self).InitPanel('theContainer');
	Container.Width = Width;
	Container.Height = Height;
	Container.SetPosition((Movie.UI_RES_X - Container.Width) / 2, (Movie.UI_RES_Y- Container.Height) / 2);
	
	FullBG = Spawn(class'UIBGBox', Container);
	FullBG.InitBG('', 0, 0, Container.Width, Container.Height);

	PanelBG = Spawn(class'UIBGBox', Container);
	PanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	PanelBG.InitBG('theBG', 0, 0, Container.Width, Container.Height);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_HP, class'XLocalizedData'.default.HealthLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Mobility, class'XLocalizedData'.default.MobilityLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Offense, class'XLocalizedData'.default.AimLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Will, class'XLocalizedData'.default.WillLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_ArmorMitigation, class'XLocalizedData'.default.ArmorLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Dodge, class'XLocalizedData'.default.DodgeLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Defense, class'XLocalizedData'.default.DefenseLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Hacking, class'XLocalizedData'.default.TechLabel);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_PsiOffense, class'XLocalizedData'.default.PsiOffenseLabel);
	StatLines.AddItem(StatLine);

	foreach StatLines(StatLine)
	{
		OffsetX = 40;
		OffsetY = 36;
		StatLine.SetPosition(OffsetX, OffsetX + (OffsetY * Index));
		//StatLine.SetSize(Container.Width * 0.8, Container.Height * 0.8 / StatLines.Length);

		color = "0x" $ rand(10) $ "A" $ rand(10) $ "B" $ rand(10) $ "F";
		//StatLine.SetColor(color);

		`LOG(self.class.name @ GetFuncName() @ StatLine @ "SetPosition" @ OffsetX @ OffsetY @ color,, 'RPG');
		Index++;
	}

	`LOG(self.class.name @ GetFuncName() @ "finished",, 'RPG');
}

defaultproperties
{
	Width=1200
	Height=800
}