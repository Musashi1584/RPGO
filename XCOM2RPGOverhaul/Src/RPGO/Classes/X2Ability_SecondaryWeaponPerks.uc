class X2Ability_SecondaryWeaponPerks extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
//	Sawed-Off Shotgun

//	Arcthrower
	Templates.AddItem(RapidStun());
	Templates.AddItem(ThatsCloseEnough());
	Templates.AddItem(SpareBattery());

	return Templates;
}

// #######################################################################################
// -------------------- ARCTHROWER  ------------------------------------------------------
// #######################################################################################

// Next Arcthrower action is free
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
	Template = SelfTargetActivated('RpgRapidStun', "img:///UILibrary_RPG.UIPerk_RapidStun", true, Effect,, eCost_Free);
	AddCooldown(Template, class'Config_Manager'.static.GetConfigIntValue("RAPID_STUN_COOLDOWN"));

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

	Template = Attack('RpgThatsCloseEnough', "img:///Texture2D'UILibrary_RPG.UIPerk_ThatsCloseEnough'", false, StunnedEffect, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_None);
	
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

	Template.IconImage = "img:///UILibrary_RPG.UIPerk_SpareBattery";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = class'Config_Manager'.static.GetConfigIntValue("SPARE_BATTERY_COOLDOWN");
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