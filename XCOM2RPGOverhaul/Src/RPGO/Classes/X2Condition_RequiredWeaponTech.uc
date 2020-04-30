class X2Condition_RequiredWeaponTech extends X2Condition;

var EInventorySlot RelevantSlot;
var name ExcludeWeaponTech;
var name RequireWeaponTech;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Item	RelevantItem;
	local XComGameState_Unit	SourceUnit;
	local X2WeaponTemplate		WeaponTemplate;

	SourceUnit = XComGameState_Unit(kSource);
	if (SourceUnit == none)
		return 'AA_NotAUnit';

	RelevantItem = SourceUnit.GetItemInSlot(RelevantSlot);
	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if (ExcludeWeaponTech != '')
	{		
		if (WeaponTemplate != none && WeaponTemplate.WeaponTech == ExcludeWeaponTech)
			return 'AA_WeaponIncompatible';
	}
	if (RequireWeaponTech != '')
	{
		if (RelevantItem == none || X2WeaponTemplate(RelevantItem.GetMyTemplate()).WeaponTech != RequireWeaponTech)
			return 'AA_WeaponIncompatible';
	}

	return 'AA_Success';
}