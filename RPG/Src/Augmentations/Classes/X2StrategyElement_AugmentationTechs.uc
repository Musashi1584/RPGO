class X2StrategyElement_AugmentationTechs extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	// Research
	Techs.AddItem(CreateAugmentationTemplate());

	// CV
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationHead', 'AugmentationHead_Base_CV', 1, "img:///UILibrary_Augmentations.TECH_Augmentations_HEAD"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationTorso', 'AugmentationTorso_Base_CV', 1, "img:///UILibrary_Augmentations.TECH_Augmentations_TORSO"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationArms', 'AugmentationArms_Base_CV', 1, "img:///UILibrary_Augmentations.TECH_Augmentations_ARM"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationLegs', 'AugmentationLegs_Base_CV', 1, "img:///UILibrary_Augmentations.TECH_Augmentations_LEG"));

	// MG
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationArmsClaw', 'AugmentationArms_Claws_MG', 2, "img:///UILibrary_Augmentations.TECH_Augmentations_ARM"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationArmsGrapple', 'AugmentationArms_Grapple_MG', 2, "img:///UILibrary_Augmentations.TECH_Augmentations_ARM"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationLegsJumpModuleMK1', 'AugmentationLegs_JumpModule_MG', 2, "img:///UILibrary_Augmentations.TECH_Augmentations_LEG"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationLegsMuscles', 'AugmentationLegs_Muscles_MG', 2, "img:///UILibrary_Augmentations.TECH_Augmentations_LEG"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationTorsoNanoCoating', 'AugmentationTorso_NanoCoating_MG', 2, "img:///UILibrary_Augmentations.TECH_Augmentations_TORSO"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationHeadNeuralGunlink', 'AugmentationHead_NeuralGunlink_MG', 2, "img:///UILibrary_Augmentations.TECH_Augmentations_HEAD"));

	// BM
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationLegsJumpModuleMK2', 'AugmentationLegs_JumpModule_BM', 3, "img:///UILibrary_Augmentations.TECH_Augmentations_LEG"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationLegsSilentRunners', 'AugmentationLegs_SilentRunners_BM', 3, "img:///UILibrary_Augmentations.TECH_Augmentations_LEG"));
	Techs.AddItem(CreateProvingGroundTemplate('AugmentationHeadNeuralTacticalProcessor', 'AugmentationHead_NeuralTacticalProcessor_BM', 3, "img:///UILibrary_Augmentations.TECH_Augmentations_HEAD"));
	
	return Techs;
}

// #######################################################################################
// -------------------------------- RESEARCH ---------------------------------------------
// #######################################################################################
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
static function X2DataTemplate CreateProvingGroundTemplate(name TemplateName, name ItemReward, int Tier, string Image)
{
	local X2TechTemplate Template;
	local ArtifactCost Resources, Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, TemplateName);
	
	Template.strImage = Image;

	Template.SortingTier = Tier;
	Template.Requirements.RequiredTechs.AddItem('Augmentations');

	switch (Tier)
	{
		case 1:
			Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 10);

			// Cost
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = 50;
			Template.Cost.ResourceCosts.AddItem(Resources);
			break;
		case 2:
			Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 13);
			Template.Requirements.RequiredTechs.AddItem('PlatedArmor');

			// Cost
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = 75;
			Template.Cost.ResourceCosts.AddItem(Resources);

			Artifacts.ItemTemplateName = 'EleriumCore';
			Artifacts.Quantity = 1;
			Template.Cost.ArtifactCosts.AddItem(Artifacts);

			break;
		case 3:
			Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, 16);
			Template.Requirements.RequiredTechs.AddItem('PowerArmor');

			// Cost
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = 100;
			Template.Cost.ResourceCosts.AddItem(Resources);

			Artifacts.ItemTemplateName = 'EleriumCore';
			Artifacts.Quantity = 1;
			Template.Cost.ArtifactCosts.AddItem(Artifacts);
			break;
	}

	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveRandomItemReward;
	Template.ItemRewards.AddItem(ItemReward);

	Template.bProvingGround = true;
	Template.bRepeatable = true;

	return Template;
}