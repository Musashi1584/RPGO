class X2Item_Augmentations extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(AugmentationHead());
	Items.AddItem(AugmentationTorso());
	Items.AddItem(AugmentationArms());
	Items.AddItem(AugmentationLegs());

	return Items;
}

static function X2DataTemplate AugmentationHead()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationHead');
	Template.ItemCat = 'augmentation';
	Template.InventorySlot = eInvSlot_AugmentationHead;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentations_Head";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	//Template.Abilities.AddItem('');

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

static function X2DataTemplate AugmentationTorso()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationTorso');
	Template.ItemCat = 'augmentation';
	Template.InventorySlot = eInvSlot_AugmentationTorso;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Torso";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	//Template.Abilities.AddItem('');

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

static function X2DataTemplate AugmentationArms()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationArms');
	Template.ItemCat = 'augmentation';
	Template.InventorySlot = eInvSlot_AugmentationArms;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Arm";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	//Template.Abilities.AddItem('');

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

static function X2DataTemplate AugmentationLegs()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AugmentationLegs');
	Template.ItemCat = 'augmentation';
	Template.InventorySlot = eInvSlot_AugmentationLegs;
	Template.strImage = "img:///UILibrary_Augmentations.Inv_Augmentation_Leg";
	Template.EquipSound = "StrategyUI_Mindshield_Equip";

	//Template.Abilities.AddItem('');

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