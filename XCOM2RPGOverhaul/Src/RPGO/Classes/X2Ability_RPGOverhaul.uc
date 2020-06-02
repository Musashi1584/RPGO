class X2Ability_RPGOverhaul extends XMBAbility;

var localized string SuppressionTargetEffectDesc;
var localized string SuppressionSourceEffectDesc;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// Random Starting Abilities
	Templates.AddItem(XenoBiologist());
	Templates.AddItem(Scout());
	Templates.AddItem(DamnGoodGround());
	Templates.AddItem(Panoptic());
	Templates.AddItem(Hitman());
	Templates.AddItem(Prodigy());
	Templates.AddItem(Bulletproof());
	Templates.AddItem(Juggernaut());
	Templates.AddItem(Stalker());
	Templates.AddItem(IronWill());
	Templates.AddItem(CyberAdept());
	Templates.AddItem(MovingTarget());
	Templates.AddItem(Praetorian());
	Templates.AddItem(HotShot());
	Templates.AddItem(EagleEye());
	Templates.AddItem(Runner());
	Templates.AddItem(SyntheticGenes());
	
	// Class abilities
	Templates.AddItem(Spray());
	Templates.AddItem(Quartermaster());
	Templates.AddItem(RpgZoneOfControl());
	Templates.AddItem(ZoneOfControlReturnFire());
	Templates.AddItem(DangerSense());
	Templates.AddItem(DangerSenseTrigger());
	Templates.AddItem(DangerSenseSpawnTrigger());
	Templates.AddItem(StealthTactics());
	Templates.AddItem(Relocation());
	Templates.AddItem(PurePassive('Grenadier', "img:///UILibrary_RPG.LW_AbilityFullKit"));
	Templates.AddItem(HighNoon());
	Templates.AddItem(Sabotage());
	Templates.AddItem(Overkill());
	Templates.AddItem(Rocketeer());
	Templates.AddItem(FullAutoFire());
	Templates.AddItem(AutoFireModifications());
	Templates.AddItem(SurgicalPrecision());
	Templates.AddItem(PurePassive('Gunner', "img:///UILibrary_RPG.UIPerk_Gunner"));
	Templates.AddItem(ReadyForAnything());
	Templates.AddItem(ReadyForAnythingFlyover());
	Templates.AddItem(DeadeyeAbility());
	Templates.AddItem(KillEmAll());
	Templates.AddItem(SniperElite());
	Templates.AddItem(PurePassive('PermanentTracking', "img:///UILibrary_RPG.UIPerk_PermanentTracking"));
	Templates.AddItem(PurePassive('Kenjutsu', "img:///UILibrary_RPG.UIPerk_Kenjutsu"));
	Templates.AddItem(PurePassive('EmergencyProtocol', "img:///UILibrary_RPG.UIPerk_EmergencyProtocol"));
	Templates.AddItem(TriggerHappy());
	Templates.AddItem(TriggerHappyScamperShot());
	Templates.AddItem(SpotWeakness());

	return Templates;
}

static function X2AbilityTemplate XenoBiologist()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("XENO_BIOLOGIST_DMG_BONUS"));
	Effect.AbilityTargetConditions.AddItem(new class 'X2Condition_TargetAutopsy');
	Effect.bDisplayInUI = false;
	
	return Passive('XenoBiologist', "img:///UILibrary_RPG.LW_AbilityVitalPointTargeting", false, Effect);
}

static function X2AbilityTemplate Scout()
{
	local XMBEffect_AddUtilityItem Effect;

	Effect = new class'XMBEffect_AddUtilityItem';
	Effect.DataName = 'BattleScanner';

	return Passive('Scout', "img:///UILibrary_RPG.UIPerk_Scout", false, Effect);
}

static function X2AbilityTemplate DamnGoodGround()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2AbilityTemplate Template;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'DamnGoodGround';

	Effect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("DAMN_GOOD_GROUND_AIM_BONUS"));
	Effect.AddToHitAsTargetModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("DAMN_GOOD_GROUND_DEFENSE_BONUS") * -1);

	Effect.AbilityTargetConditions.AddItem(default.HeightDisadvantageCondition);
	Effect.AbilityTargetConditionsAsTarget.AddItem(default.HeightAdvantageCondition);

	Template = Passive('DamnGoodGround', "img:///UILibrary_RPG.UIPerk_damngoodground", false, Effect);

	return Template;
}


static function X2AbilityTemplate Panoptic()
{
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_SightRadius, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("PANOPTIC_SIGHTRANGE_BONUS"));
	Effect.bDisplayInUI = false;
	
	return Passive('Panoptic', "img:///Texture2D'UILibrary_RPG.UIPerk_Panoptic'", false, Effect);
}

static function X2AbilityTemplate Hitman()
{
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("HITMAN_BONUS"), eHit_Crit);
	BonusEffect.AbilityTargetConditions.AddItem(default.FlankedCondition);

	return Passive('Hitman', "img:///Texture2D'UILibrary_RPG.UIPerk_Hitman'", false, BonusEffect);
}

static function X2AbilityTemplate Prodigy()
{
	local X2AbilityTemplate Template;
	
	Template = PurePassive('Prodigy', "img:///Texture2D'UILibrary_RPG.UIPerk_Savant'");
	Template.SoldierAbilityPurchasedFn = ProdigyPurchased;

	return Template;
}

static function ProdigyPurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	
	if (UnitState.ComInt <= 2)
	{
		UnitState.ComInt = ECombatIntelligence(UnitState.ComInt + 2);
	}
	if (UnitState.ComInt == 3)
	{
		UnitState.ComInt = ECombatIntelligence(UnitState.ComInt + 1);
	}
}

static function X2AbilityTemplate SyntheticGenes()
{
	local X2AbilityTemplate Template;
	
	Template = PurePassive('SyntheticGenes', "img:///Texture2D'UILibrary_RPG.UIPerk_SyntheticGenes'");
	Template.SoldierAbilityPurchasedFn = SyntheticGenesPurchased;

	return Template;
}

static function SyntheticGenesPurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local int NaturalAptitude;

	NaturalAptitude = int(GetNaturalAptitude(UnitState));

	if (NaturalAptitude <= 2)
	{
		UnitState.SetUnitFloatValue('NaturalAptitude', NaturalAptitude + 2, eCleanUp_Never);
	}
	if (NaturalAptitude == 3)
	{
		UnitState.SetUnitFloatValue('NaturalAptitude', NaturalAptitude + 1, eCleanUp_Never);
	}
}


static function ENaturalAptitude GetNaturalAptitude(XComGameState_Unit UnitState)
{
	local UnitValue NaturalAptitudeValue;
	
	UnitState.GetUnitValue('NaturalAptitude', NaturalAptitudeValue);
	return ENaturalAptitude(NaturalAptitudeValue.fValue);
}

static function X2AbilityTemplate Bulletproof()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Defense, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("BULLETPROOF_BONUS"));
	Effect.bDisplayInUI = false;
	
	Template = Passive('Bulletproof', "img:///Texture2D'UILibrary_RPG.UIPerk_Bulletproof'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DefenseStat, eStat_Defense, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("BULLETPROOF_BONUS"));
	
	return Template;
}


static function X2AbilityTemplate Juggernaut()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_HP, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("JUGGERNAUT_BONUS"));
	Effect.bDisplayInUI = false;
	
	Template = Passive('Juggernaut', "img:///Texture2D'UILibrary_RPG.UIPerk_Juggernaught'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("JUGGERNAUT_BONUS"));

	return Template;
}

static function X2AbilityTemplate Stalker()
{
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_DetectionModifier, class'RPGOAbilityConfigManager'.static.GetConfigFloatValue("STALKER_BONUS"));
	Effect.bDisplayInUI = false;
		
	return Passive('Stalker', "img:///Texture2D'UILibrary_RPG.UIPerk_Stalker'", true, Effect);
}

static function X2AbilityTemplate IronWill()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Will, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("IRONWILL_BONUS"));
	Effect.bDisplayInUI = false;
	
	Template = Passive('IronWill', "img:///Texture2D'UILibrary_RPG.UIPerk_IronWill'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.WillLabel, eStat_Will, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("IRONWILL_BONUS"));

	return Template;
}

static function X2AbilityTemplate CyberAdept()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Hacking, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("CYBERADEPT_BONUS"));
	Effect.bDisplayInUI = false;
	
	Template = Passive('CyberAdept', "img:///Texture2D'UILibrary_RPG.UIPerk_CyberAdept'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HackingSoldierLabel, eStat_Hacking, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("CYBERADEPT_BONUS"));

	return Template;
}

static function X2AbilityTemplate MovingTarget()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Dodge, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("MOVINGTARGET_BONUS"));
	Effect.bDisplayInUI = false;
	
	Template = Passive('MovingTarget', "img:///Texture2D'UILibrary_RPG.UIPerk_MovingTarget'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeStat, eStat_Dodge, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("MOVINGTARGET_BONUS"));

	return Template;
}

static function X2AbilityTemplate Praetorian()
{
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("PREATORIAN_BONUS"), eHit_Success);
	BonusEffect.AbilityTargetConditions.AddItem(default.MeleeCondition);
	BonusEffect.bDisplayInUI = false;
	
	return Passive('Praetorian', "img:///Texture2D'UILibrary_RPG.UIPerk_Praetorian'", false, BonusEffect);
}


static function X2AbilityTemplate Runner()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Mobility, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("RUNNER_BONUS"));
	Effect.bDisplayInUI = false;
	
	Template = Passive('Runner', "img:///UILibrary_RPG.UIPerk_Runner", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("RUNNER_BONUS"));

	return Template;
}

/static function X2AbilityTemplate EagleEye()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("EAGLEEYE_BONUS"), eHit_Success);
	BonusEffect.AbilityTargetConditions.AddItem(new class'X2Condition_NoReactionFire');
	BonusEffect.bDisplayInUI = false;
	
	Template = Passive('EagleEye', "img:///Texture2D'UILibrary_RPG.UIPerk_EagleEye'", false, BonusEffect);

	return Template;
}

static function X2AbilityTemplate HotShot()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("HOTSHOT_BONUS"), eHit_Success);
	BonusEffect.AbilityTargetConditions.AddItem(default.ReactionFireCondition);
	BonusEffect.bDisplayInUI = false;
	
	Template = Passive('HotShot', "img:///Texture2D'UILibrary_RPG.UIPerk_Hotshot'", false, BonusEffect);

	return Template;
}

static function X2AbilityTemplate Spray()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cone         ConeMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_ApplyDirectionalWorldDamage WorldDamage;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Spray');
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 3;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPRAY_COOLDOWN");
	Template.AbilityCooldown = Cooldown;
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bMultiTargetOnly = true;
	Template.AbilityToHitCalc = StandardAim;
	
	Template.AddMultiTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.AddMultiTargetEffect(default.WeaponUpgradeMissDamage);
	Template.bOverrideAim = true;

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = false;
	WorldDamage.EnvironmentalDamageAmount = 15;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = true;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
	WorldDamage.PlusNumZTiles = 1;
	WorldDamage.bHitTargetTile = true;
	WorldDamage.ApplyChance = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPRAY_DESTRUCTION_CHANCE");
	Template.AddMultiTargetEffect(WorldDamage);
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	ConeMultiTarget.ConeEndDiameter = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPRAY_TILE_WIDTH", "TagValueTilesToUnits");
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeLength = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPRAY_TILE_LENGTH", "TagValueTilesToUnits");
	ConeMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_saturationfire";
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.ActionFireClass = class'X2Action_Fire_SaturationFire';
	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.ActivationSpeech = 'SaturationFire';
	//Template.CinescriptCameraType = "Grenadier_SaturationFire";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;	
}

static function X2AbilityTemplate Quartermaster()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddItemCharges BonusItemEffect;

	BonusItemEffect = new class'XMBEffect_AddItemCharges';
	BonusItemEffect.PerItemBonus = 1;
	BonusItemEffect.ApplyToSlots.AddItem(eInvSlot_Utility);

	Template = Passive('Quartermaster', "img:///Texture2D'UILibrary_RPG.UIPerk_Packmaster'", false, BonusItemEffect);

	return Template;
}

static function X2AbilityTemplate RpgZoneOfControl()
{
	local X2AbilityTemplate Template;

	Template = class'X2Ability_SharpshooterAbilitySet'.static.ReturnFire('RpgZoneOfControl');
	Template.IconImage = "img:///Texture2D'UILibrary_RPG.LW_AbilityDangerZone'";

	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).bPreEmptiveFire = true;
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).MaxPointsPerTurn = 99;
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).AbilityToActivate = 'ZoneOfControlReturnFire';
	//X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).GrantActionPoint = class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint;
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).EffectName = 'ZoneOfControlEffect';
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).bDirectAttackOnly = false;

	Template.AdditionalAbilities.AddItem('ZoneOfControlReturnFire');

	return Template;
}

static function X2AbilityTemplate ZoneOfControlReturnFire()
{
	local X2AbilityTemplate Template;
	
	Template = class'X2Ability_DefaultAbilitySet'.static.PistolReturnFire('ZoneOfControlReturnFire');
	Template.IconImage = "img:///Texture2D'UILibrary_RPG.LW_AbilityDangerZone'";
	// Restrict the shot to units within 7 tiles
	Template.AbilityTargetConditions.AddItem(TargetWithinTiles(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("ZONE_OF_CONTROL_TARGET_WITHIN_TILES")));

	return Template;
}


static function X2AbilityTemplate DangerSense()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('RpgDangerSense', "img:///UILibrary_RPG.UIPerk_DangerSense", true);
	Template.AdditionalAbilities.AddItem('DangerSenseTrigger');
	Template.AdditionalAbilities.AddItem('DangerSenseSpawnTrigger');

	return Template;
}

static function X2AbilityTemplate DangerSenseTrigger()
{
	local X2AbilityTemplate					Template;
	local X2AbilityMultiTarget_Radius		RadiusMultiTarget;
	local X2Effect_RevealUnit				TrackingEffect;
	local X2Condition_UnitProperty			TargetProperty;
	local X2Condition_UnitEffects			EffectsCondition;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DangerSenseTrigger');

	Template.IconImage = "img:///UILibrary_RPG.UIPerk_DangerSense";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsNotPlayerControlled');
	Template.AbilityShooterConditions.AddItem(EffectsCondition);

	Template.AbilityTargetStyle = default.SelfTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = class'RPGOAbilityConfigManager'.static.GetConfigFloatValue("DANGERSENSE_RADIUS");
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.FailOnNonUnits = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	Template.AbilityMultiTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_Burrowed'.default.EffectName, 'AA_UnitIsBurrowed');
	Template.AbilityMultiTargetConditions.AddItem(EffectsCondition);

	TrackingEffect = new class'X2Effect_RevealUnit';
	TrackingEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddMultiTargetEffect(TrackingEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitMoveFinished';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'PlayerTurnBegun';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

// This triggers whenever a unit is spawned within tracking radius. The most likely
// reason for this to happen is a Faceless transforming due to tracking being applied.
// The newly spawned Faceless unit won't have the tracking effect when this happens,
// so we apply it here.
static function X2AbilityTemplate DangerSenseSpawnTrigger()
{
	local X2AbilityTemplate					Template;
	local X2Effect_RevealUnit				TrackingEffect;
	local X2Condition_UnitProperty			TargetProperty;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DangerSenseSpawnTrigger');

	Template.IconImage = "img:///UILibrary_RPG.UIPerk_DangerSense";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.FailOnNonUnits = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("DANGERSENSE_RADIUS") * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	TrackingEffect = new class'X2Effect_RevealUnit';
	TrackingEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddTargetEffect(TrackingEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitSpawned';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	EventListener.ListenerData.Filter = eFilter_None;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate StealthTactics()
{
	local X2AbilityTemplate								Template;
	local X2Effect_StealthTactics						StealthTacticsEffect;
	local X2AbilityTrigger_EventListener				EventListener;
	local X2Condition_NotVisibeToEnemies				NotVisibleToEnemiesCondition;
	local X2Condition_NotConcealed						NotConcealedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgStealthTactics');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_RPG.LW_AbilityTradecraft";

	NotVisibleToEnemiesCondition = new class'X2Condition_NotVisibeToEnemies';
	Template.AbilityTargetConditions.AddItem(NotVisibleToEnemiesCondition);

	NotConcealedCondition = new class'X2Condition_NotConcealed';
	Template.AbilityTargetConditions.AddItem(NotConcealedCondition);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'PlayerTurnBegun';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	StealthTacticsEffect = new class'X2Effect_StealthTactics';
	StealthTacticsEffect.EffectName = 'EffectStealthTactics';
	StealthTacticsEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	StealthTacticsEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,true,,Template.AbilitySourceName);
	StealthTacticsEffect.DuplicateResponse = eDupe_Allow;
	Template.AddTargetEffect(StealthTacticsEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}


static function X2AbilityTemplate Relocation()
{
	local X2AbilityTemplate						Template;
	local X2Effect_QuickFeet					QuickFeetEffect;
	
	Template = PurePassive('Relocation', "img:///UILibrary_RPG.UIPerk_Relocation", false);

	// Quick Feet Effect
	QuickFeetEffect = new class'X2Effect_QuickFeet';
	QuickFeetEffect.EffectName = 'Relocation';
	QuickFeetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(QuickFeetEffect);
	

	return Template;
}


static function X2AbilityTemplate HighNoon()
{
	local X2AbilityTemplate Template;

	Template = class'X2Ability_SharpshooterAbilitySet'.static.ReturnFire('HighNoon');
	Template.IconImage = "img:///UILibrary_RPG.UIPerk_HighNoon";

	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).bPreEmptiveFire = true;
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).MaxPointsPerTurn = 99;
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).AbilityToActivate = 'OverwatchShot';
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).GrantActionPoint = class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint;
	X2Effect_ReturnFire(Template.AbilityTargetEffects[0]).EffectName = 'HighNoonEffect';

	return Template;
}

static function X2AbilityTemplate Sabotage()
{
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_WeaponName WeaponCondition;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';

	Effect.AddDamageModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SABOTAGE_DAMAGE_BONUS"));

	// The bonus only applies to attacks with the weapon associated with this ability
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	WeaponCondition = new class'XMBCondition_WeaponName';
	WeaponCondition.IncludeWeaponNames.AddItem('ProximityMine');
	WeaponCondition.IncludeWeaponNames.AddItem('Reaper_Claymore');
	WeaponCondition.IncludeWeaponNames.AddItem('TacticalC4');
	WeaponCondition.IncludeWeaponNames.AddItem('TacticalX4');
	WeaponCondition.IncludeWeaponNames.AddItem('TacticalE4');
	Effect.AbilityTargetConditions.AddItem(WeaponCondition);
	// Create the template using a helper function
	return Passive('Sabotage', "img:///Texture2D'UILibrary_RPG.UIPerk_Sabotage'", true, Effect);
}

static function X2AbilityTemplate Overkill()
{
	local XMBEffect_AddItemCharges Effect;

	Effect = new class'XMBEffect_AddItemCharges';
	Effect.ApplyToSlots.AddItem(eInvSlot_Utility);
	Effect.ApplyToSlots.AddItem(eInvSlot_SecondaryWeapon);
	Effect.ApplyToNames.AddItem('ProximityMine');
	Effect.ApplyToNames.AddItem('TacticalC4');
	Effect.ApplyToNames.AddItem('TacticalX4');
	Effect.ApplyToNames.AddItem('TacticalE4');

	return Passive('Overkill', "img:///Texture2D'UILibrary_RPG.UIPerk_Overkill'", false, Effect);
}

static function X2AbilityTemplate Rocketeer()
{
	local XMBEffect_AddItemCharges Effect;
	local X2AbilityTemplate Template;

	// Create an effect that adds a charge to the equipped heavy weapon
	Effect = new class'XMBEffect_AddItemCharges';
	Effect.ApplyToSlots.AddItem(eInvSlot_HeavyWeapon);
	Effect.PerItemBonus = 1;

	// The effect isn't an X2Effect_Persistent, so we can't use it as the effect for Passive(). Let
	// Passive() create its own effect.
	Template = Passive('Rocketeer', "img:///Texture2D'UILibrary_RPG.UIPerk_rocketeer'", false);

	// Add the XMBEffect_AddItemCharges as an extra effect.
	AddSecondaryEffect(Template, Effect);

	return Template;
}


static function X2AbilityTemplate FullAutoFire()
{
	local X2AbilityTemplate Template;
	local X2Effect_MaybeApplyDirectionalWorldDamage WorldDamage;
	local X2AbilityCost_Ammo AmmoCost;
	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('FullAutoFire');
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY + 10;
	Template.IconImage = "img:///Texture2D'UILibrary_RPG.UIPerk_AssaultAutoRifle'";

	GetAbilityCostActionPoints(Template).iNumPoints = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_ACTIONPOINTS");
	AmmoCost = X2AbilityCost_Ammo(GetAbilityCostByClassName(Template, 'X2AbilityCost_Ammo'));
	AmmoCost.iAmmo += class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_MIN_AMMO");
	AmmoCost.bConsumeAllAmmo = true;

	WorldDamage = new class'X2Effect_MaybeApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = false;
	WorldDamage.EnvironmentalDamageAmount = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_ENVIRONMENTAL_DAMAGE");
	WorldDamage.ApplyChance = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_DESTRUCTION_CHANCE");
	WorldDamage.bApplyOnHit =  class'RPGOAbilityConfigManager'.static.GetConfigBoolValue("AUTOFIRE_DESTRUCTION_APPLY_ON_HIT");
	WorldDamage.bApplyOnMiss = class'RPGOAbilityConfigManager'.static.GetConfigBoolValue("AUTOFIRE_DESTRUCTION_APPLY_ON_MISS");
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = class'RPGOAbilityConfigManager'.static.GetConfigBoolValue("AUTOFIRE_DESTRUCTION_HIT_ADJACENT_DESTRUCTIBLES");
	WorldDamage.PlusNumZTiles = 1;
	WorldDamage.bHitTargetTile = true;
	Template.AddTargetEffect(WorldDamage);

	Template.AdditionalAbilities.AddItem('AutoFireModifications');

	return Template;
}

static function X2AbilityTemplate AutoFireModifications()
{
	local X2AbilityTemplate				Template;
	local XMBEffect_ConditionalBonus	HitEffect;
	local XMBEffect_ConditionalBonus	DamageBonus;
	local X2Condition_WeaponCategory	WeaponCondition;
	local XMBCondition_AbilityName		AbilityCondition;
	local array<string>					WeaponCategories;
	local string						WeaponCategory;

	Template = PurePassive('AutoFireModifications', "img:///Texture2D'UILibrary_RPG.UIPerk_AssaultAutoRifle'", false, 'eAbilitySource_Perk', false);

	WeaponCondition = new class'X2Condition_WeaponCategory';
	WeaponCategories = class'RPGOAbilityConfigManager'.static.GetConfigStringArray("AUTOFIRE_WEAPON_CATEGORIES");
	foreach WeaponCategories(WeaponCategory)
	{
		`LOG(default.class @ GetFuncName() @ "adding WeaponCategory" @ WeaponCategory,, 'RPG');
		WeaponCondition.IncludeWeaponCategories.AddItem(name(WeaponCategory));
	}

	AbilityCondition = new class'XMBCondition_AbilityName';
	AbilityCondition.IncludeAbilityNames.AddItem('FullAutoFire');

	HitEffect = new class'XMBEffect_ConditionalBonus';
	HitEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_TARGET_DODGE_PENALTY"), eHit_Graze);
	HitEffect.BuildPersistentEffect(1, false, false, false);
	HitEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,,Template.AbilitySourceName);
	HitEffect.bHideWhenNotRelevant = true;
	HitEffect.AbilityTargetConditions.AddItem(WeaponCondition);
	HitEffect.AbilityTargetConditions.AddItem(AbilityCondition);
	HitEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(HitEffect);

	HitEffect = new class'XMBEffect_ConditionalBonus';
	HitEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_FULLCOVER_MALUS"), eHit_Success);
	HitEffect.BuildPersistentEffect(1, false, false, false);
	HitEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,,Template.AbilitySourceName);
	HitEffect.bHideWhenNotRelevant = true;
	HitEffect.AbilityTargetConditions.AddItem(default.FullCoverCondition);
	HitEffect.AbilityTargetConditions.AddItem(WeaponCondition);
	HitEffect.AbilityTargetConditions.AddItem(AbilityCondition);
	HitEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(HitEffect);

	HitEffect = new class'XMBEffect_ConditionalBonus';
	HitEffect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_HALFCOVER_MALUS"), eHit_Success);
	HitEffect.BuildPersistentEffect(1, false, false, false);
	HitEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,,Template.AbilitySourceName);
	HitEffect.bHideWhenNotRelevant = true;
	HitEffect.AbilityTargetConditions.AddItem(default.HalfCoverCondition);
	HitEffect.AbilityTargetConditions.AddItem(WeaponCondition);
	HitEffect.AbilityTargetConditions.AddItem(AbilityCondition);
	HitEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(HitEffect);

	DamageBonus = new class'XMBEffect_ConditionalBonus';
	DamageBonus.BuildPersistentEffect(1, false, false, false);
	DamageBonus.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,,Template.AbilitySourceName);
	DamageBonus.AddDamageModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AUTOFIRE_DAMAGE_PER_AMMO"));
	DamageBonus.ScaleValue = new class'XMBValue_Ammo';
	DamageBonus.ScaleMax = 5;
	DamageBonus.AbilityTargetConditions.AddItem(WeaponCondition);
	DamageBonus.AbilityTargetConditions.AddItem(AbilityCondition);
	Template.AddTargetEffect(DamageBonus);

	return Template;
}


static function X2AbilityTemplate SurgicalPrecision()
{
	local X2AbilityTemplate						Template;
	local XMBEffect_ConditionalBonus			Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AbilityTargetConditions.AddItem(default.FullCoverCondition);
	Effect.AddToHitModifier(class'X2AbilityToHitCalc_StandardAim'.default.HIGH_COVER_BONUS / 2);

	Template = Passive('SurgicalPrecision', "img:///Texture2D'UILibrary_RPG.UIPerk_SurgicalPrecision'", true, Effect);
	
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AbilityTargetConditions.AddItem(default.HalfCoverCondition);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,, Template.AbilitySourceName);
	Effect.AddToHitModifier(class'X2AbilityToHitCalc_StandardAim'.default.LOW_COVER_BONUS / 2);
	Template.AddTargetEffect(Effect);

	return Template;
}

static function X2DataTemplate ReadyForAnything()
{
	local X2AbilityTemplate							Template;
	local X2Effect_ReadyForAnything					ActionPointEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'ReadyForAnything');

	Template.IconImage = "img:///UILibrary_RPG.UIPerk_ReadyForAnything";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
	Template.bShowActivation = false;
	Template.bIsPassive = true;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ActionPointEffect = new class'X2Effect_ReadyForAnything';
	ActionPointEffect.BuildPersistentEffect (1, true, false);
	ActionPointEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	Template.AddTargetEffect(ActionPointEffect);

	Template.AdditionalAbilities.AddItem('ReadyForAnythingFlyover');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}


static function X2DataTemplate ReadyForAnythingFlyover()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'ReadyForAnythingFlyover');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.bShowActivation = false; // Flyover is already displayed by Custom Build Viz
	Template.bSkipFireAction = true;
	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = "img:///UILibrary_RPG.UIPerk_ReadyForAnything";

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'ReadyForAnythingTriggered';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.CinescriptCameraType = "Overwatch";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = ReadyforAnything_BuildVisualization;
	Template.MergeVisualizationFn = ReadyForAnything_MergeVisualization;

	return Template;
}

simulated function ReadyForAnything_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability  Context;
	local VisualizationActionMetadata   ActionMetadata;
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local StateObjectReference          InteractingUnitRef;
	local XComGameState_Ability			Ability;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID, 1, VisualizeGameState.HistoryIndex - 1));
	
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(SoundCue'SoundUI.OverWatchCue', Ability.GetMyTemplate().LocFlyOverText, '', eColor_Good, Ability.GetMyTemplate().IconImage);
}

static simulated function ReadyForAnything_MergeVisualization(X2Action BuildTree, out X2Action VisualizationTree)
{
	local XComGameStateVisualizationMgr VisMgr;
	local array<X2Action>				FindActions;

	VisMgr = `XCOMVISUALIZATIONMGR;
	
	//	This will delay the Ready For Anything flyover until the soldier Enters Cover after using the triggering ability.
	VisMgr.GetNodesOfType(VisualizationTree, class'X2Action_MarkerTreeInsertEnd', FindActions, BuildTree.Metadata.VisualizeActor);
	if (FindActions.Length > 0)
	{
		VisMgr.ConnectAction(BuildTree, VisualizationTree, false,, FindActions);
	}
}

static function X2AbilityTemplate DeadeyeAbility()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("DEADEYE_CRIT_BONUS"), eHit_Crit);
	Effect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("DEADEYE_HIT_BONUS"), eHit_Success);
	Effect.AbilityTargetConditions.AddItem(new class'X2Condition_NotFlankable');

	return Passive('Deadeye', "img:///UILibrary_RPG.UIPerk_deadeye", true, Effect);
}

static function X2AbilityTemplate KillEmAll()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cone         ConeMultiTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'KillEmAll');

	Template.IconImage = "img:///UILibrary_RPG.UIPerk_KillEmAll";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("KILLEMALL_COOLDOWN");
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.bOnlyMultiHitWithSuccess = false;
	ToHitCalc.bMultiTargetOnly = true;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.bOverrideAim = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	Template.AbilityTargetStyle = CursorTarget;	

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	ConeMultiTarget.ConeEndDiameter = class'RPGOAbilityConfigManager'.static.GetConfigIntValue("KILLEMALL_TILE_WIDTH", "TagValueTilesToUnits");
	ConeMultiTarget.bUseWeaponRangeForLength = true;
	ConeMultiTarget.fTargetRadius = 99;     //  large number to handle weapon range - targets will get filtered according to cone constraints
	ConeMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);

	Template.AddTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	Template.AddMultiTargetEffect(new class'X2Effect_ApplyWeaponDamage');

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = KillEmAll_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.ActivationSpeech = 'Faceoff';

	return Template;
}


function KillEmAll_BuildVisualization(XComGameState VisualizeGameState)
{
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local StateObjectReference          ShootingUnitRef;
	//local X2Action_Fire                 FireAction;
	local X2Action_Fire_Faceoff         FireFaceoffAction;
	local XComGameState_BaseObject      TargetStateObject;//Container for state objects within VisualizeGameState	

	local Actor                     TargetVisualizer, ShooterVisualizer;
	local X2VisualizerInterface     TargetVisualizerInterface;
	local int                       EffectIndex, TargetIndex;

	local VisualizationActionMetadata        EmptyTrack;
	local VisualizationActionMetadata        ActionMetadata;
	local VisualizationActionMetadata        SourceTrack;
	local XComGameStateHistory      History;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
	local name         ApplyResult;

	local X2Action_StartCinescriptCamera CinescriptStartAction;
	local X2Action_EndCinescriptCamera   CinescriptEndAction;
	local X2Camera_Cinescript            CinescriptCamera;
	local string                         PreviousCinescriptCameraType;
	local X2Effect                       TargetEffect;

	local X2Action_MarkerNamed				JoinActions;
	local array<X2Action>					LeafNodes;
	local XComGameStateVisualizationMgr		VisualizationMgr;
	local X2Action_ApplyWeaponDamageToUnit	ApplyWeaponDamageAction;


	History = `XCOMHISTORY;
	VisualizationMgr = `XCOMVISUALIZATIONMGR;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	ShootingUnitRef = Context.InputContext.SourceObject;

	ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);

	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	if( SourceTrack.StateObject_NewState == none )
		SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;
	SourceTrack.VisualizeActor = ShooterVisualizer;

	if( AbilityTemplate.ActivationSpeech != '' )     //  allows us to change the template without modifying this function later
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(SourceTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.ActivationSpeech, eColor_Good);
	}


	// Add a Camera Action to the Shooter's Metadata.  Minor hack: To create a CinescriptCamera the AbilityTemplate 
	// must have a camera type.  So manually set one here, use it, then restore.
	PreviousCinescriptCameraType = AbilityTemplate.CinescriptCameraType;
	AbilityTemplate.CinescriptCameraType = "StandardGunFiring";
	CinescriptCamera = class'X2Camera_Cinescript'.static.CreateCinescriptCameraForAbility(Context);
	CinescriptStartAction = X2Action_StartCinescriptCamera(class'X2Action_StartCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
	CinescriptStartAction.CinescriptCamera = CinescriptCamera;
	AbilityTemplate.CinescriptCameraType = PreviousCinescriptCameraType;


	class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);

	////  Fire at the primary target first
	//FireAction = X2Action_Fire(class'X2Action_Fire'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
	//FireAction.SetFireParameters(Context.IsResultContextHit(), , false);
	////  Setup target response
	//TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);
	//TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);
	//ActionMetadata = EmptyTrack;
	//ActionMetadata.VisualizeActor = TargetVisualizer;
	//TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
	//if( TargetStateObject != none )
	//{
	//	History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID,
	//													   ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState,
	//													   eReturnType_Reference,
	//													   VisualizeGameState.HistoryIndex);
	//	`assert(ActionMetadata.StateObject_NewState == TargetStateObject);
	//}
	//else
	//{
	//	//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
	//	//and show no change.
	//	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
	//	ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	//}
	//
	//for( EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex )
	//{
	//	ApplyResult = Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]);
	//
	//	// Target effect visualization
	//	AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, ApplyResult);
	//
	//	// Source effect visualization
	//	AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
	//}
	//if( TargetVisualizerInterface != none )
	//{
	//	//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
	//	TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
	//}
	//
	//ApplyWeaponDamageAction = X2Action_ApplyWeaponDamageToUnit(VisualizationMgr.GetNodeOfType(VisualizationMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', TargetVisualizer));
	//if ( ApplyWeaponDamageAction != None)
	//{
	//	VisualizationMgr.DisconnectAction(ApplyWeaponDamageAction);
	//	VisualizationMgr.ConnectAction(ApplyWeaponDamageAction, VisualizationMgr.BuildVisTree, false, FireAction);
	//}

	//  Now configure a fire action for each multi target
	for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
	{
		// Add an action to pop the previous CinescriptCamera off the camera stack.
		CinescriptEndAction = X2Action_EndCinescriptCamera(class'X2Action_EndCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
		CinescriptEndAction.CinescriptCamera = CinescriptCamera;
		CinescriptEndAction.bForceEndImmediately = true;

		// Add an action to push a new CinescriptCamera onto the camera stack.
		AbilityTemplate.CinescriptCameraType = "StandardGunFiring";
		CinescriptCamera = class'X2Camera_Cinescript'.static.CreateCinescriptCameraForAbility(Context);
		CinescriptCamera.TargetObjectIdOverride = AbilityContext.MultiTargets[TargetIndex].ObjectID;
		CinescriptStartAction = X2Action_StartCinescriptCamera(class'X2Action_StartCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
		CinescriptStartAction.CinescriptCamera = CinescriptCamera;
		AbilityTemplate.CinescriptCameraType = PreviousCinescriptCameraType;

		// Add a custom Fire action to the shooter Metadata.
		TargetVisualizer = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);
		FireFaceoffAction = X2Action_Fire_Faceoff(class'X2Action_Fire_Faceoff'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
		FireFaceoffAction.SetFireParameters(Context.IsResultContextMultiHit(TargetIndex), AbilityContext.MultiTargets[TargetIndex].ObjectID, false);
		FireFaceoffAction.vTargetLocation = TargetVisualizer.Location;

		//  Setup target response
		TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);
		ActionMetadata = EmptyTrack;
		ActionMetadata.VisualizeActor = TargetVisualizer;
		TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
		if( TargetStateObject != none )
		{
			History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID,
															   ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState,
															   eReturnType_Reference,
															   VisualizeGameState.HistoryIndex);
			`assert(ActionMetadata.StateObject_NewState == TargetStateObject);
		}
		else
		{
			//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
			//and show no change.
			ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
			ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
		}

		for( EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityMultiTargetEffects.Length; ++EffectIndex )
		{
			TargetEffect = AbilityTemplate.AbilityMultiTargetEffects[EffectIndex];
			ApplyResult = Context.FindMultiTargetEffectApplyResult(TargetEffect, TargetIndex);

			// Target effect visualization
			AbilityTemplate.AbilityMultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, ApplyResult);

			// Source effect visualization
			AbilityTemplate.AbilityMultiTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
		}
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}

		ApplyWeaponDamageAction = X2Action_ApplyWeaponDamageToUnit(VisualizationMgr.GetNodeOfType(VisualizationMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', TargetVisualizer));
		if( ApplyWeaponDamageAction != None )
		{
			VisualizationMgr.DisconnectAction(ApplyWeaponDamageAction);
			VisualizationMgr.ConnectAction(ApplyWeaponDamageAction, VisualizationMgr.BuildVisTree, false, FireFaceoffAction);
		}
	}
	class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);

	// Add an action to pop the last CinescriptCamera off the camera stack.
	CinescriptEndAction = X2Action_EndCinescriptCamera(class'X2Action_EndCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
	CinescriptEndAction.CinescriptCamera = CinescriptCamera;

	//Add a join so that all hit reactions and other actions will complete before the visualization sequence moves on. In the case
	// of fire but no enter cover then we need to make sure to wait for the fire since it isn't a leaf node
	VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, LeafNodes);

	if( VisualizationMgr.BuildVisTree.ChildActions.Length > 0 )
	{
		JoinActions = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(SourceTrack, Context, false, none, LeafNodes));
		JoinActions.SetName("Join");
	}
}


static function X2AbilityTemplate SniperElite()
{
	local X2Effect_NoSquadsightPenalities Effect;

	Effect = new class'X2Effect_NoSquadsightPenalities';

	return Passive('SniperElite', "img:///UILibrary_RPG.UIPerk_SniperElite", true, Effect);
}

static function X2AbilityTemplate TriggerHappy()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('TriggerHappy', "img:///UILibrary_RPG.UIPerk_TiggerHappy", true);
	Template.AdditionalAbilities.AddItem('TriggerHappyScamperShot');

	return Template;
}

static function X2AbilityTemplate TriggerHappyScamperShot()
{
	//local X2AbilityTrigger_EventListener		EventListener;
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2Condition_UnitProperty          ShooterCondition;
	local X2AbilityTarget_Single            SingleTarget;
	//local X2AbilityTrigger_EventListener	Trigger;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility			TargetVisibilityCondition;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TriggerHappyScamperShot');
	
	Template.bDontDisplayInAbilitySummary = true;
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;	
	Template.AbilityCosts.AddItem(AmmoCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	//StandardAim.bReactionFire = true;
	Template.AbilityToHitCalc = StandardAim;
	Template.AbilityToHitOwnerOnMissCalc = StandardAim;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_EverVigilant');
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = OverwatchShot_BuildVisualization;
	Template.bAllowFreeFireWeaponUpgrade = false;	
	Template.bAllowAmmoEffects = true;
	Template.AssociatedPassives.AddItem('HoloTargeting');

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_Chosen'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.bAllowBonusWeaponEffects = true;

	// Damage Effect
	//
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);

	class'X2StrategyElement_XpackDarkEvents'.static.AddStilettoRoundsEffect(Template);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	
	return Template;	
}

static function X2AbilityTemplate SpotWeakness()
{
	local XMBEffect_ConditionalBonus Effect;

	// Create an effect that adds +15 to crit and +1/2/3 armor piercing
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddArmorPiercingModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPOT_WEAKNESS_PIERCE_CV"), eHit_Success, 'conventional');
	Effect.AddArmorPiercingModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPOT_WEAKNESS_PIERCE_MG"), eHit_Success, 'magnetic');
	Effect.AddArmorPiercingModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPOT_WEAKNESS_PIERCE_BM"), eHit_Success, 'beam');
	Effect.AddToHitModifier(class'RPGOAbilityConfigManager'.static.GetConfigIntValue("SPOT_WEAKNESS_CRIT"), eHit_Crit);

	// Restrict to the weapon matching this ability
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	return Passive('RpgSpotWeakness', "img:///XPerkIconPack.UIPerk_pistol_crit2", false, Effect);
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

static function X2AbilityCost GetAbilityCostByClassName(X2AbilityTemplate Template, name CostClassName)
{
	local X2AbilityCost Cost;

	foreach Template.AbilityCosts(Cost)
	{
		if (Cost.IsA(CostClassName))
		{
			return Cost;
		}
	}
	return none;
}