class X2Condition_WeaponCategory extends X2Condition;

var() array<name> MatchWeaponCategories;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	
	SourceWeapon = kAbility.GetSourceWeapon();
	if (SourceWeapon != none)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (MatchWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE)
		{
			return 'AA_Success';
		}
	}

	return 'AA_WeaponIncompatible';
}