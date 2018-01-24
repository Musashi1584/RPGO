class X2Ability_Augmentations_Abilities extends XMBAbility config (Augmentations);

var config int CYBERPUNCH_COOLDOWN;
var config int AUGMENTATION_BASE_MITIGATION_AMOUNT;
var config int AUGMENTATION_BASE_WILL_LOSS;
var config int AUGMENTED_SPEED_COOLDOWN;
var config int CYBER_SKULL_CRIT_DEFENSE;
var config int AUGMENTATION_ARMS_SHIELD_HP;

var config int NANO_COATING_SHIELD_HP;
var config int NANO_COATING_SHIELD_REGEN_TURN;
var config int NANO_COATING_SHIELD_REGEN_MAX;

var config int WEAKPOINTANALYZER_ARMOR_PIERCE;
var config int WEAKPOINTANALYZER_CRIT_CHANCE;
var config int WEAKPOINTANALYZER_CRIT_DAMAGE;

var config int CYBER_LEGS_MOBILITY_BONUS_MK1;
var config int CYBER_LEGS_DODGE_BONUS_MK1;
var config int CYBER_LEGS_MOBILITY_BONUS_MK2;
var config int CYBER_LEGS_DODGE_BONUS_MK2;

var config float HARDENED_DAMAGE_REDUCTION_PCT;

var config int NEURAL_GUNLINK_HIT_BONUS;
var config int NEURAL_TACTICAL_PROCESSOR_HIT_BONUS;
var config int NEURAL_TACTICAL_PROCESSOR_BONUS_PER_SQUADMATE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CarryHeavyWeapons());
	Templates.AddItem(NeuralTacticalProcessor());
	Templates.AddItem(NeuralGunLink());
	Templates.AddItem(CyberLegsJump('CyberJumpLegsMK1', default.CYBER_LEGS_MOBILITY_BONUS_MK1, default.CYBER_LEGS_DODGE_BONUS_MK1));
	Templates.AddItem(CyberLegsJump('CyberJumpLegsMK2', default.CYBER_LEGS_MOBILITY_BONUS_MK2, default.CYBER_LEGS_DODGE_BONUS_MK2));
	Templates.AddItem(SelfRepairingNanoCoating('NanoCoating', default.NANO_COATING_SHIELD_HP, default.NANO_COATING_SHIELD_REGEN_TURN, default.NANO_COATING_SHIELD_REGEN_MAX));
	Templates.AddItem(WeakpointAnalyzer('WeakpointAnalyzer', default.WEAKPOINTANALYZER_ARMOR_PIERCE, default.WEAKPOINTANALYZER_CRIT_CHANCE, default.WEAKPOINTANALYZER_CRIT_DAMAGE));

	Templates.AddItem(AugmentedHead());
	Templates.AddItem(AugmentedShield());
	Templates.AddItem(AugmentedSpeed());
	Templates.AddItem(ExMachina());
	Templates.AddItem(CyberPunch());
	Templates.AddItem(CyberPunchAnimSet());
	Templates.AddItem(AugmentationBaseStats());
	Templates.AddItem(AugmentationBaseWillLoss());
	Templates.AddItem(ClawsSlash());

	return Templates;
}



static function X2AbilityTemplate CarryHeavyWeapons()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	//BonusEffect.AddToHitModifier(default.NEURAL_TACTICAL_PROCESSOR_HIT_BONUS, eHit_Success);
	
	Template = Passive('CarryHeavyWeapons', "img:///Texture2D'UILibrary_Augmentations.'", false, BonusEffect);

	return Template;
}


static function X2AbilityTemplate NeuralTacticalProcessor()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;
	local X2Effect_NeuralTacticalProcessor NeuralTacticalProcessorEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.NEURAL_TACTICAL_PROCESSOR_HIT_BONUS, eHit_Success);
	
	Template = Passive('NeuralTacticalProcessor', "img:///Texture2D'UILibrary_Augmentations.UIPerk_NeuralTacticalProccessor'", false, BonusEffect);

	NeuralTacticalProcessorEffect = new class'X2Effect_NeuralTacticalProcessor';
	NeuralTacticalProcessorEffect.BonusPerViewer = default.NEURAL_TACTICAL_PROCESSOR_BONUS_PER_SQUADMATE;
	NeuralTacticalProcessorEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false, , Template.AbilitySourceName);
	Template.AddTargetEffect(NeuralTacticalProcessorEffect);

	return Template;
}


static function X2AbilityTemplate NeuralGunLink()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.NEURAL_GUNLINK_HIT_BONUS, eHit_Success);
	
	Template = Passive('NeuralGunLink', "img:///Texture2D'UILibrary_Augmentations.UIPerk_NeuralGunlink'", false, BonusEffect);

	return Template;
}

static function X2AbilityTemplate CyberLegsJump(name AbilityName, int MobilityBonus, int DodgeBonus)
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle					TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_PersistentTraversalChange	JumpEffect;
	local X2Effect_AdditionalAnimSets			AnimSets;
	local X2Effect_PersistentStatChange			PersistentStatChangeEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = "img:///UILibrary_Augmentations.UIPerk_Jump";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITacticalText = true;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	JumpEffect = new class'X2Effect_PersistentTraversalChange';
	JumpEffect.BuildPersistentEffect(1, true, false, false, eGameRule_TacticalGameStart);
	JumpEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false, , Template.AbilitySourceName);
	JumpEffect.AddTraversalChange(eTraversal_JumpUp, true);
	Template.AddTargetEffect(JumpEffect);

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.AddAnimSetWithPath("CyberLegsAugmentations.Anims.AS_Jump");
	AnimSets.BuildPersistentEffect(1, true, false, false, eGameRule_TacticalGameStart);
	Template.AddTargetEffect(AnimSets);

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, MobilityBonus);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, DodgeBonus);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, MobilityBonus);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeStat, eStat_Dodge, DodgeBonus);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;
	Template.bSkipFireAction = true;

	return Template;
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

	Template.AbilitySourceName = 'eAbilitySource_Perk';
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

	Template.AbilitySourceName = 'eAbilitySource_Perk';
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
	local X2AbilityTemplate					Template;
	local X2Effect_DamageImmunity			DamageImmunity;
	local X2Effect_Hardened					HardenedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ExMachina');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_divinearmor";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = true;

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
	DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	DamageImmunity.TargetConditions.AddItem(new class'X2Condition_Cyborg');
	Template.AddTargetEffect(DamageImmunity);

	HardenedEffect = new class'X2Effect_Hardened';
	HardenedEffect.DamageReductionPct = default.HARDENED_DAMAGE_REDUCTION_PCT;
	HardenedEffect.TargetConditions.AddItem(new class'X2Condition_Cyborg');
	Template.AddTargetEffect(HardenedEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate CyberPunch()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Effect_ApplyWeaponDamage		DamageEffect;
	local X2AbilityCooldown					Cooldown;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('CyberPunch');

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.CYBERPUNCH_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

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

	Template.CinescriptCameraType = "Skirmisher_Melee";

	return Template;
}

static function X2AbilityTemplate CyberPunchAnimSet()
{
	local X2AbilityTemplate						Template;
	local X2Effect_AdditionalAnimSets			AnimSets;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'CyberPunchAnimSet');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
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

	Template.AbilitySourceName = 'eAbilitySource_Perk';
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

static function X2AbilityTemplate AugmentationBaseWillLoss()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AugmentationBaseWillLoss');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bIsPassive = true;
	Template.bCrossClassEligible = false;

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Will, default.AUGMENTATION_BASE_WILL_LOSS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bShowActivation = true;

	return Template;
}

static function X2AbilityTemplate ClawsSlash()
{
	local X2AbilityTemplate				Template;
	//local X2AbilityCost_ActionPoints	ActionPointCost;
	//local X2AbilityCooldown				Cooldown;
	//local int i;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('ClawsSlash');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_chryssalid_slash";

	Template.bFrameEvenWhenUnitIsHidden = true;
	
	//for (i = 0; i < Template.AbilityCosts.Length; ++i)
	//{
	//	ActionPointCost = X2AbilityCost_ActionPoints(Template.AbilityCosts[i]);
	//	if (ActionPointCost != none)
	//		ActionPointCost.bConsumeAllPoints = false;
	//}

	return Template;
}
