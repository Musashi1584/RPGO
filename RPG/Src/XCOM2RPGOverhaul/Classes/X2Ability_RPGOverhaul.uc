class X2Ability_RPGOverhaul extends XMBAbility config(RPG);

var localized string SuppressionTargetEffectDesc;
var localized string SuppressionSourceEffectDesc;

var config float AREA_SUPPRESSION_RADIUS;
var config int DANGERSENSE_RADIUS;
var config int HOTSHOT_BONUS;
var config int EAGLEEYE_BONUS;
var config int RUNNER_BONUS;
var config int PREATORIAN_BONUS;
var config int MOVINGTARGET_BONUS;
var config int CYBERADEPT_BONUS;
var config int IRONWILL_BONUS;
var config float STALKER_BONUS;
var config int JUGGERNAUT_BONUS;
var config int BULLETPROOF_BONUS;
var config int HITMAN_BONUS;
var config int SABOTAGE_DAMAGE_BONUS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	// Random Starting Abilities
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
	
	// Class abilities
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

	return Templates;
}

static function X2AbilityTemplate Hitman()
{
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.HITMAN_BONUS, eHit_Crit);
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

static function X2AbilityTemplate Bulletproof()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Defense, default.BULLETPROOF_BONUS);
	Template = Passive('Bulletproof', "img:///Texture2D'UILibrary_RPG.UIPerk_Bulletproof'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DefenseStat, eStat_Defense, default.BULLETPROOF_BONUS);

	return Template;
}


static function X2AbilityTemplate Juggernaut()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_HP, default.JUGGERNAUT_BONUS);
	
	Template = Passive('Juggernaut', "img:///Texture2D'UILibrary_RPG.UIPerk_Juggernaught'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, default.JUGGERNAUT_BONUS);

	return Template;
}

static function X2AbilityTemplate Stalker()
{
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_DetectionModifier, default.STALKER_BONUS);
	
	return Passive('Stalker', "img:///Texture2D'UILibrary_RPG.UIPerk_Stalker'", true, Effect);
}

static function X2AbilityTemplate IronWill()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Will, default.IRONWILL_BONUS);
	Template = Passive('IronWill', "img:///Texture2D'UILibrary_RPG.UIPerk_IronWill'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.WillLabel, eStat_Will, default.IRONWILL_BONUS);

	return Template;
}

static function X2AbilityTemplate CyberAdept()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Hacking, default.CYBERADEPT_BONUS);
	Template = Passive('CyberAdept', "img:///Texture2D'UILibrary_RPG.UIPerk_CyberAdept'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HackingSoldierLabel, eStat_Hacking, default.CYBERADEPT_BONUS);

	return Template;
}

static function X2AbilityTemplate MovingTarget()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Dodge, default.MOVINGTARGET_BONUS);
	Template = Passive('MovingTarget', "img:///Texture2D'UILibrary_RPG.UIPerk_MovingTarget'", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeStat, eStat_Dodge, default.MOVINGTARGET_BONUS);

	return Template;
}

static function X2AbilityTemplate Praetorian()
{
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.PREATORIAN_BONUS, eHit_Success);
	BonusEffect.AbilityTargetConditions.AddItem(default.MeleeCondition);

	return Passive('Praetorian', "img:///Texture2D'UILibrary_RPG.UIPerk_Praetorian'", false, BonusEffect);
}


static function X2AbilityTemplate Runner()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Mobility, default.RUNNER_BONUS);

	Template = Passive('Runner', "img:///UILibrary_RPG.UIPerk_Runner", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.RUNNER_BONUS);

	return Template;
}

static function X2AbilityTemplate EagleEye()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.EAGLEEYE_BONUS, eHit_Success);
	BonusEffect.AbilityTargetConditions.AddItem(new class'X2Condition_NoReactionFire');

	Template = Passive('EagleEye', "img:///Texture2D'UILibrary_RPG.UIPerk_EagleEye'", false, BonusEffect);

	return Template;
}

static function X2AbilityTemplate HotShot()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.HOTSHOT_BONUS, eHit_Success);
	BonusEffect.AbilityTargetConditions.AddItem(default.ReactionFireCondition);

	Template = Passive('HotShot', "img:///Texture2D'UILibrary_RPG.UIPerk_Hotshot'", false, BonusEffect);

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
	Template.AbilityTargetConditions.AddItem(TargetWithinTiles(7));

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
	RadiusMultiTarget.fTargetRadius = default.DANGERSENSE_RADIUS;
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
	TargetProperty.WithinRange = default.DANGERSENSE_RADIUS * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER;
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

	Effect.AddDamageModifier(default.SABOTAGE_DAMAGE_BONUS);

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
	Effect.ApplyToNames.AddItem('Reaper_Claymore');
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
	local X2Effect_ApplyDirectionalWorldDamage  WorldDamage;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('FullAutoFire');
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY + 10;
	Template.IconImage = "img:///Texture2D'UILibrary_RPG.UIPerk_AssaultAutoRifle'";

	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).iNumPoints = 2;
	X2AbilityCost_Ammo(Template.AbilityCosts[1]).iAmmo += 2;
	X2AbilityCost_Ammo(Template.AbilityCosts[1]).bConsumeAllAmmo = true;

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = false;
	WorldDamage.EnvironmentalDamageAmount = 30;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = false;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
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

	Template = PurePassive('AutoFireModifications', "img:///Texture2D'UILibrary_RPG.UIPerk_AssaultAutoRifle'", false, 'eAbilitySource_Perk', false);

	WeaponCondition = new class'X2Condition_WeaponCategory';
	WeaponCondition.IncludeWeaponCategories.AddItem('bullpup');
	WeaponCondition.IncludeWeaponCategories.AddItem('rifle');
	WeaponCondition.IncludeWeaponCategories.AddItem('cannon');

	AbilityCondition = new class'XMBCondition_AbilityName';
	AbilityCondition.IncludeAbilityNames.AddItem('FullAutoFire');

	HitEffect = new class'XMBEffect_ConditionalBonus';
	HitEffect.AddToHitModifier(-100, eHit_Graze);
	HitEffect.BuildPersistentEffect(1, false, false, false);
	HitEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,,Template.AbilitySourceName);
	HitEffect.bHideWhenNotRelevant = true;
	HitEffect.AbilityTargetConditions.AddItem(WeaponCondition);
	HitEffect.AbilityTargetConditions.AddItem(AbilityCondition);
	HitEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(HitEffect);

	HitEffect = new class'XMBEffect_ConditionalBonus';
	HitEffect.AddToHitModifier(-20, eHit_Success);
	HitEffect.BuildPersistentEffect(1, false, false, false);
	HitEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, false,,Template.AbilitySourceName);
	HitEffect.bHideWhenNotRelevant = true;
	HitEffect.AbilityTargetConditions.AddItem(default.FullCoverCondition);
	HitEffect.AbilityTargetConditions.AddItem(WeaponCondition);
	HitEffect.AbilityTargetConditions.AddItem(AbilityCondition);
	HitEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(HitEffect);

	HitEffect = new class'XMBEffect_ConditionalBonus';
	HitEffect.AddToHitModifier(-10, eHit_Success);
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
	DamageBonus.AddDamageModifier(1);
	DamageBonus.ScaleValue = new class'XMBValue_Ammo';
	DamageBonus.ScaleMax = 99;
	DamageBonus.AbilityTargetConditions.AddItem(WeaponCondition);
	DamageBonus.AbilityTargetConditions.AddItem(AbilityCondition);
	Template.AddTargetEffect(DamageBonus);

	return Template;
}