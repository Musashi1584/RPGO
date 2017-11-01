class X2Ability_UpgradeAbilitySet extends XMBAbility
	dependson (XComGameStateContext_Ability) config(ExtendedUpgrades);

var config int STOCK_UPGRADE_BSC;
var config int STOCK_UPGRADE_ADV;
var config int STOCK_UPGRADE_SUP;

var config int AIM_UPGRADE_BSC;
var config int AIM_UPGRADE_ADV;
var config int AIM_UPGRADE_SUP;

var config int HAIR_TRIGGER_CHANCE_BSC;
var config int HAIR_TRIGGER_CHANCE_ADV;
var config int HAIR_TRIGGER_CHANCE_SUP;

var config int HAIR_TRIGGER_AIM_BSC;
var config int HAIR_TRIGGER_AIM_ADV;
var config int HAIR_TRIGGER_AIM_SUP;

var config int AUTO_LOADER_CHANCE_BSC;
var config int AUTO_LOADER_CHANCE_ADV;
var config int AUTO_LOADER_CHANCE_SUP;

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

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(StockAttachment(default.BasicStockAbilityName, default.STOCK_UPGRADE_BSC));
	Templates.AddItem(StockAttachment(default.AdvancedStockAbilityName, default.STOCK_UPGRADE_ADV));
	Templates.AddItem(StockAttachment(default.SuperiorStockAbilityName, default.STOCK_UPGRADE_SUP));

	Templates.AddItem(ScopeAttachment(default.BasicScopeAbilityName, default.AIM_UPGRADE_BSC));
	Templates.AddItem(ScopeAttachment(default.AdvancedScopeAbilityName, default.AIM_UPGRADE_ADV));
	Templates.AddItem(ScopeAttachment(default.SuperiorScopeAbilityName, default.AIM_UPGRADE_SUP));
	
	Templates.AddItem(TriggerAttachment(default.BasicHairTriggerAbilityName, default.HAIR_TRIGGER_AIM_BSC));
	Templates.AddItem(TriggerAttachment(default.AdvancedHairTriggerAbilityName, default.HAIR_TRIGGER_AIM_ADV));
	Templates.AddItem(TriggerAttachment(default.SuperiorHairTriggerAbilityName, default.HAIR_TRIGGER_AIM_SUP));
	
	Templates.AddItem(AutoLoaderAttachment(default.BasicAutoLoaderAbilityName));
	Templates.AddItem(AutoLoaderAttachment(default.AdvancedAutoLoaderAbilityName));
	Templates.AddItem(AutoLoaderAttachment(default.SuperiorAutoLoaderAbilityName));

	Templates.AddItem(EleriumCoating_Bsc_EU_Ability());
	Templates.AddItem(EleriumCoating_Adv_EU_Ability());
	Templates.AddItem(EleriumCoating_Sup_EU_Ability());

	Templates.AddItem(OpticScopeRangeModifier());
	
	return Templates;
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
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;

	Template = PurePassive(TemplateName, "", false, 'eAbilitySource_Item', false);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'Reload';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'X2Ability_UpgradeAbilitySet'.static.ReloadListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	
	return Template;
}

static function EventListenerReturn ReloadListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability SourceAbilityState, AutoloaderAbilityState;
	local XComGameState_Unit SourceUnit;
	local StateObjectReference AutoLoaderAbilityRef;
	local int Chance, Random;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	SourceAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	SourceUnit = XComGameState_Unit(EventSource);

	if (SourceUnit != none)
	{
		AutoLoaderAbilityRef = SourceUnit.FindAbility(default.SuperiorAutoLoaderAbilityName, SourceAbilityState.SourceWeapon);
		if (AutoLoaderAbilityRef.ObjectID > 0)
		{
			Chance = default.AUTO_LOADER_CHANCE_SUP;
		}

		if (AutoLoaderAbilityRef.ObjectID == 0)
		{
			AutoLoaderAbilityRef = SourceUnit.FindAbility(default.AdvancedAutoLoaderAbilityName, SourceAbilityState.SourceWeapon);
			if (AutoLoaderAbilityRef.ObjectID > 0)
			{
				Chance = default.AUTO_LOADER_CHANCE_ADV;
			}
		}

		if (AutoLoaderAbilityRef.ObjectID == 0)
		{
			AutoLoaderAbilityRef = SourceUnit.FindAbility(default.BasicAutoLoaderAbilityName, SourceAbilityState.SourceWeapon);
			if (AutoLoaderAbilityRef.ObjectID > 0)
			{
				Chance = default.AUTO_LOADER_CHANCE_BSC;
			}
		}
	}
	
	`LOG(SourceUnit.GetMyTemplateName() @ SourceAbilityState.GetMyTemplateName() @ SourceAbilityState.GetSourceWeapon().GetMyTemplateName() @ AutoLoaderAbilityRef.ObjectID @ Chance,, 'ExtendedUpgrades');
	
	if (SourceAbilityState != none &&
		AbilityContext != none &&
		AutoLoaderAbilityRef.ObjectID > 0)
	{
		Random = Rand(101) + 1; // 1-100
		if (Chance == 0 || Random >= Chance)
		{
			`LOG(GetFuncName() @ Chance @ "% failed, rolled" @ Random,, 'ExtendedUpgrades');
			return ELR_NoInterrupt;
		}

		SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
		AutoloaderAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AutoLoaderAbilityRef.ObjectID));
		AutoloaderAbilityState.AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.SourceObject, false);
		`LOG("Refund ActionPoint for" @ SourceAbilityState.GetMyTemplateName() @ "rolled" @ Random @ "chance" @ Chance,, 'ExtendedUpgrades');
	}
	return ELR_NoInterrupt;
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
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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

static function X2AbilityTemplate ScopeAttachment(name TemplateName, int Bonus)
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_EU_ModifyNonReactionFire	ScopeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	
	Template.AbilitySourceName = 'eAbilitySource_Item';

	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bIsPassive = true;
	Template.bCrossClassEligible = false;
	
	ScopeEffect=new class'X2Effect_EU_ModifyNonReactionFire';
	ScopeEffect.BuildPersistentEffect(1,true,false,false);
	ScopeEffect.To_Hit_Modifier = Bonus;
	ScopeEffect.FriendlyName = Template.LocFriendlyName;
	Template.AddTargetEffect(ScopeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.AdditionalAbilities.AddItem('OpticScopeRangeModifier');

	return Template;
}

static function X2AbilityTemplate OpticScopeRangeModifier()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ScopeRange					AimModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'OpticScopeRangeModifier');
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	
	AimModifier = new class 'X2Effect_ScopeRange';
	AimModifier.BuildPersistentEffect (1, true, false);
	//AimModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	
	Template.AddTargetEffect (AimModifier);
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