class X2Condition_ArcthrowerAbilities extends X2Condition config (RPG);

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local name						AbilityName;
	local XComGameState_Item		SourceWeapon;
	local array<name>				ValidArcthrowerAbilities;

	if(kAbility == none)
		return 'AA_InvalidAbilityName';

	ValidArcthrowerAbilities = class'Config_Manager'.static.GetConfigNameArray("ARCTHROWER_ABILITIES");

	SourceWeapon = kAbility.GetSourceWeapon();
	AbilityName = kAbility.GetMyTemplateName();

	if (SourceWeapon == none)
		return 'AA_InvalidAbilityName';

	if (ValidArcthrowerAbilities.Find(AbilityName) != INDEX_NONE)
		return 'AA_Success';

	return 'AA_InvalidAbilityName';
}