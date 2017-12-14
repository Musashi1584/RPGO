class X2Item_Augmentations extends X2Item config (Augmentations);

struct SlotConfigMap
{
	var EInventorySlot InvSlot;
	var name Category;
};

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
	
	Items.AddItem(AugmentationArms_Claws_MG());
	Items.AddItem(AugmentationClaws_Left_MG());
	Items.AddItem(AugmentationArms_Grapple_MG());

	return Items;
}

static function X2DataTemplate AugmentationHead_Base_CV()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationHead_Base_CV');
	Template.ItemCat = 'augmentation_head';
	Template.InventorySlot = eInvSlot_AugmentationHead;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentations_Head";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 12;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	Template.bShouldCreateDifficultyVariants = true;

	//// Requirements
	//Template.Requirements.RequiredTechs.AddItem('AutopsySectoid');
	//
	//// Cost
	//Resources.ItemTemplateName = 'Supplies';
	//Resources.Quantity = 45;
	//Template.Cost.ResourceCosts.AddItem(Resources);
	//
	//Artifacts.ItemTemplateName = 'CorpseSectoid';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);
	
	return Template;
}

static function X2DataTemplate AugmentationTorso_Base_CV()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationTorso_Base_CV');
	Template.ItemCat = 'augmentation_torso';
	Template.InventorySlot = eInvSlot_AugmentationTorso;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Torso";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 12;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	Template.bShouldCreateDifficultyVariants = true;

	//// Requirements
	//Template.Requirements.RequiredTechs.AddItem('AutopsySectoid');
	//
	//// Cost
	//Resources.ItemTemplateName = 'Supplies';
	//Resources.Quantity = 45;
	//Template.Cost.ResourceCosts.AddItem(Resources);
	//
	//Artifacts.ItemTemplateName = 'CorpseSectoid';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);
	
	return Template;
}

static function X2DataTemplate AugmentationArms_Base_CV()
{
	local X2WeaponTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'AugmentationArms_Base_CV');
	Template.ItemCat = 'augmentation_arms';
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Arm";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	Template.BaseDamage = default.CYBER_ARM_BASEDAMAGE;
	Template.Abilities.AddItem('CyberPunch');
	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 12;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	Template.bShouldCreateDifficultyVariants = true;

	//// Requirements
	//Template.Requirements.RequiredTechs.AddItem('AutopsySectoid');
	//
	//// Cost
	//Resources.ItemTemplateName = 'Supplies';
	//Resources.Quantity = 45;
	//Template.Cost.ResourceCosts.AddItem(Resources);
	//
	//Artifacts.ItemTemplateName = 'CorpseSectoid';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);
	
	return Template;
}


static function X2DataTemplate AugmentationLegs_Base_CV()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs_Base_CV');
	Template.ItemCat = 'augmentation_legs';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 12;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	Template.bShouldCreateDifficultyVariants = true;

	//// Requirements
	//Template.Requirements.RequiredTechs.AddItem('AutopsySectoid');
	//
	//// Cost
	//Resources.ItemTemplateName = 'Supplies';
	//Resources.Quantity = 45;
	//Template.Cost.ResourceCosts.AddItem(Resources);
	//
	//Artifacts.ItemTemplateName = 'CorpseSectoid';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);
	
	return Template;
}


static function X2DataTemplate AugmentationArms_Claws_MG()
{
	local X2PairedWeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2PairedWeaponTemplate', Template, 'AugmentationArms_Claws_MG');
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.
	Template.PairedSlot = eInvSlot_TertiaryWeapon;
	Template.PairedTemplateName = 'AugmentationClaws_Left_MG';

	Template.ItemCat = 'augmentation_arms';
	Template.WeaponCat = 'cyberclaws';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_CyberClaws";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.StowedLocation = eSlot_Claw_R;

	Template.GameArchetype = "CyberClaws_Augmentations.Archetypes.WP_Claws_LG";
	Template.Tier = 2;

	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('ClawsSlash');
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);


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

	Template.CanBeBuilt = true;
	Template.bInfiniteItem = false;

	Template.DamageTypeTemplateName = 'Melee';

	return Template;
}

static function X2DataTemplate AugmentationClaws_Left_MG()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'AugmentationClaws_Left_MG');
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'augmentation_arms';
	Template.WeaponCat = 'cyberclaws';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_CyberClaws";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";
	Template.InventorySlot = eInvSlot_TertiaryWeapon;
	Template.StowedLocation = eSlot_Claw_L;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "CyberClaws_Augmentations.Archetypes.WP_Claws_Left_LG";
	Template.Tier = 2;

	Template.iRadius = 1;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;
	Template.BaseDamage.DamageType='Melee';

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;

	Template.DamageTypeTemplateName = 'Melee';

	return Template;
}

static function X2DataTemplate AugmentationArms_Grapple_MG()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationArms_Grapple_MG');
	Template.ItemCat = 'augmentation_arms';
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Arm";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	Template.Abilities.AddItem('ExMachina');
	Template.Abilities.AddItem('CyberPunch');
	Template.Abilities.AddItem('GrapplePowered');
	Template.Abilities.AddItem('AugmentationBaseStats');
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_Augmentations_Abilities'.default.AUGMENTATION_BASE_MITIGATION_AMOUNT);

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 12;
	Template.PointsToComplete = 0;
	Template.Tier = 2;

	Template.bShouldCreateDifficultyVariants = true;

	//// Requirements
	//Template.Requirements.RequiredTechs.AddItem('AutopsySectoid');
	//
	//// Cost
	//Resources.ItemTemplateName = 'Supplies';
	//Resources.Quantity = 45;
	//Template.Cost.ResourceCosts.AddItem(Resources);
	//
	//Artifacts.ItemTemplateName = 'CorpseSectoid';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);
	
	return Template;
}

defaultproperties
{
	bShouldCreateDifficultyVariants = true
}