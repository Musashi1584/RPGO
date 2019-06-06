class X2Ability_UpgradeAbilitySet extends XMBAbility
	dependson (XComGameStateContext_Ability) config(ExtendedUpgrades);

var config int STOCK_UPGRADE_BSC;
var config int STOCK_UPGRADE_ADV;
var config int STOCK_UPGRADE_SUP;

var config int HAIR_TRIGGER_CHANCE_BSC;
var config int HAIR_TRIGGER_CHANCE_ADV;
var config int HAIR_TRIGGER_CHANCE_SUP;

var config int HAIR_TRIGGER_AIM_BSC;
var config int HAIR_TRIGGER_AIM_ADV;
var config int HAIR_TRIGGER_AIM_SUP;

var config int AUTO_LOADER_MAX_AMMO_BSC;
var config int AUTO_LOADER_MAX_AMMO_ADV;
var config int AUTO_LOADER_MAX_AMMO_SUP;

var config array<int> SCOPE_RANGE_CHANGE_BSC;
var config array<int> SCOPE_RANGE_CHANGE_ADV;
var config array<int> SCOPE_RANGE_CHANGE_SUP;

var config array<int> LASER_SIGHT_CHANGE_BSC;
var config array<int> LASER_SIGHT_CHANGE_ADV;
var config array<int> LASER_SIGHT_CHANGE_SUP;

var name BasicScopeAbilityName;
var name AdvancedScopeAbilityName;
var name SuperiorScopeAbilityName;

var name BasicHairTriggerAbilityName;
var name AdvancedHairTriggerAbilityName;
var name SuperiorHairTriggerAbilityName;

var name BasicAutoLoaderAbilityName;
var name AdvancedAutoLoaderAbilityName;
var name SuperiorAutoLoaderAbilityName;

var name BasicStockAbilityName;
var name AdvancedStockAbilityName;
var name SuperiorStockAbilityName;

var name BasicLaserSightAbilityName;
var name AdvancedLaserSightAbilityName;
var name SuperiorLaserSightAbilityName;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(StockAttachment(default.BasicStockAbilityName, default.STOCK_UPGRADE_BSC));
	Templates.AddItem(StockAttachment(default.AdvancedStockAbilityName, default.STOCK_UPGRADE_ADV));
	Templates.AddItem(StockAttachment(default.SuperiorStockAbilityName, default.STOCK_UPGRADE_SUP));

	Templates.AddItem(ScopeAttachment(default.BasicLaserSightAbilityName, default.LASER_SIGHT_CHANGE_BSC));
	Templates.AddItem(ScopeAttachment(default.AdvancedLaserSightAbilityName, default.LASER_SIGHT_CHANGE_ADV));
	Templates.AddItem(ScopeAttachment(default.SuperiorLaserSightAbilityName, default.LASER_SIGHT_CHANGE_SUP));

	Templates.AddItem(ScopeAttachment(default.BasicScopeAbilityName, default.SCOPE_RANGE_CHANGE_BSC));
	Templates.AddItem(ScopeAttachment(default.AdvancedScopeAbilityName, default.SCOPE_RANGE_CHANGE_ADV));
	Templates.AddItem(ScopeAttachment(default.SuperiorScopeAbilityName, default.SCOPE_RANGE_CHANGE_SUP));
	
	Templates.AddItem(TriggerAttachment(default.BasicHairTriggerAbilityName, default.HAIR_TRIGGER_AIM_BSC));
	Templates.AddItem(TriggerAttachment(default.AdvancedHairTriggerAbilityName, default.HAIR_TRIGGER_AIM_ADV));
	Templates.AddItem(TriggerAttachment(default.SuperiorHairTriggerAbilityName, default.HAIR_TRIGGER_AIM_SUP));
	
	Templates.AddItem(AutoLoaderAttachment(default.BasicAutoLoaderAbilityName));
	Templates.AddItem(AutoLoaderAttachment(default.AdvancedAutoLoaderAbilityName));
	Templates.AddItem(AutoLoaderAttachment(default.SuperiorAutoLoaderAbilityName));

	Templates.AddItem(EleriumCoating_Bsc_EU_Ability());
	Templates.AddItem(EleriumCoating_Adv_EU_Ability());
	Templates.AddItem(EleriumCoating_Sup_EU_Ability());
	
	return Templates;
}

static function X2AbilityTemplate SilencerAttachement(name TemplateName, int Bonus)
{
	local X2AbilityTemplate					Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bIsPassive = true;
	Template.bCrossClassEligible = false;


	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	return Template;
}

static function X2AbilityTemplate StockAttachment(name TemplateName, int Bonus)
{
	local X2AbilityTemplate					Template;
	local X2Effect_EU_ModifyReactionFire	StockEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);	

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bIsPassive = true;
	Template.bCrossClassEligible = false;
	
	StockEffect = new class'X2Effect_EU_ModifyReactionFire';
	StockEffect.BuildPersistentEffect(1,true,false,false);
	StockEffect.To_Hit_Modifier = Bonus;
	StockEffect.FriendlyName = Template.LocFriendlyName;
	Template.AddTargetEffect(StockEffect);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	return Template;
}

static function X2AbilityTemplate AutoLoaderAttachment(name TemplateName)
{
	local X2AbilityTemplate                 Template;	
	local X2Condition_UnitProperty          ShooterPropertyCondition;
	local X2Condition_AbilitySourceWeapon   WeaponCondition;
	local X2AbilityTrigger_EventListener	EventTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	
	Template.bDontDisplayInAbilitySummary = false;
	
	ShooterPropertyCondition = new class'X2Condition_UnitProperty';	
	ShooterPropertyCondition.ExcludeDead = true;                    //Can't reload while dead
	Template.AbilityShooterConditions.AddItem(ShooterPropertyCondition);
	WeaponCondition = new class'X2Condition_AbilitySourceWeapon';
	WeaponCondition.WantsReload = true;
	Template.AbilityShooterConditions.AddItem(WeaponCondition);
	
	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'PlayerTurnBegun';
	EventTrigger.ListenerData.Filter = eFilter_Player;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_reload";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.RELOAD_PRIORITY;
	Template.bNoConfirmationWithHotKey = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.BuildNewGameStateFn = AutoloaderAbility_BuildGameState;
	Template.BuildVisualizationFn = AutoloaderAbility_BuildVisualization;

	Template.Hostility = eHostility_Neutral;

	Template.CinescriptCameraType="GenericAccentCam";

	return Template;	
}

simulated function XComGameState AutoloaderAbility_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState, NewWeaponState;
	local UnitValue Reloads;
	local int MaxReloads;

	`LOG(GetFuncName(),, 'ExtendedUpgrades');

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);	
	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID( AbilityContext.InputContext.AbilityRef.ObjectID ));

	WeaponState = AbilityState.GetSourceWeapon();
	NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', WeaponState.ObjectID));

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));	
	UnitState.GetUnitValue('AutoLoaderReloads', Reloads);

	if (AbilityState.GetMyTemplateName() == default.SuperiorAutoLoaderAbilityName)
	{
		MaxReloads = default.AUTO_LOADER_MAX_AMMO_SUP;
	}

	if (AbilityState.GetMyTemplateName() == default.AdvancedAutoLoaderAbilityName)
	{
		MaxReloads = default.AUTO_LOADER_MAX_AMMO_ADV;
	}

	if (AbilityState.GetMyTemplateName() == default.BasicAutoLoaderAbilityName)
	{
		MaxReloads = default.AUTO_LOADER_MAX_AMMO_BSC;
	}

	`LOG(GetFuncName() @ AbilityState.GetMyTemplateName() @ "MaxReloads" @ MaxReloads,, 'ExtendedUpgrades');

	if (NewWeaponState.Ammo < NewWeaponState.GetClipSize() && Reloads.fValue < MaxReloads)
	{
		NewWeaponState.Ammo += 1;
		UnitState.SetUnitFloatValue('AutoLoaderReloads', Reloads.fValue += 1.0, eCleanup_BeginTactical);
	}
	
	NewGameState.AddStateObject(UnitState);
	NewGameState.AddStateObject(NewWeaponState);

	return NewGameState;	
}

simulated function AutoloaderAbility_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference          ShootingUnitRef;	
	local X2Action_PlayAnimation		PlayAnimation;

	local VisualizationActionMetadata   InitData;
	local VisualizationActionMetadata   BuildData;

	local XComGameState_Ability Ability;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	ShootingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	BuildData = InitData;
	BuildData.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	BuildData.VisualizeActor = History.GetVisualizer(ShootingUnitRef.ObjectID);
					
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(BuildData, Context));
	PlayAnimation.Params.AnimName = 'HL_Reload';

	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildData, Context));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Ability.GetMyTemplate().LocFriendlyName, Ability.GetMyTemplate().ActivationSpeech, eColor_Good);
	//****************************************************************************************
}

static function X2AbilityTemplate TriggerAttachment(name TemplateName, int HitBonus)
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Condition_Visibility VisibilityCondition;
	local X2AbilityToHitCalc_StandardAim Aim;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	// Icon Properties
	//Template.IconImage = IconImage;
	Template.ShotHUDPriority = default.AUTO_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Item'; 
	Template.Hostility = eHostility_Offensive;

	// Create the template using a helper function
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'HairTriggerShot';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'X2Ability_UpgradeAbilitySet'.static.HairTriggerShotListener;
	Template.AbilityTriggers.AddItem(Trigger);

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	//AddIconPassive(Template);

	// Require that the activated ability use the weapon associated with this ability
	//AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	Template.AddShooterEffectExclusions();

	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;

	Template.AbilityTargetConditions.AddItem(VisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_None));	

	AddAmmoCost(Template, 1);

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.bAllowFreeFireWeaponUpgrade = true;

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);
	
	Aim = new class'X2AbilityToHitCalc_StandardAim';
	Aim.BuiltInHitMod = HitBonus;
	Template.AbilityToHitCalc = Aim;
	
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;
		
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	

	Template.AssociatedPassives.AddItem('HoloTargeting');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bShowActivation = true;

	Template.bCrossClassEligible = false;

	return Template;
}


static function EventListenerReturn HairTriggerShotListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability SourceAbilityState, HairTriggerAbilityState;
	local XComGameState_Unit SourceUnit;
	local StateObjectReference HairTriggerShotAbilityRef;
	local int Chance, Random;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	SourceAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	SourceUnit = XComGameState_Unit(EventSource);

	if (SourceUnit != none)
	{
		HairTriggerShotAbilityRef = SourceUnit.FindAbility(default.SuperiorHairTriggerAbilityName, SourceAbilityState.SourceWeapon);
		if (HairTriggerShotAbilityRef.ObjectID > 0)
		{
			Chance = default.HAIR_TRIGGER_CHANCE_SUP;
		}

		if (HairTriggerShotAbilityRef.ObjectID == 0)
		{
			HairTriggerShotAbilityRef = SourceUnit.FindAbility(default.AdvancedHairTriggerAbilityName, SourceAbilityState.SourceWeapon);
			if (HairTriggerShotAbilityRef.ObjectID > 0)
			{
				Chance = default.HAIR_TRIGGER_CHANCE_ADV;
			}
		}

		if (HairTriggerShotAbilityRef.ObjectID == 0)
		{
			HairTriggerShotAbilityRef = SourceUnit.FindAbility(default.BasicHairTriggerAbilityName, SourceAbilityState.SourceWeapon);
			if (HairTriggerShotAbilityRef.ObjectID > 0)
			{
				Chance = default.HAIR_TRIGGER_CHANCE_BSC;
			}
		}
	}
	
	`LOG(SourceUnit.GetMyTemplateName() @ SourceAbilityState.GetMyTemplateName() @ SourceAbilityState.GetSourceWeapon().GetMyTemplateName() @ HairTriggerShotAbilityRef.ObjectID @ Chance,, 'ExtendedUpgrades');

	if (SourceAbilityState != none &&
		AbilityContext != none &&
		HairTriggerShotAbilityRef.ObjectID > 0 &&
		(AbilityContext.IsResultContextMiss() || AbilityContext.ResultContext.HitResult == eHit_Graze))
	{
		Random = Rand(101) + 1; // 1-100
		if (Chance == 0 || Random >= Chance)
		{
			`LOG("HairTriggerShot" @ Chance @ "% failed, rolled" @ Random,, 'ExtendedUpgrades');
			return ELR_NoInterrupt;
		}

		HairTriggerAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(HairTriggerShotAbilityRef.ObjectID));
		HairTriggerAbilityState.AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.PrimaryTarget, false);
		`LOG("Trigger" @ SourceAbilityState.GetMyTemplateName() @ "against" @ AbilityContext.InputContext.PrimaryTarget.ObjectID @ "rolled" @ Random @ "chance" @ Chance,, 'ExtendedUpgrades');
	}
	return ELR_NoInterrupt;
}

static function X2AbilityTemplate ScopeAttachment(name TemplateName, array<int> BonusRange)
{
	local X2AbilityTemplate						Template;
	local X2Effect_Scope						AimModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	
	AimModifier = new class 'X2Effect_Scope';
	AimModifier.SCOPE_RANGE_CHANGE = BonusRange;
	AimModifier.BuildPersistentEffect (1, true, false, false, eGameRule_PlayerTurnBegin);
	AimModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(AimModifier);

	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate EleriumCoating_Bsc_EU_Ability()
{
	
}

static function X2AbilityTemplate EleriumCoating_Adv_EU_Ability()
{
	
}

static function X2AbilityTemplate EleriumCoating_Sup_EU_Ability()
{
	
}

defaultproperties
{
	BasicScopeAbilityName = "Scope_EU_Bsc_Ability"
	AdvancedScopeAbilityName = "Scope_EU_Adv_Ability"
	SuperiorScopeAbilityName = "Scope_EU_Sup_Ability"

	BasicLaserSightAbilityName = "LaserSight_EU_Bsc_Ability"
	AdvancedLaserSightAbilityName = "LaserSight_EU_Adv_Ability"
	SuperiorLaserSightAbilityName = "LaserSight_EU_Sup_Ability"

	BasicHairTriggerAbilityName = "Hair_Trigger_EU_Bsc_Ability"
	AdvancedHairTriggerAbilityName = "Hair_Trigger_EU_Adv_Ability"
	SuperiorHairTriggerAbilityName = "Hair_Trigger_EU_Sup_Ability"

	BasicAutoLoaderAbilityName="AutoLoader_EU_Bsc_Ability"
	AdvancedAutoLoaderAbilityName="AutoLoader_EU_Adv_Ability"
	SuperiorAutoLoaderAbilityName="AutoLoader_EU_Sup_Ability"

	BasicStockAbilityName = "Stock_EU_Bsc_Ability"
	AdvancedStockAbilityName = "Stock_EU_Adv_Ability"
	SuperiorStockAbilityName = "Stock_EU_Sup_Ability"
}