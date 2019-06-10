class X2Ability_Aptitudes extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2DataTemplate Template;

	Templates.AddItem(Guttersnipe());
	Templates.AddItem(Warden());
	Templates.AddItem(Veteran());
	Templates.AddItem(Activist());
	Templates.AddItem(NobleScion());
	Templates.AddItem(LoneWolf());
	Templates.AddItem(OldGuard());
	Templates.AddItem(Militia());
	Templates.AddItem(Informant());
	Templates.AddItem(Guerilla());
	Templates.AddItem(Survivor());
	Templates.AddItem(Outcast());
	Templates.AddItem(Revolutionary());
	Templates.AddItem(SysAdmin());
	Templates.AddItem(Pacifist());
	Templates.AddItem(Pacifist_Dmg());
	Templates.AddItem(Anarchist());
	Templates.AddItem(Vanguard());
	Templates.AddItem(Rebel());
	Templates.AddItem(Insurgent());
	Templates.AddItem(Xenophobe());
	Templates.AddItem(FortuneHunter());
	Templates.AddItem(Renegade());
	Templates.AddItem(Irregular());
	Templates.AddItem(Legacy());
	Templates.AddItem(Tactician());
	Templates.AddItem(Pioneer());
	Templates.AddItem(Professional());
	Templates.AddItem(Mercenary());
	Templates.AddItem(Saboteur());
	Templates.AddItem(Scrapper());
	Templates.AddItem(Heretic());
	Templates.AddItem(Overseer());
	Templates.AddItem(Vigilante());
	Templates.AddItem(Toxicologist());
	Templates.AddItem(Electrician());
	Templates.AddItem(Chemist());
	Templates.AddItem(Pyromaniac());

	//Recolor icons
	foreach Templates(Template){
		X2AbilityTemplate(Template).AbilitySourceName = 'eAbilitySource_Commander';
		X2AbilityTemplate(Template).AdditionalAbilities.AddItem('MNT_PerkLoader');
	}

	return Templates;

}


// #######################################################################################
// -------------------- GUTTERSNIPE ------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Guttersnipe()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus FlankEffect;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MissionData Condition;

	FlankEffect = new class'XMBEffect_ConditionalBonus';
	FlankEffect.AddToHitModifier(class'Config_Manager'.static.GetConfigIntValue("GUTTERSNIPE_CRIT"), eHit_Crit);
	FlankEffect.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("GUTTERSNIPE_SHRED_CV"), eHit_Success, 'conventional');
	FlankEffect.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("GUTTERSNIPE_SHRED_MG"), eHit_Success, 'magnetic');
	FlankEffect.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("GUTTERSNIPE_SHRED_BM"), eHit_Success, 'beam');

	FlankEffect.AbilityTargetConditions.AddItem(default.FlankedCondition);

	Template = Passive('APT_Guttersnipe', "img:///UILibrary_PerkIcons.UIPerk_leap", true, FlankEffect);

	Effect = new class 'X2Effect_PersistentStatChange';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_Mobility, class'Config_Manager'.static.GetConfigIntValue("GUTTERSNIPE_MOBILITY"));
	Condition = new class'X2Condition_MissionData';
	Condition.bSupply = true;
	Condition.AllowedPlots.AddItem("Shanty");
	Condition.AllowedPlots.AddItem("Slums");
	Condition.AllowedPlots.AddItem("Tunnels_Subway");
	Condition.AllowedPlots.AddItem("Tunnels_Sewer");
	Effect.TargetConditions.AddItem(Condition);
	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- WARDEN	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Warden()
{
	local X2Effect_ModifyReactionFire		ReactionFire;

	// Create a conditional bonus
	ReactionFire = new class'X2Effect_ModifyReactionFire';
	ReactionFire.ReactionModifier = class'Config_Manager'.static.GetConfigIntValue("WARDEN_REACTION_AIM");

	return Passive('APT_Warden', "img:///UILibrary_PerkIcons.UIPerk_opportunist", true, ReactionFire);
}

// #######################################################################################
// -------------------- VETERAN	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Veteran()
{
	local X2Effect_DamageImmunity Effect;

	Effect = new class'X2Effect_DamageImmunity';
	Effect.ImmuneTypes.AddItem('Mental');

	return Passive('APT_Veteran', "img:///XPerkIconPack.UIPerk_mind_defense2", true, Effect);
}

// #######################################################################################
// -------------------- ACTIVIST	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Activist()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MissionData Condition;
	local X2Condition_UnitProperty CivProperty;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	
	Template = Passive('APT_Activist', "img:///UILibrary_PerkIcons.UIPerk_nation_aim", true, none);

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'Activist';

	Effect.AddPersistentStatChange(eStat_DetectionRadius, class'Config_Manager'.static.GetConfigIntValue("ACTIVIST_DETECTION_MOD"));
	Effect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, true, , Template.AbilitySourceName);
	Effect.BuildPersistentEffect(1, true, false);
	Effect.DuplicateResponse = eDupe_Ignore;

	CivProperty = new class 'X2Condition_UnitProperty';
	CivProperty.ExcludeFriendlyToSource = true;
	CivProperty.ExcludeNonCivilian = true;
	Effect.TargetConditions.AddItem(CivProperty);

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = 999;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	Template.AddMultiTargetEffect(Effect);

	Effect = new class 'X2Effect_PersistentStatChange';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_DetectionRadius, class'Config_Manager'.static.GetConfigFloatValue("ACTIVIST_DETECTION_MOD_CIVS"));
	
	Condition = new class'X2Condition_MissionData';
	Condition.AllowedPlots.AddItem("CityCenter");
	Condition.AllowedPlots.AddItem("Rooftops");
	Effect.TargetConditions.AddItem(Condition);
	Effect.TargetConditions.AddItem(default.LivingFriendlyTargetProperty);

	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- NOBLE SCION	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate NobleScion()
{
	local X2Effect_SystemUplink Effect;

	Effect = new class'X2Effect_SystemUplink';
	Effect.EffectName = 'APT_NobleScion';
	Effect.DuplicateResponse = eDupe_Ignore;
	Effect.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("WAR_HERO_DAMAGE_BONUS"));
	Effect.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	return SquadPassive('APT_NobleScion', "img:///UILibrary_PerkIcons.UIPerk_advent_commandaura", false, Effect);
}

// #######################################################################################
// -------------------- LONE WOLF	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate LoneWolf()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus AllyEffect;
	local X2Effect_PersistentStatChange	Effect;
	local X2Condition_NearestAlly Condition;
	local X2Condition_MissionData Condition2;

	AllyEffect = new class'XMBEffect_ConditionalBonus';
	AllyEffect.AddToHitModifier(class'Config_Manager'.static.GetConfigIntValue("LONE_WARRIOR_CRIT"), eHit_Crit);
	
	Condition = new class 'X2Condition_NearestAlly';
	Condition.bBeyond = true;
	Condition.TileDistance = class'Config_Manager'.static.GetConfigIntValue("LONE_WARRIOR_RADIUS");
	AllyEffect.AbilityShooterConditions.AddItem(Condition);
	
	// Create the template using a helper function
	Template = Passive('APT_LoneWolf', "img:///UILibrary_PerkIcons.UIPerk_honor_b", true, AllyEffect);

	Effect = new class 'X2Effect_PersistentStatChange';

	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_DetectionModifier, class'Config_Manager'.static.GetConfigFloatValue("LONE_WARRIOR_DETECTION_MOD"));
	Effect.AddPersistentStatChange(eStat_Mobility, class'Config_Manager'.static.GetConfigIntValue("LONE_WARRIOR_MOBILITY"));
	Condition2 = new class'X2Condition_MissionData';
	Condition2.bNeutralize = true;
	Effect.TargetConditions.AddItem(Condition2);
	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- OLD GUARD	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate OldGuard()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("OLD_GUARD_DAMAGE_BONUS"), eHit_Success, 'conventional');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("OLD_GUARD_CRIT_DAMAGE_BONUS"), eHit_Crit, 'conventional');
	Effect.AddArmorPiercingModifier(class'Config_Manager'.static.GetConfigIntValue("OLD_GUARD_ARMOR_PIERCE"), eHit_Success, 'conventional');

	return Passive('APT_OldGuard', "img:///UILibrary_PerkIcons.UIPerk_Timeshift", true, Effect);
}

// #######################################################################################
// -------------------- MILITIA	------------------------------------------------------
// #######################################################################################

static function X2AbilityTemplate Militia()
{
	local X2AbilityTemplate					Template;
	local X2Effect_RangeMultiplier			RangeEffect;
	local X2Effect_PersistentStatChange		Effect;

	RangeEffect = new class'X2Effect_RangeMultiplier';
	RangeEffect.RangeMultiplier=class'Config_Manager'.static.GetConfigFloatValue("MILITIA_RANGE_MULTIPLIER");
	RangeEffect.BuildPersistentEffect(1, true, false, false);

	Template = Passive('APT_Militia', "img:///UILibrary_PerkIcons.UIPerk_Urban_Aim", true, RangeEffect);

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_Offense, class'Config_Manager'.static.GetConfigIntValue("MILITIA_AIM"));
	Effect.AddPersistentStatChange(eStat_SightRadius, class'Config_Manager'.static.GetConfigIntValue("MILITIA_SIGHT_RADIUS"));

	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- INFORMANT	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Informant()
{
	local X2AbilityTemplate					Template;
	local XMBEffect_ConditionalBonus		ADVEffect;
	local X2Effect_PersistentStatChange		Effect;
	local X2Condition_UnitProperty			UnitProperty;
	local X2Condition_MissionData			Condition;
	
	ADVEffect = new class'XMBEffect_ConditionalBonus';
	ADVEffect.AddToHitModifier(class'Config_Manager'.static.GetConfigIntValue("INFORMANT_CRIT"), eHit_Crit);
	
	UnitProperty = new class 'X2Condition_UnitProperty';
	UnitProperty.ExcludeFriendlyToSource = true;
	UnitProperty.IsADVENT = true;
	ADVEffect.AbilityTargetConditions.AddItem(UnitProperty);

	Template = Passive('APT_Informant', "img:///UILibrary_PerkIcons.UIPerk_nation_aim", true, ADVEffect);

	Effect = new class 'X2Effect_PersistentStatChange';

	Effect.EffectName = 'Informant';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_Hacking, class'Config_Manager'.static.GetConfigIntValue("INFORMANT_HACK"));
	Effect.AddPersistentStatChange(eStat_Mobility, class'Config_Manager'.static.GetConfigIntValue("INFORMANT_MOBILITY"));
	Condition = new class'X2Condition_MissionData';
	Condition.bSupply = true;
	Condition.bRecovery = true;
	Condition.bHack = true;
	Condition.AllowedPlots.AddItem("Facility");
	Condition.AllowedPlots.AddItem("Stronghold");
	Effect.TargetConditions.AddItem(Condition);
	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- GUERILLA	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Guerilla()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus FlankEffect;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MissionData Condition;

	FlankEffect = new class'XMBEffect_ConditionalBonus';
	FlankEffect.AddToHitModifier(class'Config_Manager'.static.GetConfigIntValue("GUERILLA_CRIT"), eHit_Crit);
	FlankEffect.AddArmorPiercingModifier(class'Config_Manager'.static.GetConfigIntValue("GUERILLA_PIERCE_CV"), eHit_Success, 'conventional');
	FlankEffect.AddArmorPiercingModifier(class'Config_Manager'.static.GetConfigIntValue("GUERILLA_PIERCE_MG"), eHit_Success, 'magnetic');
	FlankEffect.AddArmorPiercingModifier(class'Config_Manager'.static.GetConfigIntValue("GUERILLA_PIERCE_BM"), eHit_Success, 'beam');

	FlankEffect.AbilityTargetConditions.AddItem(default.FlankedCondition);

	Template = Passive('APT_Guerilla', "img:///UILibrary_XPACK_Common.UIPerk_bond_spotter2", true, FlankEffect);

	Effect = new class 'X2Effect_PersistentStatChange';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_Defense, class'Config_Manager'.static.GetConfigIntValue("GUERILLA_DEFENSE"));
	Condition = new class'X2Condition_MissionData';
	Condition.bSabotage = true;
	Condition.AllowedPlots.AddItem("Shanty");
	Condition.AllowedPlots.AddItem("Wilderness");
	Condition.AllowedPlots.AddItem("SmallTown");
	Effect.TargetConditions.AddItem(Condition);
	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- SURVIVOR	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Survivor()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitStatCheck Condition;
	local X2Condition_MissionData MapCondition;

	Condition = new class'X2Condition_UnitStatCheck';
	Condition.AddCheckStat(eStat_HP, class'Config_Manager'.static.GetConfigIntValue("SURVIVOR_DAMAGE_THRESHOLD"), eCheck_LessThan,,, true);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("SURVIVOR_DAMAGE_BONUS"));
	Effect.AbilityShooterConditions.AddItem(Condition);
	
	// Create the template using a helper function
	Template = Passive('APT_Survivor', "img:///UILibrary_PerkIcons.UIPerk_fallencomrades", true, Effect);

	MapCondition = new class'X2Condition_MissionData';
	MapCondition.bDefend = true;
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("SURVIVOR_DAMAGE_BONUS"));
	Effect.TargetConditions.AddItem(MapCondition);

	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- OUTCAST	------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Outcast()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MissionData Condition;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_FlankingAimBonus, class'Config_Manager'.static.GetConfigIntValue("OUTCAST_FLANKING_AIM"));
	
	Template = Passive('APT_Outcast', "img:///UILibrary_PerkIcons.UIPerk_nation_aim", true, Effect);
	
	Effect = new class 'X2Effect_PersistentStatChange';

	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_Dodge, class'Config_Manager'.static.GetConfigIntValue("OUTCAST_DODGE"));
	Condition = new class'X2Condition_MissionData';
	Condition.bSupply = true;
	Condition.AllowedPlots.AddItem("Wilderness");
	Condition.AllowedPlots.AddItem("SmallTown");
	Condition.AllowedPlots.AddItem("Abandoned");
	Effect.TargetConditions.AddItem(Condition);
	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- THE JUST ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Revolutionary()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitStatCheck Condition;

	Condition = new class'X2Condition_UnitStatCheck';
	Condition.AddCheckStat(eStat_HP, 100, eCheck_Exact,,, true);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("REVOLUTIONARY_DAMAGE_CV"), eHit_Success, 'conventional');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("REVOLUTIONARY_DAMAGE_MG"), eHit_Success, 'magnetic');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("REVOLUTIONARY_DAMAGE_BM"), eHit_Success, 'beam');

	// The effect only applies while both you and target are unharmed
	Effect.AbilityTargetConditions.AddItem(Condition);
	Effect.AbilityShooterConditions.AddItem(Condition);
	Effect.AbilityTargetConditionsAsTarget.AddItem(Condition);
	
	// Create the template using a helper function
	return Passive('APT_Revolutionary', "img:///UILibrary_PerkIcons.UIPerk_civiliancover", true, Effect);
}

// #######################################################################################
// -------------------- SYSADMIN ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate SysAdmin()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty UnitProperty;
	local X2Effect_PersistentStatChange StatEffect;
	local X2Condition_MissionData Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("SYSADMIN_DAMAGE_CV"), eHit_Success, 'conventional');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("SYSADMIN_DAMAGE_MG"), eHit_Success, 'magnetic');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("SYSADMIN_DAMAGE_BM"), eHit_Success, 'beam');
	Effect.AddToHitAsTargetModifier(class'Config_Manager'.static.GetConfigIntValue("SYSADMIN_ROBOT_DEFENSE"), eHit_Success);

	UnitProperty = new class 'X2Condition_UnitProperty';
	UnitProperty.ExcludeFriendlyToSource = true;
	UnitProperty.ExcludeOrganic = true;
	Effect.AbilityTargetConditions.AddItem(UnitProperty);
	
	// Create the template using a helper function
	Template = Passive('APT_SysAdmin', "img:///UILibrary_PerkIcons.UIPerk_jamthesignal", true, Effect);
	
	StatEffect = new class 'X2Effect_PersistentStatChange';
	StatEffect.BuildPersistentEffect(1, true, false, false);
	StatEffect.AddPersistentStatChange(eStat_Hacking, class'Config_Manager'.static.GetConfigIntValue("SYSADMIN_HACKING"));

	Condition = new class'X2Condition_MissionData';
	Condition.bHack = true;
	Condition.bSabotage = true;
	StatEffect.TargetConditions.AddItem(Condition);
	AddSecondaryEffect(Template, StatEffect);

	return Template;

}

// #######################################################################################
// -------------------- PACIFIST ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Pacifist()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange MobEffect;

	MobEffect = new class 'X2Effect_PersistentStatChange';
	MobEffect.BuildPersistentEffect(1, true, false, false);
	MobEffect.AddPersistentStatChange(eStat_Defense, class'Config_Manager'.static.GetConfigIntValue("PACIFIST_DEFENSE"));

	// Create the template using a helper function
	Template = SquadPassive('APT_Pacifist', "img:///UILibrary_PerkIcons.UIPerk_helpinghand", true, MobEffect);

	AddSecondaryAbility(Template, Pacifist_Dmg());

	return Template;
}

static function X2AbilityTemplate Pacifist_Dmg()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("PACIFIST_DAMAGE_MOD"));
	Effect.BuildPersistentEffect(1, true, false, false);
	
	return SelfTargetTrigger('APT_Pacifist_Dmg', "img:///UILibrary_PerkIcons.UIPerk_helpinghand", false, Effect, 'KillMail');
}


// #######################################################################################
// -------------------- ANARCHIST --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Anarchist()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem	PyroEffect;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_Visibility Value;
	
	PyroEffect = new class 'XMBEffect_AddUtilityItem';
	PyroEffect.DataName = 'FragGrenade';
	PyroEffect.BaseCharges = class'Config_Manager'.static.GetConfigIntValue("ANARCHIST_CHARGES");

	Template = Passive('APT_Anarchist', "img:///UILibrary_PerkIcons.UIPerk_equalizer", true, PyroEffect);
 
	Value = new class'XMBValue_Visibility';
	Value.bCountAllies = true;
	Value.bCountEnemies = true;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(class'Config_Manager'.static.GetConfigIntValue("ANARCHIST_CRIT"), eHit_Crit);
	Effect.ScaleValue = Value;
	Effect.ScaleMax = class'Config_Manager'.static.GetConfigIntValue("ANARCHIST_CRIT_MAX");

	AddSecondaryEffect(Template, Effect);

	return Template;
}

// #######################################################################################
// -------------------- VANGUARD --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Vanguard()
{
	local X2Effect_Infighter Effect;
	 
	Effect = new class'X2Effect_Infighter';
	Effect.DodgeMod = class'Config_Manager'.static.GetConfigIntValue("VANGUARD_DODGE");
	Effect.HitMod = class'Config_Manager'.static.GetConfigIntValue("VANGUARD_AIM");
	Effect.CritMod = class'Config_Manager'.static.GetConfigIntValue("VANGUARD_CRIT");
	Effect.TileRange = class'Config_Manager'.static.GetConfigIntValue("VANGUARD_RANGE");
	Effect.bWithin = true;

	return Passive('APT_Vanguard', "img:///UILibrary_PerkIcons.UIPerk_Adventstunlancer_charge", true, Effect);
}

// #######################################################################################
// -------------------- REBEL ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Rebel()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitStatCheck Condition;

	Condition = new class'X2Condition_UnitStatCheck';
	Condition.AddCheckStat(eStat_HP, 100, eCheck_LessThan,,, true);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("REBEL_DAMAGE_CV"), eHit_Success, 'conventional');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("REBEL_DAMAGE_MG"), eHit_Success, 'magnetic');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("REBEL_DAMAGE_BM"), eHit_Success, 'beam');
	
	Effect.AbilityTargetConditions.AddItem(Condition);
	Effect.AbilityShooterConditions.AddItem(Condition);
	Effect.AbilityTargetConditionsAsTarget.AddItem(Condition);
	// Create the template using a helper function
	return Passive('APT_Rebel', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_spectralarmy", true, Effect);
}

// #######################################################################################
// -------------------- INSURGENT ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Insurgent()
{
	local XMBEffect_ConditionalBonus	Effect;

	Effect = new class'X2Effect_SystemUplink';
	Effect.EffectName = 'APT_Insurgent';
	Effect.DuplicateResponse = eDupe_Ignore;
	Effect.AddArmorPiercingModifier(class'Config_Manager'.static.GetConfigIntValue("INSURGENT_ARMOR_PIERCE"));
	Effect.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	return SquadPassive('APT_Insurgent', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_ambush", true, Effect);
}

// #######################################################################################
// -------------------- XENOPHOBE ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Xenophobe()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty UnitProperty;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("XENOPHOBE_DAMAGE_CV"), eHit_Success, 'conventional');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("XENOPHOBE_DAMAGE_MG"), eHit_Success, 'magnetic');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("XENOPHOBE_DAMAGE_BM"), eHit_Success, 'beam');

	UnitProperty = new class 'X2Condition_UnitProperty';
	UnitProperty.ExcludeFriendlyToSource=true;
	UnitProperty.ExcludeAdvent=true;
	Effect.AbilityTargetConditions.AddItem(UnitProperty);
	
	// Create the template using a helper function
	return Passive('APT_Xenophobe', "img:///UILibrary_PerkIcons.UIPerk_muton_execute", true, Effect);
}

// #######################################################################################
// -------------------- FORTUNE-HUNTER ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate FortuneHunter()
{
	local X2Effect_DangerousGame	Effect;

	Effect = new class'X2Effect_DangerousGame';
	Effect.DamageMod = class'Config_Manager'.static.GetConfigFloatValue("FORTUNE_HUNTER_DAMAGE_MOD");

	// Create the template using a helper function
	return Passive('APT_FortuneHunter', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vektorrifle", true, Effect);
}

// #######################################################################################
// -------------------- RENEGADE ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Renegade()
{
	local X2Effect_Prevail			Effect;

	Effect = new class'X2Effect_Prevail';
	Effect.CritMod = class'Config_Manager'.static.GetConfigIntValue("RENEGADE_CRIT");
	Effect.DamageReduction = class'Config_Manager'.static.GetConfigFloatValue("RENEGADE_DAMAGE_REDUCTION");

	// Create the template using a helper function
	return Passive('APT_Renegade', "img:///UILibrary_PerkIcons.UIPerk_riposte", true, Effect);
}

// #######################################################################################
// -------------------- IRREGULAR --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Irregular()
{
	local X2AbilityTemplate			Template;
	local X2Effect_LowProfile_LW	Effect;
	local X2Effect_RangerStealth	StealthEffect;
	local X2Condition_Fade			IsVisibleToEnemy;
	local X2Effect_DefendingDamage	DamageTaken;

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;

	Template = SelfTargetTrigger('APT_Irregular', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanish", false, StealthEffect, 'PlayerTurnBegun', eFilter_Player);
	AddIconPassive(Template);

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');
	IsVisibleToEnemy = new class 'X2Condition_Fade';
	Template.AbilityShooterConditions.AddItem(IsVisibleToEnemy);

	AddSecondaryEffect(Template, class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Effect = new class'X2Effect_LowProfile_LW';
	AddSecondaryEffect(Template, Effect);

	DamageTaken = new class 'X2Effect_DefendingDamage';
	DamageTaken.PercentDamage=true;
	DamageTaken.PercentDamageMod = class'Config_Manager'.static.GetConfigFloatValue("IRREGULAR_DAMAGE_MALUS");

	return Template;
}

// #######################################################################################
// -------------------- PIONEER --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Pioneer()
{
	local XMBEffect_ConditionalBonus Effect;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';

	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("PIONEER_DAMAGE_LASER"), eHit_Success, 'laser');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("PIONEER_DAMAGE_MG"), eHit_Success, 'magnetic');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("PIONEER_DAMAGE_COIL"), eHit_Success, 'coil');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("PIONEER_DAMAGE_BM"), eHit_Success, 'beam');

	// The bonus only applies to attacks with the weapon associated with this ability
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	// Create the template using a helper function
	return Passive('APT_Pioneer', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_quantumtargeting", true, Effect);
}

// #######################################################################################
// -------------------- PROFESSIONAL -----------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Professional()
{
	local XMBEffect_ConditionalBonus			ReactionFire;
	
	// Create a conditional bonus
	ReactionFire = new class'XMBEffect_ConditionalBonus';
	ReactionFire.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("PROFESSIONAL_DAMAGE_BONUS"), eHit_Success);
	ReactionFire.AbilityShooterConditions.AddItem(default.ReactionFireCondition);

	return Passive('APT_Professional', "img:///XPerkIconPack.UIPerk_overwatch_plus", true, ReactionFire);
}

// #######################################################################################
// -------------------- LEGACY --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Legacy()
{
	local X2Effect_Latent Effect;

	// Create a conditional bonus
	Effect = new class'X2Effect_Latent';

	// Create the template using a helper function
	return Passive('APT_Legacy', "img:///UILibrary_PerkIcons.UIPerk_combatstim_psi", true, Effect);
}

// #######################################################################################
// -------------------- TACTICIAN --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Tactician()
{
	local XMBEffect_ConditionalBonus Effect;
	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("TACTICIAN_DAMAGE_CV"), eHit_Miss, 'conventional');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("TACTICIAN_DAMAGE_MG"), eHit_Miss, 'magnetic');
	Effect.AddDamageModifier(class'Config_Manager'.static.GetConfigIntValue("TACTICIAN_DAMAGE_BM"), eHit_Miss, 'beam');
	
	// The bonus only applies to attacks with the weapon associated with this ability
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	// Create the template using a helper function
	return Passive('APT_Tactician', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_bloodletter", true, Effect);
}


// #######################################################################################
// -------------------- MERCENARY --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Mercenary()
{
	local X2Effect_Mercenary Effect;
	// Create a conditional bonus
	Effect = new class'X2Effect_Mercenary';
	Effect.bSupplies = true;
	Effect.bIntel = false;
	Effect.Cap = class'Config_Manager'.static.GetConfigIntValue("MERCENARY_CRIT_CAP");
	Effect.Factor = class'Config_Manager'.static.GetConfigIntValue("MERCENARY_CRIT_SUPPLY_FACTOR");
	
	// Create the template using a helper function
	return Passive('APT_Mercenary', "img:///UILibrary_PerkIcons.UIPerk_star_hire", true, Effect);
}

// #######################################################################################
// -------------------- SABOTEUR --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Saboteur()
{
	local X2Effect_Mercenary Effect;
	// Create a conditional bonus
	Effect = new class'X2Effect_Mercenary';
	Effect.bSupplies = false;
	Effect.bIntel = true;
	Effect.Cap = class'Config_Manager'.static.GetConfigIntValue("SABOTEUR_CRIT_CAP");
	Effect.Factor = class'Config_Manager'.static.GetConfigIntValue("SABOTEUR_CRIT_INTEL_FACTOR");
	
	// Create the template using a helper function
	return Passive('APT_Saboteur', "img:///UILibrary_PerkIcons.UIPerk_defuse", true, Effect);
}

// #######################################################################################
// -------------------- SCRAPPER --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Scrapper()
{
	local XMBEffect_ConditionalBonus	Effect;
	
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(class'Config_Manager'.static.GetConfigIntValue("SCRAPPER_CRIT"), eHit_Crit);
	Effect.BuildPersistentEffect(2, true, true, false, eGameRule_PlayerTurnBegin);
	Effect.DuplicateResponse = eDupe_Allow;

	return SelfTargetTrigger('APT_Scrapper', "img:///UILibrary_PerkIcons.UIPerk_adrenaline", false, Effect, 'UnitTakeEffectDamage');
}

// #######################################################################################
// -------------------- HERETIC --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Heretic()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty TargetProperty;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("HERETIC_DAMAGE_BONUS"));
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);
	TargetProperty = new class 'X2Condition_UnitProperty';
	TargetProperty.ExcludeNonPsionic = true;
	Effect.AbilityTargetConditions.AddItem(TargetProperty);

	// Create the template using a helper function
	return Passive('APT_Heretic', "img:///XPerkIconPack.UIPerk_enemy_psi", true, Effect);
}

// #######################################################################################
// -------------------- OVERSEER ---------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Overseer()
{
	local XMBEffect_ConditionalBonus	Effect;

	Effect = new class'X2Effect_SystemUplink';
	Effect.EffectName = 'APT_Overseer';
	Effect.DuplicateResponse = eDupe_Ignore;
	Effect.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("OVERSEER_SHRED"));
	Effect.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	return SquadPassive('APT_Overseer', "img:///XPerkIconPack.UIPerk_hack_chevron_x3", true, Effect);
}

// #######################################################################################
// -------------------- VIGILANTE --------------------------------------------------------
// #######################################################################################
static function X2AbilityTemplate Vigilante()
{
	local XMBEffect_ConditionalBonus	ADVEffect;
	local X2Condition_UnitProperty		UnitProperty;

	ADVEffect = new class'XMBEffect_ConditionalBonus';
	ADVEffect.AddPercentDamageModifier(class'Config_Manager'.static.GetConfigIntValue("VIGILANTE_CRIT_DAMAGE_BONUS"), eHit_Crit);
	
	UnitProperty = new class 'X2Condition_UnitProperty';
	UnitProperty.ExcludeFriendlyToSource = true;
	UnitProperty.IsADVENT = true;
	ADVEffect.AbilityTargetConditions.AddItem(UnitProperty);

	return Passive('APT_Vigilante', "img:///XPerkIconPack.UIPerk_enemy_crit_plus", true, ADVEffect);
}

// #######################################################################################
// -------------------- TOXICOLOGIST ----------------------------------------------------------
// #######################################################################################

// Perk name:		Toxicologist
// Perk effect:		Your poison attacks deal +1 damage, and your poison effects deal +1 damage per turn. You get a free gas grenade on each mission.
// Localized text:	"Your poison  attacks deal +1 damage, and your poison effects deal +1 damage per turn. You get a free gas grenade on each mission."
// Config:			(AbilityName="RpgToxicologist")

static function X2AbilityTemplate Toxicologist()
{
	local XMBEffect_BonusDamageByDamageType Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	// Create an effect that adds +1 damage to poison attacks and +1 damage to poison damage
	Effect = new class'XMBEffect_BonusDamageByDamageType';
	Effect.EffectName = 'Toxicologist';
	Effect.RequiredDamageTypes.AddItem('Poison');
	Effect.DamageBonus = class'Config_Manager'.static.GetConfigIntValue("TOXICOLOGIST_DAMAGE_BONUS");

	// Create the template using a helper function
	Template = Passive('RpgToxicologist', "img:///UILibrary_RPG.UIPerk_Toxicologist_Aptitude", true, Effect);

	// Add another effect that grants a free gas grenade during each mission
	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'GasGrenade';
	AddSecondaryEffect(Template, ItemEffect);

	return Template;
}

// #######################################################################################
// -------------------- ELECTRICIAN-------------------------------------------------------
// #######################################################################################

// Perk name:		Electrician
// Perk effect:		Your electrical attacks deal +1 damage, and your electrical effects have a 25% chance to stun for 1 turn. You get a free EMP grenade on each mission.
// Localized text:	"Your electrical attacks deal +1 damage, and your electrical effects have a 25% chance to stun for 1 turn. You get a free EMP grenade on each mission."
// Config:			(AbilityName="RpgToxicologist")

static function X2AbilityTemplate Electrician()
{
	local XMBEffect_BonusDamageByDamageType Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	// Create an effect that adds +2 damage to electrical attacks
	Effect = new class'XMBEffect_BonusDamageByDamageType';
	Effect.EffectName = 'Electrician';
	Effect.RequiredDamageTypes.AddItem('Electricity'); // check if this is correct terminology
	Effect.RequiredDamageTypes.AddItem('Electrical');
	Effect.DamageBonus = class'Config_Manager'.static.GetConfigIntValue("ELECTRICIAN_DAMAGE_BONUS");

	// Create the template using a helper function
	Template = Passive('RpgElectrician', "img:///UILibrary_RPG.UIPerk_Electrician_Aptitude", true, Effect);

	// Add another effect that grants a free EMP grenade during each mission
	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'EMPGrenade';
	AddSecondaryEffect(Template, ItemEffect);

	return Template;
}

// #######################################################################################
// -------------------- CHEMIST ----------------------------------------------------------
// #######################################################################################

// Perk name:		Chemist
// Perk effect:		Your acid attacks deal +1 damage, and your attacks against targets affected by acid burn shred armour. You get a free acid grenade on each mission.
// Localized text:	"Your acid attacks deal +1 damage, and your attacks against targets affected by acid burn shred armour. You get a free acid grenade on each mission."
// Config:			(AbilityName="RpgChemist")

static function X2AbilityTemplate Chemist()
{
	local XMBEffect_BonusDamageByDamageType Effect;
	local XMBEffect_ConditionalBonus Effect2;
	local XMBEffect_AddUtilityItem ItemEffect;
    local X2Condition_UnitAffectedByAcidBurn Condition;
	local X2AbilityTemplate Template;

	// Create an effect that adds +1 damage to acid attacks and +1 damage to acid effects 
	Effect = new class'XMBEffect_BonusDamageByDamageType';
	Effect.EffectName = 'Chemist';
	Effect.RequiredDamageTypes.AddItem('Acid');
	Effect.DamageBonus = class'Config_Manager'.static.GetConfigIntValue("CHEMIST_DAMAGE_BONUS");

	// Create an effect that make
	Effect2 = new class'XMBEffect_ConditionalBonus';
	Effect2.EffectName = 'RpgChemist_Bonuses';
	Effect2.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("CHEMIST_SHRED_BONUS_CV"), eHit_Success, 'conventional');
	Effect2.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("CHEMIST_SHRED_BONUS_MG"), eHit_Success, 'magnetic');
	Effect2.AddShredModifier(class'Config_Manager'.static.GetConfigIntValue("CHEMIST_SHRED_BONUS_BM"), eHit_Success, 'beam');
	
	// Add a condition that the target must suffer from a acid burn
    Condition = new class'X2Condition_UnitAffectedByAcidBurn';
	Effect2.AbilityTargetConditions.AddItem(Condition);

	// Create the template using a helper function
	Template = Passive('RpgChemist', "img:///UILibrary_RPG.UIPerk_Chemist_Aptitude", true, Effect);

	// Add another effect that grants a free acid grenade during each mission
	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'AcidGrenade';

	AddSecondaryEffect(Template, ItemEffect);
	AddSecondaryEffect(Template, Effect2);

	return Template;
}

// #######################################################################################
// -------------------- PYROMANIAC--------------------------------------------------------
// #######################################################################################

// Perk name:		Pyromaniac
// Perk effect:		Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission.
// Localized text:	"Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission."
// Config:			(AbilityName="XMBExample_Pyromaniac")

static function X2AbilityTemplate Pyromaniac()
{
	local XMBEffect_BonusDamageByDamageType Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	// Create an effect that adds +1 damage to fire attacks and +1 damage to burn damage
	Effect = new class'XMBEffect_BonusDamageByDamageType';
	Effect.EffectName = 'Pyromaniac';
	Effect.RequiredDamageTypes.AddItem('fire');
	Effect.RequiredDamageTypes.AddItem('Napalm');
	Effect.DamageBonus = class'Config_Manager'.static.GetConfigIntValue("PYROMANIAC_DAMAGE_BONUS");

	// Create the template using a helper function
	Template = Passive('RpgPyromaniac', "img:///UILibrary_RPG.UIPerk_Pyromaniac_Aptitude", true, Effect);

	// Add another effect that grants a free incendiary grenade during each mission
	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'Firebomb';
	AddSecondaryEffect(Template, ItemEffect);

	return Template;
}