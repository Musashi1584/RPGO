class X2DownloadableContentInfo_StatUpgradeUI extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	class'StatUIHelper'.static.OnPostCharacterTemplatesCreated();
}

exec function DebugStatUIHeader(
	int StatNameHeaderWidth,
	int StatValueHeaderWidth,
	int UpgradePointsHeaderWidth,
	int StatCostHeaderWidth,
	int UpgradeCostHeaderWidth
)
{
	local UIScreen_StatUI UI;
	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));
	UI.InitStatHeaders(StatNameHeaderWidth, StatValueHeaderWidth, UpgradePointsHeaderWidth, StatCostHeaderWidth, UpgradeCostHeaderWidth);
}

exec function DebugStatUI(
	int OffsetY = 100,
	int RowHeight = 30,
	int StatNameWidth = 260,
	int StatValueTextWidth = 100,
	int UpgradePointsWidth = 100,
	int ButtonWidth = 150,
	int StatCostTextWidth = 200,
	int UpgradeCostSumWidth = 140)
{
	local UIScreen_StatUI UI;
	local UIPanel_StatUI_StatLine StatLine;
	local int Index, OffsetX;

	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));
	
	Index = 0;
	foreach UI.StatLines(StatLine)
	{
		OffsetX = 40;
		StatLine.InitChildPanels(UI.MCName, StatNameWidth, StatValueTextWidth, UpgradePointsWidth, ButtonWidth, StatCostTextWidth, UpgradeCostSumWidth);
		StatLine.SetPosition(OffsetX, OffsetY + (RowHeight * Index));
		
		`LOG(self.class.name @ GetFuncName() @ StatLine.MCName, , 'RPG');
		Index++;
	}
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