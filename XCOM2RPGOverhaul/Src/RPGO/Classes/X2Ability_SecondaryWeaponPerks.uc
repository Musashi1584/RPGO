class X2Ability_SecondaryWeaponPerks extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
//	Arcthrower
	Templates.AddItem(RapidStun());
	Templates.AddItem(ThatsCloseEnough());
	Templates.AddItem(SpareBattery());

//	Sawed-Off Shotgun
	Templates.AddItem(SawnOffReload());
	Templates.AddItem(ShotgunTap());	
	Templates.AddItem(SingleTap());	
	Templates.AddItem(DoubleTap());	
	Templates.AddItem(DoubleTap2());
	Templates.Additem(RpgDeepPockets());
	Templates.Additem(SawedOffOverwatch());
	Templates.Additem(ScrapMetal());
	Templates.Additem(ScrapMetalTrigger());
	Templates.Additem(Brutality());
	Templates.Additem(Ruthless());
	
	return Templates;
}

// #######################################################################################
// -------------------- ARCTHROWER  ------------------------------------------------------
// #######################################################################################

// Quick Zap - Next Arcthrower action is free
static function X2AbilityTemplate RapidStun()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AbilityCostRefund Effect;
	local X2Condition_ArcthrowerAbilities Condition;

	// Create effect that will refund actions points
	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.TriggeredEvent = 'RpgRapidStun';
	Effect.bShowFlyOver = true;
	Effect.CountValueName = 'RpgRapidStun_Uses';
	Effect.MaxRefundsPerTurn = 1;
	Effect.bFreeCost = true;
	Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	// Action points are only refunded if using a support grenade (or battlescanner)
	Condition = new class'X2Condition_ArcthrowerAbilities';
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Show a flyover over the target unit when the effect is added
	Effect.VisualizationFn = EffectFlyOver_Visualization;

	// Create activated ability that adds the refund effect
	Template = SelfTargetActivated('RpgRapidStun', "img:///UILibrary_RPGO.UIPerk_RapidStun", true, Effect,, eCost_Free);
	AddCooldown(Template, class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("RAPID_STUN_COOLDOWN"));

	// Cannot be used while burning, etc.
	Template.AddShooterEffectExclusions();

	return Template;
}

// That's Close Enough - Close Combat Specialist for Arcthrower
static function X2AbilityTemplate ThatsCloseEnough()
{
	local X2AbilityTemplate Template;
	local X2AbilityToHitCalc_StandardAim ToHit;
	local X2Effect StunnedEffect;

	// Create a stun effect that removes 2 actions and has a 100% chance of success if the attack hits.
	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false);

	Template = Attack('RpgThatsCloseEnough', "img:///Texture2D'UILibrary_RPGO.UIPerk_ThatsCloseEnough'", false, StunnedEffect, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_None);
	
	HidePerkIcon(Template);
	AddIconPassive(Template);

	ToHit = new class'X2AbilityToHitCalc_StandardAim';
	ToHit.bReactionFire = true;
	Template.AbilityToHitCalc = ToHit;
	Template.AbilityTriggers.Length = 0;
	AddMovementTrigger(Template);
	Template.AbilityTargetConditions.AddItem(TargetWithinTiles(4));
	AddPerTargetCooldown(Template, 1);

	return Template;
}

// Spare Battery - Once per mission, reset your Arcthrower perk cooldowns
static function X2AbilityTemplate SpareBattery()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCooldown                 Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgSpareBattery');

	Template.IconImage = "img:///UILibrary_RPGO.UIPerk_SpareBattery";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("SPARE_BATTERY_COOLDOWN");
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_ManualOverride');
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();	

	Template.AddTargetEffect(new class'X2Effect_SpareBattery');

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.AbilityConfirmSound = "Manual_Override_Activate";

	return Template;
}

// #######################################################################################
// -------------------- SAWED-OFF SHOTGUN ------------------------------------------------
// #######################################################################################

// Reload Sawed-Off - Reload the Sawed-Off Shotgun. Charge-based.
static function X2AbilityTemplate SawnOffReload()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCharges					Charges;
	local X2AbilityCost_Charges				ChargeCost;
	local X2Condition_UnitProperty          ShooterPropertyCondition;
	local X2Condition_AbilitySourceWeapon   WeaponCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local array<name>                       SkipExclusions;
	local X2Effect_ReloadSecondaryWeapon 	ReloadEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgSawnOffReload');
	
	Template.bDontDisplayInAbilitySummary = false;
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Charges
	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("SAWNOFFRELOAD_CHARGES");
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	ShooterPropertyCondition = new class'X2Condition_UnitProperty';	
	ShooterPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(ShooterPropertyCondition);
	WeaponCondition = new class'X2Condition_AbilitySourceWeapon';
	WeaponCondition.WantsReload = true;
	Template.AbilityShooterConditions.AddItem(WeaponCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.AbilityToHitCalc = default.DeadEye;
	
	Template.AbilityTargetStyle = default.SelfTarget;
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.IconImage = "img:///'UILibrary_RPGO.UIPerk_ReloadSawedOff'";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.RELOAD_PRIORITY;
	Template.bNoConfirmationWithHotKey = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	// Create an effect that restores some ammo
	ReloadEffect = new class'X2Effect_ReloadSecondaryWeapon';
	ReloadEffect.AmmoToReload = 1; // make configurable
	Template.AddTargetEffect(ReloadEffect);
	
	Template.ActivationSpeech = 'Reloading';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = ReloadAbility_BuildVisualization; // testing standard reload viz
	
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.Hostility = eHostility_Neutral;

	Template.CinescriptCameraType = "GenericAccentCam";

	return Template;	
}

simulated function ReloadAbility_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference          ShootingUnitRef;	
	local X2Action_PlayAnimation		PlayAnimation;

	local VisualizationActionMetadata        EmptyTrack;
	local VisualizationActionMetadata        ActionMetadata;

	local XComGameState_Ability Ability;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	ShootingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(ShootingUnitRef.ObjectID);
					
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	PlayAnimation.Params.AnimName = 'HL_Reload';

	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", Ability.GetMyTemplate().ActivationSpeech, eColor_Good);

		//****************************************************************************************
}

// Shotgun Tap - Grants the Hipfire ability (template name RpgShotgunTap).
// Point Blank no longer ends the turn.
static function X2AbilityTemplate ShotgunTap()
{
	local X2AbilityTemplate		Template;
	
	Template = PurePassive('RpgShotgunTap', "img:///UILibrary_LWSecondariesWOTC.LW_AbilityPointBlank", false, 'eAbilitySource_Perk', true);
	Template.AdditionalAbilities.AddItem('RpgSingleTap');
//	Template.AdditionalAbilities.AddItem('RpgDoubleTap');

	return Template;
}

// Single Tap - Shooting only one barrel doesn't end the turn
static function X2AbilityTemplate SingleTap()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2AbilityTarget_Single            SingleTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgSingleTap');

	Template.IconImage = "img:///UILibrary_LWSecondariesWOTC.LW_AbilityPointBlank";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_PISTOL_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.bHideOnClassUnlock = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	SingleTarget.bAllowDestructibleObjects=true;
	SingleTarget.bShowAOE = true;
	Template.AbilityTargetStyle = SingleTarget;

	ActionPointCost = new class'X2AbilityCost_QuickdrawActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('SawedOffSingle_DoNotConsumeAllActionsEffect');
	Template.AbilityCosts.AddItem(ActionPointCost);	

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true; // 	

	Template.bAllowFreeFireWeaponUpgrade = true; // Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);
		
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	
	Template.OverrideAbilities.AddItem('PointBlank');

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 3;
	Template.AddTargetEffect(KnockbackEffect);

	Template.bUseAmmoAsChargesForHUD = true;
	Template.bUniqueSource = true;	

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;	
}

// Double Tap - Shoot one barrel, only shoot second if target doesn't die
static function X2AbilityTemplate DoubleTap()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2AbilityTarget_Single            SingleTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgDoubleTap');

	Template.IconImage = "img:///UILibrary_LWSecondariesWOTC.LW_AbilityBothBarrels";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_PISTOL_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                       // color of the icon
	Template.bHideOnClassUnlock = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	SingleTarget.bAllowDestructibleObjects=true;
	SingleTarget.bShowAOE = true;
	Template.AbilityTargetStyle = SingleTarget;

	ActionPointCost = new class'X2AbilityCost_QuickdrawActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('SawedOffDouble_DoNotConsumeAllActionsEffect');
	Template.AbilityCosts.AddItem(ActionPointCost);	

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 2;
	AmmoCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	//  actually charge 1 ammo for this shot. the 2nd shot will charge the extra ammo.
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true; // 	

	Template.bAllowFreeFireWeaponUpgrade = true;

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);
		
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	//Second Shot
	Template.AdditionalAbilities.AddItem('RpgDoubleTap2');
	Template.PostActivationEvents.AddItem('RpgDoubleTap2');
	
	Template.OverrideAbilities.AddItem('BothBarrels');

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 3;
	Template.AddTargetEffect(KnockbackEffect);

	Template.bUseAmmoAsChargesForHUD = true;
	Template.bUniqueSource = true;	

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;	
}

static function X2AbilityTemplate DoubleTap2()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTrigger_EventListener    Trigger;
	local X2Effect_Knockback				KnockbackEffect;

	Template= new(None, string('RpgDoubleTap2')) class'X2AbilityTemplate'; Template.SetTemplateName('RpgDoubleTap2');;;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true; // 	

	// Hit Calculation
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RpgDoubleTap2';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_OriginalTarget;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_rapidfire";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.MergeVisualizationFn = SequentialShot_MergeVisualization;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 3;
	Template.AddTargetEffect(KnockbackEffect);
	
	Template.bShowActivation = true;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;
}


// Deep Pockets - Gain additional charges for Reload Sawed-Off
static function X2AbilityTemplate RpgDeepPockets()
{
	local X2AbilityTemplate 				Template;
	local XMBEffect_AddAbilityCharges 		ChargesEffectCV, ChargesEffectMG, ChargesEffectBM;
	local X2Condition_RequiredWeaponTech	WeaponConditionCV, WeaponConditionMG, WeaponConditionBM;
	
	Template = Passive('RpgDeepPockets', "img:///UILibrary_RPGO.UIPerk_DeepPockets", false);
	
	// conventional
	ChargesEffectCV = new class'XMBEffect_AddAbilityCharges';
	ChargesEffectCV.AbilityNames.AddItem('RpgSawnOffReload');
	ChargesEffectCV.BonusCharges = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("DEEP_POCKETS_CHARGES_CV");
	WeaponConditionCV = new class'X2Condition_RequiredWeaponTech';
	WeaponConditionCV.RelevantSlot = eInvSlot_SecondaryWeapon;
	WeaponConditionCV.RequireWeaponTech = 'conventional';
	ChargesEffectCV.TargetConditions.AddItem(WeaponConditionCV);

	// magnetic
	ChargesEffectMG = new class'XMBEffect_AddAbilityCharges';
	ChargesEffectMG.AbilityNames.AddItem('RpgSawnOffReload');
	ChargesEffectMG.BonusCharges = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("DEEP_POCKETS_CHARGES_MG");
	WeaponConditionMG = new class'X2Condition_RequiredWeaponTech';
	WeaponConditionMG.RelevantSlot = eInvSlot_SecondaryWeapon;
	WeaponConditionMG.RequireWeaponTech = 'magnetic';
	ChargesEffectMG.TargetConditions.AddItem(WeaponConditionMG);
	
	// beam
	ChargesEffectBM = new class'XMBEffect_AddAbilityCharges';
	ChargesEffectBM.AbilityNames.AddItem('RpgSawnOffReload');
	ChargesEffectBM.BonusCharges = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("DEEP_POCKETS_CHARGES_BM");
	WeaponConditionBM = new class'X2Condition_RequiredWeaponTech';
	WeaponConditionBM.RelevantSlot = eInvSlot_SecondaryWeapon;
	WeaponConditionBM.RequireWeaponTech = 'beam';
	ChargesEffectBM.TargetConditions.AddItem(WeaponConditionBM);
	
	Template.AddTargetEffect(ChargesEffectCV);
	Template.AddTargetEffect(ChargesEffectMG);
	Template.AddTargetEffect(ChargesEffectBM);
	
	return Template;
}

// SawedOffOverwatch (working name) - During enemy turns, fire a free reaction shot that can critically hit with your
// sawed-off shotgun weapon at any visible enemy within three tiles who moves or fires. 
// Can only trigger once per turn. The reaction shot uses 1 ammo and only triggers if the sawed-off shotgun is loaded. 
static function X2AbilityTemplate SawedOffOverwatch()
{
	local X2AbilityTemplate 				Template;
	local X2AbilityToHitCalc_StandardAim 	ToHit;

	Template = Attack('RpgSawedOffOverwatch', "img:///'UILibrary_RPGO.UIPerk_SawedOffOverwatch'", false, none, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_None);
	
	HidePerkIcon(Template);
	AddIconPassive(Template);

	ToHit = new class'X2AbilityToHitCalc_StandardAim';
	ToHit.bReactionFire = true;
	ToHit.bAllowCrit = true;
	Template.AbilityToHitCalc = ToHit;
	Template.AbilityTriggers.Length = 0;
	AddMovementTrigger(Template);
	Template.AbilityTargetConditions.AddItem(TargetWithinTiles(3));
	AddCooldown(Template, 1); // can only trigger once per turn

	return Template;
}

// Scrap Metal - Your sawed-off shotgun attacks against robotic enemies pierce 1/2/3 armor and
// kills on robotic enemies with your sawed-off shotgun restore one charge of the Reload Sawed-Off Shotgun ability.
static function X2AbilityTemplate ScrapMetal()
{
	local X2AbilityTemplate 			Template;
	local XMBEffect_ConditionalBonus	PierceEffect;
	local X2Condition_UnitProperty		UnitPropertyCondition;
	
	PierceEffect = new class'XMBEffect_ConditionalBonus';
	PierceEffect.AddArmorPiercingModifier(class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("SCRAP_METAL_PIERCE_CV"), eHit_Success, 'conventional');
	PierceEffect.AddArmorPiercingModifier(class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("SCRAP_METAL_PIERCE_MG"), eHit_Success, 'magnetic');
	PierceEffect.AddArmorPiercingModifier(class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("SCRAP_METAL_PIERCE_BM"), eHit_Success, 'beam');

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeOrganic = true;
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	PierceEffect.AbilityTargetConditions.AddItem(UnitPropertyCondition);
	
	Template = Passive('RpgScrapMetal', "img:///'UILibrary_RPGO.UIPerk_ScrapMetal'", false, PierceEffect);
	Template.AdditionalAbilities.AddItem('RpgScrapMetalTrigger');
	
	return Template;
}	
	
static function X2AbilityTemplate ScrapMetalTrigger()
{
	local X2AbilityTemplate 			Template;
	local XMBEffect_AddAbilityCharges 	ChargesEffect;
	local X2Condition_UnitProperty		UnitPropertyCondition;
	
	ChargesEffect = new class'XMBEffect_AddAbilityCharges';
	ChargesEffect.AbilityNames.AddItem('RpgSawnOffReload');
	ChargesEffect.BonusCharges = 1;// make configurable 
	
	Template = SelfTargetTrigger('RpgScrapMetalTrigger', "img:///'UILibrary_RPGO.UIPerk_ScrapMetal'", false, ChargesEffect, 'KillMail');
	    
	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeOrganic = true;
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	AddTriggerTargetCondition(Template, UnitPropertyCondition);

	Template.bShowActivation = true;
	
	return Template;
}

// Brutality - Killing an organic target with your sawed-off shotgun has a chance to panic nearby organic targets.
static function X2AbilityTemplate Brutality()
{
	local X2AbilityTemplate 				Template;
	local X2AbilityToHitCalc_PercentChance 	ToHitCalc;
	local XMBAbilityTrigger_EventListener 	EventListener;
	local X2AbilityMultiTarget_Radius 		Radius;
	local X2Effect_Persistent 				Effect;
	local X2Condition_PanicOnPod 			PanicCondition;
	//local X2AbilityTarget_Single 			PrimaryTarget;
	local X2Condition_UnitProperty 			TargetCondition, UnitPropertyCondition;

	Template = TargetedDebuff('RpgBrutality', "img:///'UILibrary_RPGO.UIPerk_Brutality'", false, none,, eCost_None);
	Template.bSkipFireAction = true;
	Template.SourceMissSpeech = '';
	Template.SourceHitSpeech = '';

	PanicCondition = new class'X2Condition_PanicOnPod';
	PanicCondition.MaxPanicUnitsPerPod = 2;

	Effect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	Effect.TargetConditions.AddItem(PanicCondition);
	Effect.EffectName = class'X2AbilityTemplateManager'.default.PanickedName;
//	Effect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
//  Effect.SetDisplayInfo(ePerkBuff_Penalty, "Panicking", "This unit is losing control of the situation", "img:///UILibrary_PerkIcons.panicky_icon_here");
	
	Template.AddTargetEffect(Effect);
	Template.AddMultiTargetEffect(Effect);
	
	Template.AbilityTriggers.Length = 0;
	EventListener = new class'XMBAbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'KillMail';
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeRobotic = true;
	TargetCondition.ExcludeFriendlyToSource = true;
	TargetCondition.ExcludeHostileToSource = false;
	
	Template.AbilityTargetConditions.Length = 0;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	Template.AbilityShooterConditions.Length = 0;

	Template.AbilityMultiTargetConditions.Length = 0;
	Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);
	
	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.fTargetRadius = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigFloatValue("BRUTALITY_TILE_RADIUS");
	Radius.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = Radius;
		
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	AddTriggerTargetCondition(Template, UnitPropertyCondition);
	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);
	
	HidePerkIcon(Template);
	AddIconPassive(Template);

	ToHitCalc = new class'X2AbilityToHitCalc_PercentChance';
	ToHitCalc.PercentToHit = class'RPGO_Helper'.static.GetAbilityConfig().GetConfigIntValue("BRUTALITY_PANIC_CHANCE");
	Template.AbilityToHitCalc = ToHitCalc;

	Template.bShowActivation = true;

	return Template;
}

// Ruthless - Killing a stunned, panicked or mind-controlled enemy with your sawed-off shotgun refunds one action point. 
// There is not limit to the number of activations per turn.
static function X2AbilityTemplate Ruthless()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Ruthless               		ActionPointEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgRuthless');
	Template.IconImage = "img:///'UILibrary_RPGO.UIPerk_Ruthless'";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ActionPointEffect = new class'X2Effect_Ruthless';
	ActionPointEffect.BuildPersistentEffect(1, true, false, false);
	ActionPointEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(ActionPointEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!
	
	return Template;
}
