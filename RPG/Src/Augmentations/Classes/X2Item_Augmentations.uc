class X2Item_Augmentations extends X2Item config (Augmentations);

struct SlotConfigMap
{
	var EInventorySlot InvSlot;
	var name Category;
};
var config bool bAddCosmeticOnAugmentation;

var config array<EInventorySlot> AugmentationSlots;
var config array<SlotConfigMap> SlotConfig;

var config WeaponDamageValue	CLAWS_BASEDAMAGE;
var config int					CLAWS_AIM;
var config int					CLAWS_CRITCHANCE;
var config int					CLAWS_ICLIPSIZE;
var config int					CLAWS_ISOUNDRANGE;
var config int					CLAWS_IENVIRONMENTDAMAGE;
var config int					CLAWS_UPGRADE_SLOTS;

var config WeaponDamageValue	CYBER_ARM_BASEDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(AugmentationHead_Base_CV());
	Items.AddItem(AugmentationTorso_Base_CV());
	Items.AddItem(AugmentationArms_Base_CV());
	Items.AddItem(AugmentationLegs_Base_CV());
	
	Items.AddItem(AugmentationHead_NeuralGunlink_MG());
	Items.AddItem(AugmentationHead_NeuralTacticalProcessor_BM());

	Items.AddItem(AugmentationArms_Claws_MG());
	Items.AddItem(AugmentationArms_Claws_Left_MG());
	Items.AddItem(AugmentationArms_Grapple_MG());

	Items.AddItem(AugmentationTorso_NanoCoating_MG());
	
	Items.AddItem(AugmentationLegs_JumpModule_MG());
	Items.AddItem(AugmentationLegs_Muscles_MG());
	Items.AddItem(AugmentationLegs_SilentRunners_BM());
	Items.AddItem(AugmentationLegs_JumpModule_BM());
	

	return Items;
}

static function X2EquipmentTemplate AugmentationBase(X2EquipmentTemplate Template)
{
	Template.EquipSound = "StrategyUI_Mindshield_Equip";
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.bShouldCreateDifficultyVariants = true;
	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('AugmentationBaseWillLoss');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.WillLabel, eStat_Will, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_WILL_LOSS);
	Template.OnEquippedFn = OnAugmentationEquipped;

	return Template;
}

static function OnAugmentationEquipped(XComGameState_Item ItemState, XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local UnitValue SeveredBodyPart;
	local XComGameState_HeadquartersProjectHealSoldier ProjectState;
	local XComGameState_HeadquartersXCom XComHQ;

	if (!UnitState.IsSoldier())
		return;

	if (UnitState.IsGravelyInjured() && UnitState.GetUnitValue('SeveredBodyPart', SeveredBodyPart))
	{
		if ((int(SeveredBodyPart.fValue) == eHead && X2EquipmentTemplate(ItemState.GetMyTemplate()).InventorySlot == eInvSlot_AugmentationHead) ||
			(int(SeveredBodyPart.fValue) == eTorso && X2EquipmentTemplate(ItemState.GetMyTemplate()).InventorySlot == eInvSlot_AugmentationTorso) ||
			(int(SeveredBodyPart.fValue) == eArms && X2EquipmentTemplate(ItemState.GetMyTemplate()).InventorySlot == eInvSlot_AugmentationArms) ||
			(int(SeveredBodyPart.fValue) == eLegs && X2EquipmentTemplate(ItemState.GetMyTemplate()).InventorySlot == eInvSlot_AugmentationLegs))
		{
			`LOG(GetFuncName() @ "SeveredBodyPart" @ GetEnum(Enum'ESeveredBodyPart', SeveredBodyPart.fValue),,'Augmentations');
			UnitState.ClearUnitValue('SeveredBodyPart');
			XComHQ = GetAndAddXComHQ(NewGameState);
			ProjectState = XComGameState_HeadquartersProjectHealSoldier(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectHealSoldier'));
			ProjectState.SetProjectFocus(UnitState.GetReference(), NewGameState);
			XComHQ.Projects.AddItem(ProjectState.GetReference());
		}
	}
	UnitState.ModifyCurrentStat(eStat_HP, UnitState.GetMaxStat(eStat_HP) / 3 * 2);

	if (default.bAddCosmeticOnAugmentation)
	{
		switch (X2EquipmentTemplate(ItemState.GetMyTemplate()).InventorySlot)
		{
			case eInvSlot_AugmentationHead:
				UnitState.kAppearance.nmHead = 'HS_Invisible_CAU_M';
				UnitState.kAppearance.nmHelmet = 'Augmentations_Head';
				break;
			case eInvSlot_AugmentationTorso:
				UnitState.kAppearance.nmTorso = 'Augmentations_Torso_KV';
				break;
			case eInvSlot_AugmentationArms:
				UnitState.kAppearance.nmArms = '';
				UnitState.kAppearance.nmLeftArm = 'Augmentations_ArmL_KV';
				UnitState.kAppearance.nmRightArm = 'Augmentations_ArmR_KV';
				break;
			case eInvSlot_AugmentationLegs:
				UnitState.kAppearance.nmLegs = 'Augmentations_Legs_KV';
				break;
		}
	}
}

private static function XComGameState_HeadquartersXCom GetAndAddXComHQ(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	}

	return XComHQ;
}

static function X2DataTemplate AugmentationHead_Base_CV()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationHead_Base_CV');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_head';
	Template.InventorySlot = eInvSlot_AugmentationHead;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentations_Head";
	
	Template.Abilities.AddItem('AugmentedHead');
	
	Template.TradingPostValue = 25;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	return Template;
}

static function X2DataTemplate AugmentationTorso_Base_CV()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationTorso_Base_CV');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_torso';
	Template.InventorySlot = eInvSlot_AugmentationTorso;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Torso";
	
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);

	Template.TradingPostValue = 25;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	
	return Template;
}

static function X2DataTemplate AugmentationArms_Base_CV()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'AugmentationArms_Base_CV');
	Template = X2WeaponTemplate(AugmentationBase(Template));

	Template.ItemCat = 'augmentation_arms';
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Arm";
	
	Template.BaseDamage = default.CYBER_ARM_BASEDAMAGE;
	Template.Abilities.AddItem('AugmentedShield');
	Template.Abilities.AddItem('CyberPunch');
	
	Template.TradingPostValue = 25;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	return Template;
}


static function X2DataTemplate AugmentationLegs_Base_CV()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs_Base_CV');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_legs';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	
	Template.Abilities.AddItem('AugmentedSpeed');

	Template.TradingPostValue = 25;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	return Template;
}


static function X2DataTemplate AugmentationArms_Claws_MG()
{
	local X2PairedWeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2PairedWeaponTemplate', Template, 'AugmentationArms_Claws_MG');
	Template = X2PairedWeaponTemplate(AugmentationBase(Template));
	
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.
	Template.PairedSlot = eInvSlot_TertiaryWeapon;
	Template.PairedTemplateName = 'AugmentationArms_Claws_Left_MG';

	Template.ItemCat = 'augmentation_arms';
	Template.WeaponCat = 'cyberclaws';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_CyberClaws";
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.StowedLocation = eSlot_Claw_R;

	Template.GameArchetype = "CyberClaws_Augmentations.Archetypes.WP_Claws_LG";
	Template.Tier = 2;

	Template.Abilities.AddItem('AugmentedShield');
	Template.Abilities.AddItem('ClawsSlash');
	
	Template.iRadius = 1;
	Template.NumUpgradeSlots = default.CLAWS_UPGRADE_SLOTS;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage = default.CLAWS_BASEDAMAGE;
	Template.Aim = default.CLAWS_AIM;
	Template.CritChance = default.CLAWS_CRITCHANCE;
	Template.iSoundRange = default.CLAWS_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.CLAWS_IENVIRONMENTDAMAGE;
	Template.BaseDamage.DamageType='Melee';

	Template.TradingPostValue = 35;

	Template.DamageTypeTemplateName = 'Melee';

	return Template;
}

static function X2DataTemplate AugmentationArms_Claws_Left_MG()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'AugmentationArms_Claws_Left_MG');
	Template = X2WeaponTemplate(AugmentationBase(Template));

	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'augmentation_arms';
	Template.WeaponCat = 'cyberclaws';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_CyberClaws";
	Template.InventorySlot = eInvSlot_TertiaryWeapon;
	Template.StowedLocation = eSlot_Claw_L;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "CyberClaws_Augmentations.Archetypes.WP_Claws_Left_LG";
	Template.Tier = 2;

	Template.iRadius = 1;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage.DamageType='Melee';

	Template.DamageTypeTemplateName = 'Melee';

	return Template;
}

static function X2DataTemplate AugmentationArms_Grapple_MG()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'AugmentationArms_Grapple_MG');
	Template = X2WeaponTemplate(AugmentationBase(Template));

	Template.ItemCat = 'augmentation_arms';
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Arm";
	
	Template.BaseDamage = default.CYBER_ARM_BASEDAMAGE;
	Template.Abilities.AddItem('AugmentedShield');
	Template.Abilities.AddItem('CyberPunch');
	Template.Abilities.AddItem('GrapplePowered');
	
	Template.TradingPostValue = 35;
	Template.PointsToComplete = 0;
	Template.Tier = 2;

	return Template;
}

static function X2DataTemplate AugmentationTorso_NanoCoating_MG()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationTorso_NanoCoating_MG');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_torso';
	Template.InventorySlot = eInvSlot_AugmentationTorso;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Torso";
	
	Template.Abilities.AddItem('NanoCoating');

	Template.TradingPostValue = 35;
	Template.Tier = 2;

	return Template;
}

static function X2DataTemplate AugmentationLegs_JumpModule_MG()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs_JumpModule_MG');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_legs';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	
	Template.Abilities.AddItem('AugmentedSpeed');
	Template.Abilities.AddItem('CyberJumpLegsMK1');

	Template.TradingPostValue = 35;
	Template.Tier = 2;

	return Template;
}

static function X2DataTemplate AugmentationLegs_JumpModule_BM()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs_JumpModule_BM');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_legs';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	
	Template.Abilities.AddItem('AugmentedSpeed');
	Template.Abilities.AddItem('CyberJumpLegsMK2');

	Template.TradingPostValue = 50;
	Template.Tier = 3;

	return Template;
}

static function X2DataTemplate AugmentationHead_NeuralGunlink_MG()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationHead_NeuralGunlink_MG');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_head';
	Template.InventorySlot = eInvSlot_AugmentationHead;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentations_Head";
	
	Template.Abilities.AddItem('AugmentedHead');
	Template.Abilities.AddItem('NeuralGunLink');
	
	Template.TradingPostValue = 35;
	Template.PointsToComplete = 0;
	Template.Tier = 2;

	return Template;
}

static function X2DataTemplate AugmentationHead_NeuralTacticalProcessor_BM()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationHead_NeuralTacticalProcessor_BM');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_head';
	Template.InventorySlot = eInvSlot_AugmentationHead;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentations_Head";
	
	Template.Abilities.AddItem('AugmentedHead');
	Template.Abilities.AddItem('NeuralTacticalProcessor');
	
	Template.TradingPostValue = 50;
	Template.PointsToComplete = 0;
	Template.Tier = 3;

	return Template;
}

static function X2DataTemplate AugmentationLegs_Muscles_MG()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs_Muscles_MG');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_legs';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	
	Template.Abilities.AddItem('AugmentedSpeed');
	Template.Abilities.AddItem('CarryHeavyWeapons');

	Template.TradingPostValue = 35;
	Template.Tier = 2;

	return Template;
}

static function X2DataTemplate AugmentationLegs_SilentRunners_BM()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs_SilentRunners_BM');
	Template = AugmentationBase(Template);

	Template.ItemCat = 'augmentation_legs';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	
	Template.Abilities.AddItem('AugmentedSpeed');
	Template.Abilities.AddItem('Shadow');

	Template.TradingPostValue = 50;
	Template.Tier = 3;

	return Template;
}



defaultproperties
{
	bShouldCreateDifficultyVariants = true
}