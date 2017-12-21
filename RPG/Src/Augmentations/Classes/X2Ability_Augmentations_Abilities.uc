class X2Ability_Augmentations_Abilities extends XMBAbility config (Augmentations);

var config int AUGMENTATION_BASE_MITIGATION_AMOUNT;
var config int AUGMENTED_SPEED_COOLDOWN;
var config int CYBER_SKULL_CRIT_DEFENSE;
var config int AUGMENTATION_ARMS_SHIELD_HP;

var config int NANO_COATING_SHIELD_HP;
var config int NANO_COATING_SHIELD_REGEN_TURN;
var config int NANO_COATING_SHIELD_REGEN_MAX;

var config int WEAKPOINTANALYZER_ARMOR_PIERCE;
var config int WEAKPOINTANALYZER_CRIT_CHANCE;
var config int WEAKPOINTANALYZER_CRIT_DAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(SelfRepairingNanoCoating('NanoCoating', default.NANO_COATING_SHIELD_HP, default.NANO_COATING_SHIELD_REGEN_TURN, default.NANO_COATING_SHIELD_REGEN_MAX));
	Templates.AddItem(WeakpointAnalyzer('WeakpointAnalyzer', default.WEAKPOINTANALYZER_ARMOR_PIERCE, default.WEAKPOINTANALYZER_CRIT_CHANCE, default.WEAKPOINTANALYZER_CRIT_DAMAGE));

	Templates.AddItem(AugmentedHead());
	Templates.AddItem(AugmentedShield());
	Templates.AddItem(AugmentedSpeed());
	Templates.AddItem(ExMachina());
	Templates.AddItem(CyberPunch());
	Templates.AddItem(CyberPunchAnimSet());
	Templates.AddItem(AugmentationBaseStats());
	Templates.AddItem(ClawsSlash());

	return Templates;
}

static function X2AbilityTemplate WeakpointAnalyzer(name AbilityName, int ArmorPierce, int CritChance, int CritDamage)
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddArmorPiercingModifier(ArmorPierce);
	Effect.AddToHitModifier(CritChance, eHit_Crit);
	Effect.AddDamageModifier(CritDamage, eHit_Crit);
	Effect.AbilityTargetConditions.AddItem(new class 'X2Condition_TargetAutopsy');

	return Passive('AbilityName', "img:///UILibrary_RPG.LW_AbilityVitalPointTargeting", false, Effect);
}


static function X2AbilityTemplate SelfRepairingNanoCoating(name AbilityName, int ShieldHP, int HealAmount, int MaxHealAmount)
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentStatChange			PersistentStatChangeEffect;
	local X2Effect_Regeneration					RegenerationEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//buff
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, ShieldHP);
	Template.AddTargetEffect(PersistentStatChangeEffect);
	
    //Build the regeneration effect
	RegenerationEffect = new class'X2Effect_Regeneration';
	RegenerationEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	RegenerationEffect.HealAmount = HealAmount;
	RegenerationEffect.MaxHealAmount = MaxHealAmount;
	RegenerationEffect.HealthRegeneratedName = name(AbilityName $ "Effect");
	Template.AddTargetEffect(RegenerationEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate AugmentedHead()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Resilience				CritDefEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AugmentedHead');
	Template.IconImage = "img:///UILibrary_Augmentations.UIPerk_CyberSkull";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = true;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	CritDefEffect = new class'X2Effect_Resilience';
	CritDefEffect.CritDef_Bonus = default.CYBER_SKULL_CRIT_DEFENSE;
	CritDefEffect.BuildPersistentEffect (1, true, false, false);
	Template.AddTargetEffect(CritDefEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AugmentedShield()
{
	local X2AbilityTemplate					Template;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AugmentedShield');
	Template.IconImage = "img:///UILibrary_Augmentations.UIPerk_AugmentedShield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = true;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, default.AUGMENTATION_ARMS_SHIELD_HP);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AugmentedSpeed()
{
	local X2AbilityTemplate							Template;
	local X2Effect_Augmentations_GrantActionPoints	GrantActionPointEffect;
	local X2Effect_RemoveEffects					RemoveEffects;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2Effect_Speed							SpeedEffect;
	local X2AbilityCooldown							Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AugmentedSpeed');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;	
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_parkour";
	Template.Hostility = eHostility_Neutral;
	Template.AbilityConfirmSound = "TacticalUI_Activate_Ability_Wraith_Armor";
	Template.bDisplayInUITacticalText = true;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.AUGMENTED_SPEED_COOLDOWN;
	Template.AbilityCooldown = Cooldown;


	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	//ActionPointCost.bConsumeAllPoints = false;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	GrantActionPointEffect = new class 'X2Effect_Augmentations_GrantActionPoints';
	GrantActionPointEffect.EffectName = 'GrantActionPointEffect';
	GrantActionPointEffect.BuildPersistentEffect(1, false, true, , eGameRule_PlayerTurnBegin);
	GrantActionPointEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,true,,Template.AbilitySourceName);
	GrantActionPointEffect.bRemoveWhenTargetDies = true;
	GrantActionPointEffect.DuplicateResponse = eDupe_Ignore;
	GrantActionPointEffect.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
	Template.AddTargetEffect(GrantActionPointEffect);

	SpeedEffect = new class'X2Effect_Speed';
	SpeedEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	SpeedEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, , , Template.AbilitySourceName);
	Template.AddTargetEffect(SpeedEffect);

 	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';
	Template.CinescriptCameraType = "Psionic_FireAtUnit";
	Template.ActivationSpeech = 'CombatStim';
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate ExMachina()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;
	local X2Effect_DamageImmunity           DamageImmunity;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ExMachina');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_divinearmor";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	DamageImmunity = new class'X2Effect_DamageImmunity';
	DamageImmunity.EffectName = 'ExMachina';
	DamageImmunity.DuplicateResponse = eDupe_Ignore;
	DamageImmunity.ImmuneTypes.AddItem('Fire');
	DamageImmunity.ImmuneTypes.AddItem('Poison');
	DamageImmunity.ImmuneTypes.AddItem('Acid');
	DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	DamageImmunity.BuildPersistentEffect(1, true, false, false);
	DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	DamageImmunity.TargetConditions.AddItem(new class'X2Condition_Cyborg');
	Template.AddTargetEffect(DamageImmunity);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate CyberPunch()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Effect_ApplyWeaponDamage		DamageEffect;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('CyberPunch');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_beserker_punch";
	
	Template.CustomFireAnim = 'FF_MeleeCyberPunchA';
	Template.CustomFireKillAnim = 'FF_MeleeCyberPunchA';
	Template.CustomMovingFireAnim = 'MV_MeleeCyberPunchA';
	Template.CustomMovingFireKillAnim =  'MV_MeleeCyberPunchA';
	Template.CustomMovingTurnLeftFireAnim = 'MV_RunTurn90LeftMeleeCyberPunchA';
	Template.CustomMovingTurnLeftFireKillAnim = 'MV_RunTurn90LeftMeleeCyberPunchA';
	Template.CustomMovingTurnRightFireAnim = 'MV_RunTurn90RightMeleeCyberPunchA';
	Template.CustomMovingTurnRightFireKillAnim = 'MV_RunTurn90RightMeleeCyberPunchA';

	Template.AbilityTargetEffects.Length = 0;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 20;
	KnockbackEffect.bKnockbackDestroysNonFragile = true;
	KnockbackEffect.OnlyOnDeath = false;
	Template.AddTargetEffect(KnockbackEffect);
	Template.bOverrideMeleeDeath = true;

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(DamageEffect);

	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true));
	
	Template.AdditionalAbilities.AddItem('CyberPunchAnimSet');

	return Template;
}

static function X2AbilityTemplate CyberPunchAnimSet()
{
	local X2AbilityTemplate						Template;
	local X2Effect_AdditionalAnimSets			AnimSets;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'CyberPunchAnimSet');

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.EffectName = 'CyberPunchAnimsets';
	AnimSets.AddAnimSetWithPath("AnimationsMaster_Augmentations.Anims.AS_CyberPunch");
	AnimSets.BuildPersistentEffect(1, true, false, false, eGameRule_TacticalGameStart);
	AnimSets.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(AnimSets);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate AugmentationBaseStats()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AugmentationBaseStats');

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bIsPassive = true;
	Template.bCrossClassEligible = false;
	
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.AUGMENTATION_BASE_MITIGATION_AMOUNT);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bShowActivation = true;

	return Template;
}

static function X2AbilityTemplate ClawsSlash()
{
	local X2AbilityTemplate				Template;
	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2AbilityCooldown				Cooldown;
	local int i;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('ClawsSlash');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_chryssalid_slash";

	Template.bFrameEvenWhenUnitIsHidden = true;
	
	for (i = 0; i < Template.AbilityCosts.Length; ++i)
	{
		ActionPointCost = X2AbilityCost_ActionPoints(Template.AbilityCosts[i]);
		if (ActionPointCost != none)
			ActionPointCost.bConsumeAllPoints = false;
	}

	return Template;
}
