class X2Ability_Patches extends XMBAbility config (RPG);

var config array<EquipmentStatCap> HEAVYWEAPON_STAT_CAPS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(BullpupReturnFire());
	Templates.AddItem(ShotgunDamageModifierCoverType());
	Templates.AddItem(BullpupDesign());
	Templates.AddItem(PurePassive('QuickDrawNew', "img:///UILibrary_PerkIcons.UIPerk_quickdraw"));
	Templates.AddItem(RpgDeathFromAbove());
	Templates.AddItem(BlueMoveSlash());
	Templates.AddItem(HeavyWeaponMobilityPenalty());
	Templates.AddItem(PistolDamageModifierRange());
	Templates.AddItem(ShotgunDamageModifierRange());
	Templates.AddItem(ShotgunDamageModifierCoverType());
	Templates.AddItem(SawedOffShotgunDamageModifierCovertype());
	Templates.AddItem(SawedOffShotgunDamageModifierRange ('SawedOffShotgunDamageModifierRange_CV', class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatArray("SAWEDOFF_SHOTGUN_DAMAGE_FALLOFF_CV")));
	Templates.AddItem(SawedOffShotgunDamageModifierRange ('SawedOffShotgunDamageModifierRange_MG', class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatArray("SAWEDOFF_SHOTGUN_DAMAGE_FALLOFF_MG")));
	Templates.AddItem(SawedOffShotgunDamageModifierRange ('SawedOffShotgunDamageModifierRange_BM', class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatArray("SAWEDOFF_SHOTGUN_DAMAGE_FALLOFF_BM")));
	//Templates.AddItem(DamageModifierCoverType());
	//Templates.AddItem(AutoFireOverwatch());
	//Templates.AddItem(AutoFireShot());
	Templates.AddItem(RemoveSquadSightOnMove());

	return Templates;
}

static function X2AbilityTemplate BullpupReturnFire()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ReserveActionPoints	ReserveActionPoints;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BullpupReturnFire');
	class'X2Ability_DefaultAbilitySet'.static.PistolOverwatchShotHelper(Template);

	ReserveActionPoints = GetAbilityReserveCostActionPoints(Template);
	ReserveActionPoints.AllowedTypes.Length = 0;
	ReserveActionPoints.AllowedTypes.AddItem('SkirmisherReturnFireActionPoint');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_returnfire";
	Template.bShowPostActivation = TRUE;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

static function X2AbilityTemplate BullpupDesign()
{
	local X2AbilityTemplate							Template;
	local X2Effect_ConditionalModifyReactionFire	ReactionFire;
	local X2Effect_ConditionalSetUnitValue			UnitValueEffect;

	ReactionFire = new class'X2Effect_ConditionalModifyReactionFire';
	ReactionFire.bAllowCrit = true;
	ReactionFire.ReactionModifier = 0;
	ReactionFire.BuildPersistentEffect(1, true, true, true);
	ReactionFire.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	UnitValueEffect = new class'X2Effect_ConditionalSetUnitValue';
	UnitValueEffect.UnitName = class'X2Ability_DefaultAbilitySet'.default.ConcealedOverwatchTurn;
	UnitValueEffect.CleanupType = eCleanup_BeginTurn;
	UnitValueEffect.NewValueToSet = 1;
	UnitValueEffect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	Template = Passive('BullpupDesign', "img:///UILibrary_PerkIcons.UIPerk_coolpressure", false, ReactionFire);

	AddSecondaryEffect(Template, UnitValueEffect);

	return Template;
}

static function X2AbilityTemplate RpgDeathFromAbove()
{
	local X2Effect_DeathFromAboveRPG Effect;
	
	// Create an effect that will refund the cost of attacks
	Effect = new class'X2Effect_DeathFromAboveRPG';
	Effect.EffectName = 'RpgDeathFromAbove';

	// Create the template using a helper function
	return Passive('RpgDeathFromAbove', "img:///UILibrary_PerkIcons.UIPerk_DeathFromAbove", false, Effect);
}

static function X2AbilityTemplate BlueMoveSlash()
{
	local X2AbilityTemplate Template;
	local X2Effect_BlueMoveSlash		BlueMoveSlash;
	local XMBCondition_SourceAbilities	RequiredAbilitiesCondition;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'BlueMoveSlash');

	Template.IconImage = "img:///UILibrary_RPGO.UIPerk_Kenjutsu";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.bCrossClassEligible = false;

	RequiredAbilitiesCondition = new class'XMBCondition_SourceAbilities';
	RequiredAbilitiesCondition.AddRequireAbility('Kenjutsu', 'AA_AbilityRequired');
	
	BlueMoveSlash = new class'X2Effect_BlueMoveSlash';
	BlueMoveSlash.BuildPersistentEffect(1, true, false, true);
	BlueMoveSlash.TargetConditions.AddItem(RequiredAbilitiesCondition);
	Template.AddTargetEffect(BlueMoveSlash);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

//static function X2AbilityTemplate HeavyWeaponMobilityPenalty()
//{
//	local X2AbilityTemplate Template;
//	local XMBEffect_ConditionalStatChange Effect;
//	local XMBCondition_SourceAbilities	SourceAbilitiesCondition;
//
//	Template = PurePassive('HeavyWeaponMobilityPenalty', "Texture2D'UILibrary_RPGO.UIPerk_HeavyWeapon'", false, 'eAbilitySource_Perk', false);
//
//	SourceAbilitiesCondition = new class'XMBCondition_SourceAbilities';
//	SourceAbilitiesCondition.AddExcludeAbility('SyntheticLegMuscles', 'AA_AbilityNotAllowed');
//
//	Effect = new class'XMBEffect_ConditionalStatChange';
//	Effect.AddPersistentStatChange(eStat_Mobility,class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("HEAVY_WEAPON_MOBILITY_SCALAR"), MODOP_PostMultiplication);
//	Effect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
//	Effect.TargetConditions.AddItem(SourceAbilitiesCondition);
//
//	Template.AddTargetEffect(Effect);
//
//	SourceAbilitiesCondition = new class'XMBCondition_SourceAbilities';
//	SourceAbilitiesCondition.AddRequireAbility('SyntheticLegMuscles', 'AA_AbilityRequired');
//
//	Effect = new class'XMBEffect_ConditionalStatChange';
//	Effect.AddPersistentStatChange(eStat_Mobility, class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("HEAVY_WEAPON_MOBILITY_SCALAR_REDUCED"), MODOP_PostMultiplication);
//	Effect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
//	Effect.TargetConditions.AddItem(SourceAbilitiesCondition);
//
//
//	//Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.HEAVY_WEAPON_MOBILITY_SCALAR);
//	Template.AddTargetEffect(Effect);
//
//	return Template;
//}


static function X2AbilityTemplate HeavyWeaponMobilityPenalty()
{
	local X2AbilityTemplate Template;
	local X2Effect_EquipmentStatCaps CapStatEffect;
	local EquipmentStatCap EquipmentCap;
	local int Index;

	Template = PurePassive('HeavyWeaponMobilityPenalty', "Texture2D'UILibrary_RPGO.UIPerk_HeavyWeapon'", false, 'eAbilitySource_Perk', false);

	CapStatEffect = new class'X2Effect_EquipmentStatCaps';
	CapStatEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	CapStatEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	CapStatEffect.EffectName = 'CapStatEffectRegular';
	CapStatEffect.bUseMaxCap = true;

	foreach default.HEAVYWEAPON_STAT_CAPS(EquipmentCap, Index)
	{	
		default.HEAVYWEAPON_STAT_CAPS[Index].Cap.StatCapValue = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue(EquipmentCap.ValueConfigKey);
		CapStatEffect.EquipmentStatCaps.AddItem(default.HEAVYWEAPON_STAT_CAPS[Index]);
	}
	
	Template.AddTargetEffect(CapStatEffect);
	return Template;
}

static function X2AbilityTemplate PistolDamageModifierRange()
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageModifierRange RangeEffect;
	
	Template = PurePassive('PistolDamageModifierRange', "", false, 'eAbilitySource_Perk', false);

	RangeEffect = new class'X2Effect_DamageModifierRange';
	RangeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	RangeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
	RangeEffect.DamageFalloff =  class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntArray("PISTOL_DAMAGE_FALLOFF");
	//RangeEffect.AbilityIgnoreDamageFalloff =  class'RPGO_Helper'.static.GetAbilityConfig().GetConfigNameArray("PISTOL_DAMAGE_ABILITY_IGNORE_DAMAGE_FALLOFF");

	Template.AddTargetEffect(RangeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

static function X2AbilityTemplate ShotgunDamageModifierRange()
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageModifierRange RangeEffect;
	
	Template = PurePassive('ShotgunDamageModifierRange', "", false, 'eAbilitySource_Perk', false);

	RangeEffect = new class'X2Effect_DamageModifierRange';
	RangeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	RangeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
	RangeEffect.DamageFalloff =  class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntArray("SHOTGUN_DAMAGE_FALLOFF");

	Template.AddTargetEffect(RangeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

static function X2AbilityTemplate ShotgunDamageModifierCoverType()
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageModifierCoverType CoverTypeEffect;
	
	Template = PurePassive('ShotgunDamageModifierCoverType', "", false, 'eAbilitySource_Perk', false);

	CoverTypeEffect = new class'X2Effect_DamageModifierCoverType';
	CoverTypeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	CoverTypeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
	CoverTypeEffect.HalfCovertModifier = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("SHOTGUN_DAMAGE_HALFCOVERTMODIFIER");
	CoverTypeEffect.FullCovertModifier = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("SHOTGUN_DAMAGE_FULLCOVERTMODIFIER");

	Template.AddTargetEffect(CoverTypeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

static function X2AbilityTemplate SawedOffShotgunDamageModifierCovertype()
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageModifierCoverType CoverTypeEffect;
	
	Template = PurePassive('SawedOffShotgunDamageModifierCovertype', "", false, 'eAbilitySource_Perk', false);

	CoverTypeEffect = new class'X2Effect_DamageModifierCoverType';
	CoverTypeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	CoverTypeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
	CoverTypeEffect.HalfCovertModifier = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("SAWEDOFF_SHOTGUN_DAMAGE_HALFCOVERTMODIFIER");
	CoverTypeEffect.FullCovertModifier = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("SAWEDOFF_SHOTGUN_DAMAGE_FULLCOVERTMODIFIER");

	Template.AddTargetEffect(CoverTypeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

static function X2AbilityTemplate SawedOffShotgunDamageModifierRange(name TemplateName, array<float> DamageFalloff)
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageModifierRangePercentage RangeEffect;
	
	Template = PurePassive(TemplateName, "", false, 'eAbilitySource_Perk', false);

	RangeEffect = new class'X2Effect_DamageModifierRangePercentage';
	RangeEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	RangeEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
	RangeEffect.DamageFalloff = DamageFalloff;

	Template.AddTargetEffect(RangeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}


//static function X2AbilityTemplate DamageModifierCoverType()
//{
//	local X2AbilityTemplate Template;
//	local X2Effect_DamageModifierCoverType DamageModifierCoverType;
//	
//	Template = PurePassive('DamageModifierCoverType', "", false, 'eAbilitySource_Perk', false);
//
//	DamageModifierCoverType = new class'X2Effect_DamageModifierCoverType';
//	DamageModifierCoverType.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
//	DamageModifierCoverType.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
//
//	Template.AddTargetEffect(DamageModifierCoverType);
//
//	Template.bDisplayInUITacticalText = false;
//	Template.bDisplayInUITooltip = false;
//	Template.bUniqueSource = true;
//
//	return Template;
//}

//static function X2AbilityTemplate AutoFireShot()
//{
//	local X2AbilityTemplate Template;
//	local X2Effect_ApplyDirectionalWorldDamage  WorldDamage;
//
//	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('AutoFireShot');
//	//Template.IconImage = "img:///UILibrary_RPGO.UIPerk_CannonShot";
//
//	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
//	WorldDamage.bUseWeaponDamageType = true;
//	WorldDamage.bUseWeaponEnvironmentalDamage = false;
//	WorldDamage.EnvironmentalDamageAmount = 30;
//	WorldDamage.bApplyOnHit = true;
//	WorldDamage.bApplyOnMiss = true;
//	WorldDamage.bApplyToWorldOnHit = true;
//	WorldDamage.bApplyToWorldOnMiss = true;
//	WorldDamage.bHitAdjacentDestructibles = true;
//	WorldDamage.PlusNumZTiles = 1;
//	WorldDamage.bHitTargetTile = true;
//	Template.AddTargetEffect(WorldDamage);
//
//	GetAbilityCostActionPoints(Template).iNumPoints = 2;
//	Template.OverrideAbilities.AddItem('StandardShot');
//
//	return Template;
//}
//
//static function X2AbilityTemplate AutoFireOverwatch()
//{
//	local X2AbilityTemplate Template;
//
//	Template = class'X2Ability_DefaultAbilitySet'.static.AddOverwatchAbility('AutoFireOverwatch');
//	//Template.IconImage = "img:///UILibrary_RPGO.UIPerk_CannonOverwatch";
//
//	GetAbilityCostActionPoints(Template).iNumPoints = 2;
//	Template.OverrideAbilities.AddItem('Overwatch');
//
//	return Template;
//}



static function X2AbilityTemplate RemoveSquadSightOnMove()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener EventTrigger;
	local X2Effect_RemoveEffects RemoveEffect;
	local XMBCondition_SourceAbilities ExcludeAbilities;

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

	ExcludeAbilities = new class'XMBCondition_SourceAbilities';
	ExcludeAbilities.AddExcludeAbility('SniperElite', 'AA_ExcludeAbility');

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem('Squadsight');
	RemoveEffect.TargetConditions.AddItem(ExcludeAbilities);
	Template.AddTargetEffect(RemoveEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}

private static function X2AbilityCost_ActionPoints GetAbilityCostActionPoints(X2AbilityTemplate Template)
{
	local X2AbilityCost Cost;
	foreach Template.AbilityCosts(Cost)
	{
		if (X2AbilityCost_ActionPoints(Cost) != none)
		{
			return X2AbilityCost_ActionPoints(Cost);
		}
	}
	return none;
}

static function X2AbilityCost_ReserveActionPoints GetAbilityReserveCostActionPoints(X2AbilityTemplate Template)
{
	local X2AbilityCost Cost;
	foreach Template.AbilityCosts(Cost)
	{
		if (X2AbilityCost_ReserveActionPoints(Cost) != none)
		{
			return X2AbilityCost_ReserveActionPoints(Cost);
		}
	}
	return none;
}
