class X2Ability_Patches extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(ShotgunDamageModifierRange());
	Templates.AddItem(ShotgunDamageModifierCoverType());
	Templates.AddItem(AutoFireOverwatch());
	Templates.AddItem(AutoFireShot());
	Templates.AddItem(RemoveSquadSightOnMove());

	return Templates;
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
	return Template;
}

static function X2AbilityTemplate AutoFireShot()
{
	local X2AbilityTemplate Template;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('AutoFireShot');
	//Template.IconImage = "img:///UILibrary_RPG.UIPerk_CannonShot";

	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).iNumPoints = 2;
	Template.OverrideAbilities.AddItem('StandardShot');

	return Template;
}

static function X2AbilityTemplate AutoFireOverwatch()
{
	local X2AbilityTemplate Template;

	Template = class'X2Ability_DefaultAbilitySet'.static.AddOverwatchAbility('AutoFireOverwatch');
	//Template.IconImage = "img:///UILibrary_RPG.UIPerk_CannonOverwatch";

	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).iNumPoints = 2;
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