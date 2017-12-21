class X2StrategyElement_AugmentationTechs extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	// Research
	Techs.AddItem(CreateAugmentationTemplate());

	// CV
	Techs.AddItem(CreateAugmentationHeadTemplate());
	Techs.AddItem(CreateAugmentationTorsoTemplate());
	Techs.AddItem(CreateAugmentationArmsTemplate());
	Techs.AddItem(CreateAugmentationLegsTemplate());

	// MG
	Techs.AddItem(CreateAugmentationArmsClawTemplate());

	// BM

	return Techs;
}

static function X2DataTemplate CreateAugmentationTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'Augmentations');
	Template.PointsToComplete = 8400;
	Template.SortingTier = 1;
	Template.strImage = "img:///UILibrary_Augmentations.TECH_Augmentations";
	Template.bArmorTech = true;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');

	// Cost
	Resources.ItemTemplateName='AlienAlloy';
	Resources.Quantity = 10;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

// #######################################################################################
// -------------------- PROVING GROUND TECHS ---------------------------------------------
// #######################################################################################
static function X2DataTemplate CreateAugmentationHeadTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'AugmentationHead');
	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 10);
	Template.strImage = "img:///UILibrary_Augmentations.TECH_Augmentations_HEAD";
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveRandomItemReward;
	Template.SortingTier = 1;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Augmentations');

	// Item Reward
	Template.ItemRewards.AddItem('AugmentationHead_Base_CV');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);

	//Artifacts.ItemTemplateName = 'EleriumCore';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);

	Template.bProvingGround = true;
	Template.bRepeatable = true;

	return Template;
}

static function X2DataTemplate CreateAugmentationTorsoTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'AugmentationTorso');
	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 10);
	Template.strImage = "img:///UILibrary_Augmentations.TECH_Augmentations_TORSO";
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveRandomItemReward;
	Template.SortingTier = 1;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Augmentations');

	// Item Reward
	Template.ItemRewards.AddItem('AugmentationTorso_Base_CV');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);

	//Artifacts.ItemTemplateName = 'EleriumCore';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);

	Template.bProvingGround = true;
	Template.bRepeatable = true;

	return Template;
}

static function X2DataTemplate CreateAugmentationArmsTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'AugmentationArms');
	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 10);
	Template.strImage = "img:///UILibrary_Augmentations.TECH_Augmentations_ARM";
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveRandomItemReward;
	Template.SortingTier = 1;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Augmentations');

	// Item Reward
	Template.ItemRewards.AddItem('AugmentationArms_Base_CV');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);

	//Artifacts.ItemTemplateName = 'EleriumCore';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);

	Template.bProvingGround = true;
	Template.bRepeatable = true;

	return Template;
}

static function X2DataTemplate CreateAugmentationLegsTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'AugmentationLegs');
	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 10);
	Template.strImage = "img:///UILibrary_Augmentations.TECH_Augmentations_LEG";
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveRandomItemReward;
	Template.SortingTier = 1;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Augmentations');

	// Item Reward
	Template.ItemRewards.AddItem('AugmentationLegs_Base_CV');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);

	//Artifacts.ItemTemplateName = 'EleriumCore';
	//Artifacts.Quantity = 1;
	//Template.Cost.ArtifactCosts.AddItem(Artifacts);

	Template.bProvingGround = true;
	Template.bRepeatable = true;

	return Template;
}


static function X2DataTemplate CreateAugmentationArmsClawTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources, Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'AugmentationArmsClaw');
	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 14);
	Template.strImage = "img:///UILibrary_Augmentations.TECH_Augmentations_ARM";
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveRandomItemReward;
	Template.SortingTier = 2;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Augmentations');
	Template.Requirements.RequiredTechs.AddItem('PlatedArmor');

	// Item Reward
	Template.ItemRewards.AddItem('AugmentationArms_Claws_MG');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Artifacts.ItemTemplateName = 'EleriumCore';
	Artifacts.Quantity = 1;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	Template.bProvingGround = true;
	Template.bRepeatable = true;

	return Template;
}