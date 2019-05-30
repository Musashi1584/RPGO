class X2DownloadableContentInfo_RPGO_UI extends X2DownloadableContentInfo;

//exec function RPGO_DebugSpecListIcons(
//	int ItemHeight,
//	int IconSize,
//	int InitPosX,
//	int InitPosY,
//	int IconPadding,
//	string BGColor,
//	string FGColor
//)
//{
//	local UIChooseSpecializations UI;
//	local UIInventory_SpecializationListItem Item;
//	local int Index, IconIndex;
//
//	UI = UIChooseSpecializations(`SCREENSTACK.GetFirstInstanceOf(class'UIChooseSpecializations'));
//	for (Index = 0; Index < UI.PoolList.GetItemCount(); Index++)
//	{
//		Item = UIInventory_SpecializationListItem(UI.PoolList.GetItem(Index));
//		Item.SetHeight(ItemHeight);
//		Item.InitPosX = InitPosX;
//		Item.InitPosY = InitPosY;
//		Item.IconSize = IconSize;
//		Item.EDGE_PADDING = IconPadding;
//		Item.ConfirmButton.SetY(InitPosY);
//		Item.RealizeSpecializationsIcons();
//		for (IconIndex = 0; IconIndex < Item.SpecializationAbilityIcons.Length; IconIndex++)
//		{
//			Item.SpecializationAbilityIcons[IconIndex].SetBGColor(BGColor);
//			Item.SpecializationAbilityIcons[IconIndex].SetForegroundColor(FGColor);
//		}
//		//Item.PopulateData();
//		
//		//Item.RealizeLocation();
//		//Item.InitPanel();
//	}
//	UI.PoolList.RealizeItems();
//	UI.PoolList.RealizeList();
//}
