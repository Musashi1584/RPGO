class UIArmory_Augmentations extends UIArmory_Loadout;

simulated function UpdateEquippedList()
{
	local UIArmory_LoadoutItem Item;
	local XComGameState_Unit UpdatedUnit;
	local int prevIndex;
	local CHUIItemSlotEnumerator En;
	

	prevIndex = EquippedList.SelectedIndex;
	UpdatedUnit = GetUnit();
	EquippedList.ClearItems();

	// Clear out tooltips from removed list items
	Movie.Pres.m_kTooltipMgr.RemoveTooltipsByPartialPath(string(EquippedList.MCPath));

	En = class'CHUIItemSlotEnumerator'.static.CreateEnumerator(UpdatedUnit, CheckGameState,,, class'X2Item_Augmentations'.default.AugmentationSlots);
	while (En.HasNext())
	{
		En.Next();

		`LOG(GetFuncName() @ En.Slot,, 'Augmentations');

		if (class'X2Item_Augmentations'.default.AugmentationSlots.Find(En.Slot) == INDEX_NONE)
		{
			continue;
		}

		Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
		if (CannotEditSlotsList.Find(En.Slot) != INDEX_NONE)
			Item.InitLoadoutItem(En.ItemState, En.Slot, true, m_strCannotEdit);
		else if (En.IsLocked)
			Item.InitLoadoutItem(En.ItemState, En.Slot, true, En.LockedReason);
		else
			Item.InitLoadoutItem(En.ItemState, En.Slot, true);
	}
	EquippedList.SetSelectedIndex(prevIndex < EquippedList.ItemCount ? prevIndex : 0);
	// Force item into view
	EquippedList.NavigatorSelectionChanged(EquippedList.SelectedIndex);
}

simulated function bool ShowInLockerList(XComGameState_Item Item, EInventorySlot SelectedSlot)
{
	local X2ItemTemplate ItemTemplate;
	local int Index;

	ItemTemplate = Item.GetMyTemplate();
	
	if(MeetsAllStrategyRequirements(ItemTemplate.ArmoryDisplayRequirements) && MeetsDisplayRequirement(ItemTemplate))
	{
		Index = class'X2Item_Augmentations'.default.SlotConfig.Find('InvSlot', SelectedSlot);

		if (Index != INDEX_NONE)
		{
			`LOG(GetFuncName() @ ItemTemplate.DataName @ ItemTemplate.ItemCat @ ItemTemplate.ItemCat == class'X2Item_Augmentations'.default.SlotConfig[Index].Category,, 'Augmentation');
			return ItemTemplate.ItemCat == class'X2Item_Augmentations'.default.SlotConfig[Index].Category;
		}
	}

	return false;
}


simulated function OnItemClicked(UIList ContainerList, int ItemIndex)
{
	super.OnItemClicked(ContainerList, ItemIndex);
	`LOG(GetFuncName(),, 'Augmentations');
	UpdateData(true);
}