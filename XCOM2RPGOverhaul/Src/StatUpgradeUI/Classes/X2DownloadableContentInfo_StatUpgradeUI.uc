class X2DownloadableContentInfo_StatUpgradeUI extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	class'StatUIHelper'.static.OnPostCharacterTemplatesCreated();
}


//exec function StatUIDebugHeader(
//	int StatNameHeaderWidth,
//	int StatValueHeaderWidth,
//	int UpgradePointsHeaderWidth,
//	int StatCostHeaderWidth,
//	int UpgradeCostHeaderWidth
//)
//{
//	local UIScreen_StatUI UI;
//	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));
//	UI.InitStatHeaders();
//}

exec function StatUIScreenSet(int X, int Y, int Width, int Height)
{
	local UIScreen_StatUI UI;

	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));

	//UI.SetSize(Width, Height);
	UI.Container.SetSize(Width, Height);
	UI.Container.SetPosition(X, Y);

	UI.FullBG.SetSize(Width, Height);
	UI.PanelBG.SetSize(Width, Height);
}

// 270 100 120 120 120 300
exec function StatUITest(
	optional int StatNameWidth = 150,
	optional int StatValueTextWidth = 80,
	optional int UpgradePointsWidth = 60,
	optional int StatCostTextWidth = 100,
	optional int UpgradeCostSumWidth = 120,
	optional int ButtonOffset = 150)
{
	local XComHQPresentationLayer HQPres;
	local UIScreen_StatUI UI;
	local StateObjectReference UnitRef;
	
	HQPres = `HQPRES;

	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));
	UnitRef = UI.GetUnitRef();
	UI.OnCancel();

	UI = UIScreen_StatUI(HQPres.ScreenStack.Push(HQPres.Spawn(class'UIScreen_StatUI', HQPres), HQPres.Get3DMovie()));

	UI.StatNameHeaderWidth = StatNameWidth;
	UI.StatValueHeaderWidth = StatValueTextWidth;
	UI.UpgradePointsHeaderWidth = UpgradePointsWidth;
	UI.StatCostHeaderWidth = StatCostTextWidth;
	UI.UpgradeCostHeaderWidth = UpgradeCostSumWidth;
	UI.ButtonOffset = ButtonOffset;

	UI.InitArmory(UnitRef);
}

// Testing non linear stat progression
//static event OnPostTemplatesCreated()
//{
//	local int i;
//	local float div, f, res;
//
//	for (i=0;i<=150;i++)
//	{
//		f = float(i) / float(100);
//		res = Exp(Pow(f, 6)) * 3;
//		`LOG(GetFuncName() @ i @ res @ int(res + 0.5f),, 'RPG');
//	}
//}
//
//static function float Pow(Float Base, int Exponent)
//{
//	local int i;
//	local float Result;
//	
//	Result = Base;
//	
//	for(i=1; i <= Exponent; i++)
//	{
//		Result *= Base;
//	}
//	return Result;
//}