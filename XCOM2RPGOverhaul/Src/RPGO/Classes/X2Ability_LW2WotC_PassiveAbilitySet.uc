//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_LW2WotC_PassiveAbilitySet
//  PURPOSE: Defines ability templates for passive abilities
//--------------------------------------------------------------------------------------- 

class X2Ability_LW2WotC_PassiveAbilitySet extends XMBAbility config (LW_SoldierSkills);

var config int HEAT_WARHEADS_PIERCE;
var config int HEAT_WARHEADS_SHRED;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Sentinel());
	Templates.AddItem(HEATWarheads());

	return Templates;
}

// Perk name:		Sentinel
// Perk effect:		When in overwatch, you may take additional reaction shots.
// Localized text:	"When in overwatch, you may take <Ability:SENTINEL_LW_USES_PER_TURN/> reaction shots."
// Config:			(AbilityName="LW2WotC_Sentinel", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate Sentinel()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_LW2WotC_Sentinel			PersistentEffect;

	// Sentinel effect
	PersistentEffect = new class'X2Effect_LW2WotC_Sentinel';

	// Create the template using a helper function
	Template = Passive('LW2WotC_Sentinel', "img:///UILibrary_LW_PerkPack.LW_AbilitySentinel", false, PersistentEffect);
	Template.bIsPassive = false;

	return Template;
}

// Perk name:		HEAT Warheads
// Perk effect:		Your grenades now pierce and shred some armor.
// Localized text:	"Your grenades now pierce up to <Ability:HEAT_WARHEADS_PIERCE> points of armor and shred <Ability:HEAT_WARHEADS_SHRED> additional point of armor."
// Config:			(AbilityName="LW2WotC_HEATWarheads")
static function X2AbilityTemplate HEATWarheads()
{
	local X2Effect_LW2WotC_HEATGrenades			HEATEffect;

	// Effect granting bonus pierce and shred to grenades
	HEATEffect = new class 'X2Effect_LW2WotC_HEATGrenades';
	HEATEffect.Pierce = default.HEAT_WARHEADS_PIERCE;
	HEATEffect.Shred = default.HEAT_WARHEADS_SHRED;

	// Create the template using a helper function
	return Passive('LW2WotC_HEATWarheads', "img:///UILibrary_LW_PerkPack.LW_AbilityHEATWarheads", false, HEATEffect);
}
