class X2DownloadableContentInfo_StatUpgradeUI extends X2DownloadableContentInfo;

exec function DebugStatUI(
	int OffsetY = 100,
	int RowHeight = 30,
	int StatNameWidth = 260,
	int StatValueTextWidth = 100,
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
		StatLine.InitChildPanels(UI.MCName, StatNameWidth, StatValueTextWidth, ButtonWidth, StatCostTextWidth, UpgradeCostSumWidth);
		StatLine.SetPosition(OffsetX, OffsetY + (RowHeight * Index));
		
		`LOG(self.class.name @ GetFuncName() @ StatLine.MCName, , 'RPG');
		Index++;
	}
}
