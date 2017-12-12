class UIArmory_Augmentations extends UIArmory_Loadout;

var protected array<EInventorySlot> AugmentationSlots;

simulated function UpdateEquippedList()
{
	local int i, numUtilityItems;
	local UIArmory_LoadoutItem Item;
	local array<XComGameState_Item> UtilityItems;
	local XComGameState_Unit UpdatedUnit;
	local int prevIndex;
	local CHUIItemSlotEnumerator En;
	

	prevIndex = EquippedList.SelectedIndex;
	UpdatedUnit = GetUnit();
	EquippedList.ClearItems();

	// Clear out tooltips from removed list items
	Movie.Pres.m_kTooltipMgr.RemoveTooltipsByPartialPath(string(EquippedList.MCPath));

	AugmentationSlots.Length = 0;
	AugmentationSlots.AddItem(eInvSlot_AugmentationHead);
	AugmentationSlots.AddItem(eInvSlot_AugmentationTorso);
	AugmentationSlots.AddItem(eInvSlot_AugmentationArms);
	AugmentationSlots.AddItem(eInvSlot_AugmentationLegs);

	En = class'CHUIItemSlotEnumerator'.static.CreateEnumerator(UpdatedUnit, CheckGameState,,,AugmentationSlots);
	while (En.HasNext())
	{
		En.Next();

		`LOG(GetFuncName() @ En.Slot,, 'Augmentations');

		if (AugmentationSlots.Find(En.Slot) == INDEX_NONE)
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

	ItemTemplate = Item.GetMyTemplate();
	
	if(MeetsAllStrategyRequirements(ItemTemplate.ArmoryDisplayRequirements) && MeetsDisplayRequirement(ItemTemplate))
	{
		return AugmentationSlots.Find(SelectedSlot) != INDEX_NONE && ItemTemplate.ItemCat == 'augmentation';
	}

	return false;
}