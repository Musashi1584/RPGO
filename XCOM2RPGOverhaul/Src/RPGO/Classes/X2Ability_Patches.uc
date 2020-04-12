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
	Templates.AddItem(HeavyWeaponMobilityCap());
	Templates.AddItem(PistolDamageModifierRange());
	Templates.AddItem(ShotgunDamageModifierRange());
	Templates.AddItem(ShotgunDamageModifierCoverType());
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

	Template.IconImage = "img:///UILibrary_RPG.UIPerk_Kenjutsu";
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

static function X2AbilityTemplate HeavyWeaponMobilityCap()
{
	local X2AbilityTemplate Template;
	local X2Effect_EquipmentStatCaps CapStatEffect;
	local EquipmentStatCap EquipmentCap;
	local int Index;

	Template = PurePassive('HeavyWeaponMobilityPenalty', "Texture2D'UILibrary_RPG.UIPerk_HeavyWeapon'", false, 'eAbilitySource_Perk', false);

	CapStatEffect = new class'X2Effect_EquipmentStatCaps';
	CapStatEffect.BuildPersistentEffect(1, true, true, false, eGameRule_TacticalGameStart);
	CapStatEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	CapStatEffect.EffectName = 'CapStatEffectRegular';
	CapStatEffect.bUseMaxCap = true;

	foreach default.HEAVYWEAPON_STAT_CAPS(EquipmentCap, Index)
	{	
		default.HEAVYWEAPON_STAT_CAPS[Index].Cap.StatCapValue = class'RPGOAbilityConfigManager'.static.GetConfigIntValue(EquipmentCap.ValueConfigKey);
		CapStatEffect.EquipmentStatCaps.AddItem(default.HEAVYWEAPON_STAT_CAPS[Index]);
	}
	
	Template.AddTargetEffect(CapStatEffect);
	return Template;
}

static function X2AbilityTemplate StationaryCannonDamageBonus()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local X2Effect_RemoveEffectAfterMove RemoveEffectAfterMoveEffect;
	
	Template = PurePassive('StationaryCannonDamageBonus', "", false, 'eAbilitySource_Perk', false);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Effect.AddPercentDamageModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("CANNON_STATIONARY_DAMAGE_PCT_BONUS"), eHit_Success);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
	Effect.EffectName = 'StationaryCannonDamageBonus';
	Template.AddTargetEffect(Effect);

	RemoveEffectAfterMoveEffect = new class'X2Effect_RemoveEffectAfterMove';
	RemoveEffectAfterMoveEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	RemoveEffectAfterMoveEffect.EffectsToRemove.AddItem('StationaryCannonDamageBonus');
	Template.AddTargetEffect(RemoveEffectAfterMoveEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;
	
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
	RangeEffect.DamageFalloff =  class'RPGOAbilityConfigManager'.static.GetConfigIntArray("PISTOL_DAMAGE_FALLOFF");

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
	RangeEffect.DamageFalloff =  class'RPGOAbilityConfigManager'.static.GetConfigIntArray("SHOTGUN_DAMAGE_FALLOFF");

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
	CoverTypeEffect.HalfCovertModifier = class'RPGOAbilityConfigManager'.static.GetConfigFloatValue("SHOTGUN_DAMAGE_HALFCOVERTMODIFIER");
	CoverTypeEffect.FullCovertModifier = class'RPGOAbilityConfigManager'.static.GetConfigFloatValue("SHOTGUN_DAMAGE_FULLCOVERTMODIFIER");

	Template.AddTargetEffect(CoverTypeEffect);

	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;

	return Template;
}

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
