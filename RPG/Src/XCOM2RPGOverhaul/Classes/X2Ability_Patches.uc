class X2Ability_Patches extends XMBAbility config (RPG);

var config int HEAVY_WEAPON_MOBILITY_PENALTY;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(HeavyWeaponMobilityPenalty());
	Templates.AddItem(CombatProtocolHackingBonus());
	Templates.AddItem(ShotgunDamageModifierRange());
	Templates.AddItem(ShotgunDamageModifierCoverType());
	Templates.AddItem(AutoFireOverwatch());
	Templates.AddItem(AutoFireShot());
	Templates.AddItem(RemoveSquadSightOnMove());

	return Templates;
}

static function X2AbilityTemplate HeavyWeaponMobilityPenalty()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Template = PurePassive('HeavyWeaponMobilityPenalty', "Texture2D'UILibrary_RPG.UIPerk_HeavyWeapon'", false, 'eAbilitySource_Perk', false);

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Mobility, default.HEAVY_WEAPON_MOBILITY_PENALTY);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.HEAVY_WEAPON_MOBILITY_PENALTY);
	Template.AddTargetEffect(Effect);

	return Template;
}

static function X2AbilityTemplate CombatProtocolHackingBonus()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Hacking, 50);
	
	Template = Passive('CombatProtocolHackingBonus', "img:///Texture2D'UILibrary_RPG.UIPerk_HackingBonus'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HackingSoldierLabel, eStat_Hacking, 50);
	
	return Template;
}

static function X2AbilityTemplate ShotgunDamageModifierRange()
{
	local X2AbilityTemplate Template;
	local X2Effect_ShotgunDamageModifierRange RangeEffect;
	
	Template = PurePassive('ShotgunDamageModifierRange', "", false, 'eAbilitySource_Perk', false);

	RangeEffect = new class'X2Effect_ShotgunDamageModifierRange';
	RangeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	RangeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);

	Template.AddTargetEffect(RangeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

static function X2AbilityTemplate ShotgunDamageModifierCoverType()
{
	local X2AbilityTemplate Template;
	local X2Effect_ShotgunDamageModifierCoverType CoverTypeEffect;
	
	Template = PurePassive('ShotgunDamageModifierCoverType', "", false, 'eAbilitySource_Perk', false);

	CoverTypeEffect = new class'X2Effect_ShotgunDamageModifierCoverType';
	CoverTypeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	CoverTypeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);

	Template.AddTargetEffect(CoverTypeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

static function X2AbilityTemplate AutoFireShot()
{
	local X2AbilityTemplate Template;
	local X2Effect_ApplyDirectionalWorldDamage  WorldDamage;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('AutoFireShot');
	//Template.IconImage = "img:///UILibrary_RPG.UIPerk_CannonShot";

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = false;
	WorldDamage.EnvironmentalDamageAmount = 30;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = true;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
	WorldDamage.PlusNumZTiles = 1;
	WorldDamage.bHitTargetTile = true;
	Template.AddTargetEffect(WorldDamage);

	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).iNumPoints = 2;
	Template.OverrideAbilities.AddItem('StandardShot');

	return Template;
}

static function X2AbilityTemplate AutoFireOverwatch()
{
	local X2AbilityTemplate Template;

	Template = class'X2Ability_DefaultAbilitySet'.static.AddOverwatchAbility('AutoFireOverwatch');
	//Template.IconImage = "img:///UILibrary_RPG.UIPerk_CannonOverwatch";

	X2AbilityCost_ActionPoints(Template.AbilityCosts[1]).iNumPoints = 2;
	Template.OverrideAbilities.AddItem('Overwatch');

	return Template;
}



static function X2AbilityTemplate RemoveSquadSightOnMove()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener EventTrigger;
	local X2Effect_RemoveEffects RemoveEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RemoveSquadSightOnMove');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'UnitMoveFinished';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem('Squadsight');
	Template.AddTargetEffect(RemoveEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}