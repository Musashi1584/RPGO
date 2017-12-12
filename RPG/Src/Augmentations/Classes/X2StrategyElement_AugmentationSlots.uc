class X2StrategyElement_AugmentationSlots extends CHItemSlotSet;

var localized string strAugmentationFirstLetter;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateAugmentationHeadSlotTemplate('AugmentationHead', eInvSlot_AugmentationHead));
	Templates.AddItem(CreateAugmentationHeadSlotTemplate('AugmentationTorso', eInvSlot_AugmentationTorso));
	Templates.AddItem(CreateAugmentationHeadSlotTemplate('AugmentationArms', eInvSlot_AugmentationArms));
	Templates.AddItem(CreateAugmentationHeadSlotTemplate('AugmentationLegs', eInvSlot_AugmentationLegs));
	return Templates;
}

static function X2DataTemplate CreateAugmentationHeadSlotTemplate(name TemplateName, EInventorySlot InventorySlot)
{
	local CHItemSlot Template;

	`CREATE_X2TEMPLATE(class'CHItemSlot', Template, TemplateName);

	Template.InvSlot = InventorySlot;
	// Unused for now
	Template.IsUserEquipSlot = true;
	// Uses unique rule
	Template.IsEquippedSlot = true;
	// Does not bypass unique rule
	Template.BypassesUniqueRule = false;
	Template.IsMultiItemSlot = false;
	Template.IsSmallSlot = false;

	Template.CanAddItemToSlotFn = CanAddItemToAugmentationSlot;
	Template.UnitHasSlotFn = HasAugmentationSlot;
	Template.GetPriorityFn = AugmentationGetPriority;
	Template.ShowItemInLockerListFn = ShowAugmentationItemInLockerList;
	Template.ValidateLoadoutFn = AugmentationValidateLoadout;
	Template.UnitShowSlotFn = UnitShowAugmentationSlot;

	return Template;
}

static function bool UnitShowAugmentationSlot(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return false;
}

static function bool CanAddItemToAugmentationSlot(CHItemSlot Slot, XComGameState_Unit Unit, X2ItemTemplate Template, optional XComGameState CheckGameState, optional int Quantity = 1, optional XComGameState_Item ItemState)
{
	local string strDummy;
	`log(GetFuncName() @ "called" @ Template.DataName @ Template.ItemCat,, 'Augmentations');
	if (!Slot.UnitHasSlot(Unit, strDummy, CheckGameState) || Unit.GetItemInSlot(Slot.InvSlot, CheckGameState) != none)
	{
		return false;
	}
	return Template.ItemCat == 'augmentation';
}

static function bool HasAugmentationSlot(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{
	`log(GetFuncName() @ "called",, 'Augmentations');
	// @TODO check if soldier is augmented
	return UnitState.IsSoldier() && !UnitState.IsRobotic();
}

static function int AugmentationGetPriority(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	`log(GetFuncName() @ "called",, 'Augmentations');
	return 120; // Ammo Pocket is 110 
}

static function bool ShowAugmentationItemInLockerList(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_Item ItemState, X2ItemTemplate ItemTemplate, XComGameState CheckGameState)
{
	return ItemTemplate.ItemCat == 'defense';
}

static function string GetAugmentationDisplayLetter(CHItemSlot Slot)
{
	`log(GetFuncName() @ "called",, 'Augmentations');
	return default.strAugmentationFirstLetter;
}

static function AugmentationValidateLoadout(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
	local XComGameState_Item EquippedAugmentation;
	local string strDummy;
	local bool HasSlot;
	EquippedAugmentation = Unit.GetItemInSlot(Slot.InvSlot, NewGameState);
	HasSlot = Slot.UnitHasSlot(Unit, strDummy, NewGameState);
	`log(GetFuncName() @ "called",, 'Augmentations');
	if(EquippedAugmentation == none && HasSlot)
	{
		//EquippedSecondaryWeapon = GetBestSecondaryWeapon(NewGameState);
		//AddItemToInventory(EquippedSecondaryWeapon, eInvSlot_SecondaryWeapon, NewGameState);
	}
	else if(EquippedAugmentation != none && !HasSlot)
	{
		EquippedAugmentation = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', EquippedAugmentation.ObjectID));
		Unit.RemoveItemFromInventory(EquippedAugmentation, NewGameState);
		XComHQ.PutItemInInventory(NewGameState, EquippedAugmentation);
		EquippedAugmentation = none;
	}

}

static function array<X2EquipmentTemplate> GetBestAugmentationTemplates()
{

}