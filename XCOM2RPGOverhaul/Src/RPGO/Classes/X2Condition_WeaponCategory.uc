class X2Condition_WeaponCategory extends X2Condition;

var() array<name> IncludeWeaponCategories;
var() array<name> ExcludeWeaponCategories;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	
	SourceWeapon = kAbility.GetSourceWeapon();
	if (SourceWeapon != none)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (IncludeWeaponCategories.Length > 0 && IncludeWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE)
		{
			return 'AA_Success';
		}

		if (ExcludeWeaponCategories.Length > 0 && ExcludeWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE)
		{
			return 'AA_WeaponIncompatible';
		}
	}

	return 'AA_WeaponIncompatible';
}

//function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
//{
//	local array<XComGameState_Item> InventoryItems;
//	local XComGameState_Item ItemState;
//	local X2WeaponTemplate WeaponTemplate;
//
//	if (IncludeWeaponCategories.Length == 0)
//	{
//		return true;
//	}
//
//	InventoryItems = SourceUnit.GetAllInventoryItems();
//
//	foreach InventoryItems(ItemState)
//	{
//		WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
//
//		if (WeaponTemplate == none)
//		{
//			continue;
//		}
//
//		if (IncludeWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE)
//		{
//			//`LOG(self.Class.Name @ GetFuncName() @ kAbility.GetMyTemplateName() @ "IncludeWeaponCategories matches" @ WeaponTemplate.WeaponCat,, 'RPG');
//			return true;
//		}
//	}
//
//	return false;
//}