class X2Ability_ABB extends XMBAbility config(RPG);

var config int DRIVEN_BY_VENGEANCE_WILL;
var config int DRIVEN_BY_VENGEANCE_AIM;
var config int DRIVEN_BY_VENGEANCE_CRIT;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(DrivenByVengeance());

	return Templates;
}

static function X2AbilityTemplate DrivenByVengeance()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local XMBEffect_PermanentStatChange Effect;
	local X2Effect_PersistentStatChange Effect2;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgDrivenByVengeance');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatstims";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeAlive = false;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	Effect = new class'XMBEffect_PermanentStatChange';
	Effect.AddStatChange(eStat_Will, default.DRIVEN_BY_VENGEANCE_WILL);
	
	Effect2 = new class'X2Effect_PersistentStatChange';
	Effect2.EffectName = 'Vengeant';
	Effect2.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Effect2.DuplicateResponse = eDupe_Refresh;
	Effect2.AddPersistentStatChange(eStat_Offense, default.DRIVEN_BY_VENGEANCE_AIM);
	Effect2.AddPersistentStatChange(eStat_CritChance, default.DRIVEN_BY_VENGEANCE_CRIT);
	Effect2.TargetConditions.AddItem(default.LivingFriendlyTargetProperty);
	Effect2.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	
	Template.AddTargetEffect(Effect);
	Template.AddTargetEffect(Effect2);

	//Effect.VisualizationFn = EffectFlyOver_Visualization;

	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;

	Template.FrameAbilityCameraType = eCameraFraming_Always;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}