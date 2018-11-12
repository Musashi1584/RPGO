class X2TemplateHelper_RPGOverhaul extends Object config (RPG);

struct AbilityWeaponCategoryRestriction
{
	var name AbilityName;
	var array<name> WeaponCategories;
};

struct AbilityPrerequisite
{
	var array<name> PrerequisiteTree;
};

struct MutuallyExclusiveAbilityPool
{
	var array<name> Abilities;
};


struct UniqueItemCategories
{
	var array<name> Categories;
};

struct WeaponProficiency
{
	var name AbilityName;
	var name UnlocksWeaponCategory;
};


var config array<AbilityWeaponCategoryRestriction> AbilityWeaponCategoryRestrictions;
var config array<AbilityPrerequisite> AbilityPrerequisites;
var config array<MutuallyExclusiveAbilityPool> MutuallyExclusiveAbilities;
var config array<UniqueItemCategories> LoadoutUniqueItemCategories;
var config array<WeaponProficiency> WeaponProficiencies;
var config array<int> VERY_SHORT_RANGE;
var config array<SoldierSpecialization> Specializations;
var config array<name> ValidLightEmUpAbilities;

var config int ShotgunAimBonus;
var config int ShotgunCritBonus;
var config int CannonDamageBonus;
var config int AutoPistolCritChanceBonus;
var config int DefaultWeaponUpgradeSlots;

static function SetupSpecialization(name SoldierClassTemplate)
{
	local X2SoldierClassTemplateManager Manager;
	local X2SoldierClassTemplate Template;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;
	local array<SoldierSpecialization> ValidSpecs;
	local int Index;

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	Template = Manager.FindSoldierClassTemplate(SoldierClassTemplate);

	Template.AbilityTreeTitles.Length = 0;
	class'X2SoldierClassTemplatePlugin'.static.ResetDummySlot(Template);

	default.Specializations = GetSpecializations();

	for (Index = 0; Index < default.Specializations.Length; Index++)
	{
		UniversalSoldierClassTemplate = new(None, string(default.Specializations[Index].TemplateName))class'X2UniversalSoldierClassInfo';
		`LOG("Specialization" @ Index @ default.Specializations[Index].TemplateName @ default.Specializations[Index].bEnabled @ UniversalSoldierClassTemplate.ClassSpecializationTitle,, 'RPG');
		AddAbilityRanks(UniversalSoldierClassTemplate.ClassSpecializationTitle, UniversalSoldierClassTemplate.AbilitySlots);
	}
}

static function array<SoldierSpecialization> GetSpecializations()
{
	local X2SoldierClassTemplateManager Manager;
	local X2SoldierClassTemplate Template;
	local array<SoldierSpecialization> ValidSpecs;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;
	local SoldierClassAbilitySlot Slot;
	local int Index;
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Ability;
	local bool bHasAbilityInDeck;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	Template = Manager.FindSoldierClassTemplate('UniversalSoldier');

	// Sort here cause plugin mods which loaded first could added to the array already
	default.Specializations.Sort(SortSpecializations);

	for (Index = 0; Index < default.Specializations.Length; Index++)
	{
		UniversalSoldierClassTemplate = new(None, string(default.Specializations[Index].TemplateName))class'X2UniversalSoldierClassInfo';
		if (UniversalSoldierClassTemplate.AbilitySlots.Length > 0 && default.Specializations[Index].bEnabled)
		{
			bHasAbilityInDeck = false;
			foreach UniversalSoldierClassTemplate.AbilitySlots(Slot)
			{
				Ability = TemplateManager.FindAbilityTemplate(Slot.AbilityType.AbilityName);
				if (Ability != none)
				{
					bHasAbilityInDeck = true;
					break;
				}
			}
			
			if (bHasAbilityInDeck && ValidSpecs.Find('TemplateName', default.Specializations[Index].TemplateName) == INDEX_NONE)
			{
				ValidSpecs.AddItem(default.Specializations[Index]);
			}
		}
		else
		{
			`LOG("Removing Specialization" @ Index @ default.Specializations[Index].TemplateName,, 'RPG');
			class'X2SoldierClassTemplatePlugin'.static.DeleteSpecialization(Template, default.Specializations[Index].TemplateName, Index);
		}
	}
	
	return ValidSpecs;
}

function int SortSpecializations(SoldierSpecialization A, SoldierSpecialization B)
{
	return A.Order > B.Order ? -1 : 0;
}

static function AddAbilityRanks(string SpecializationTitle, array<SoldierClassAbilitySlot> AbilitySlots)
{
	local X2SoldierClassTemplateManager Manager;
	local X2SoldierClassTemplate Template;
	local SoldierClassAbilitySlot Slot;
	local int RankIndex;

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();

	Template = Manager.FindSoldierClassTemplate('UniversalSoldier');

	for (RankIndex = 1; RankIndex < Template.GetMaxConfiguredRank(); RankIndex++)
	{
		Slot = AbilitySlots[RankIndex - 1];
		`LOG("Adding Spec" @ RankIndex - 1 @ SpecializationTitle @ "Slot" @ Slot.AbilityType.AbilityName,, 'RPG');
		class'X2SoldierClassTemplatePlugin'.static.AddSlot(Template, Slot, RankIndex);
	}

	Template.AbilityTreeTitles.AddItem(SpecializationTitle);

	//for (RankIndex = 1; RankIndex < class'X2ExperienceConfig'.static.GetMaxRank(); RankIndex++)
	//{
	//	`LOG("Rank" @ RankIndex,, 'RPG');
	//	foreach Template.SoldierRanks[RankIndex].AbilitySlots(Slot)
	//	{
	//		`LOG("Adding Spec" @ SpecializationTitle @ "Slot" @ Slot.AbilityType.AbilityName,, 'RPG');
	//	}
	//}
}

static function XComGameState_HeadquartersXCom GetNewXComHQState(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom NewXComHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', NewXComHQ)
	{
		break;
	}

	if(NewXComHQ == none)
	{
		NewXComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		NewXComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', NewXComHQ.ObjectID));
	}

	return NewXComHQ;
}

static function FinalizeUnitAbilities(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local X2ConditionDisabled DisabledCondition;
	local int Index, CategoryIndex;
	local name WeaponCategory;
	local EInventorySlot InvSlot;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;
	local AbilitySetupData Data, EmptyData;
	local array<AbilitySetupData> DataToAdd;

	if (!UnitState.IsSoldier())
		return;

	CurrentInventory = UnitState.GetAllInventoryItems(StartState);

	for(Index = SetupData.Length; Index >= 0; Index--)
	{
		// Deactivate all ranged abilities that are associated with the primary weapon slot
		//if (class'X2TemplateHelper_RPGOverhaul'.static.IsPrimaryMelee(UnitState) &&
		//	SetupData[Index].Template.DefaultSourceItemSlot == eInvSlot_PrimaryWeapon &&
		//	SetupData[Index].Template.TargetingMethod == class'X2TargetingMethod_OverTheShoulder')
		//{
		//	DisabledCondition = new class'X2ConditionDisabled';
		//	SetupData[Index].Template.AbilityTargetConditions.AddItem(DisabledCondition);
		//}

		//`LOG(GetFuncName() @ UnitState.GetFullName() @ SetupData[Index].TemplateName @ SetupData[Index].Template.DefaultSourceItemSlot,, 'RPG');

		CategoryIndex = default.AbilityWeaponCategoryRestrictions.Find('AbilityName', SetupData[Index].TemplateName);
		//`LOG(GetFuncName() @ SetupData[Index].TemplateName @ SetupData[Index].Template.DefaultSourceItemSlot @ Index,, 'RPG');
		if (CategoryIndex != INDEX_NONE)
		{
			foreach default.AbilityWeaponCategoryRestrictions[CategoryIndex].WeaponCategories(WeaponCategory)
			{
				InvSlot = FindInventorySlotForItemCategory(UnitState, WeaponCategory, InventoryItem, StartState);
				if (InvSlot != eInvSlot_Unknown)
				{
					//SetupData[Index].Template.DefaultSourceItemSlot = InvSlot;
					SetupData[Index].SourceWeaponRef = InventoryItem.GetReference();
					`LOG(GetFuncName()  @ UnitState.GetFullName() @ "Patching" @ SetupData[Index].TemplateName @ "setting DefaultSourceItemSlot to" @ InvSlot @ SetupData[Index].SourceWeaponRef.ObjectID,, 'RPG');
				}
			}
		}

		// Do this here again because the launch grenade ability is now on the grenade lanucher itself and not in earned soldier abilities
		if (SetupData[Index].Template.bUseLaunchedGrenadeEffects)
		{
			Data = EmptyData;
			Data.TemplateName = SetupData[Index].TemplateName;
			Data.Template = SetupData[Index].Template;
			Data.SourceWeaponRef = SetupData[Index].SourceWeaponRef;

			// Remove the original ability
			SetupData.Remove(Index, 1);

			//  populate a version of the ability for every grenade in the inventory
			foreach CurrentInventory(InventoryItem)
			{
				if (InventoryItem.bMergedOut) 
					continue;

				if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
				{ 
					Data.SourceAmmoRef = InventoryItem.GetReference();
					DataToAdd.AddItem(Data);
					`LOG(GetFuncName()  @ UnitState.GetFullName() @ "Patching" @ Data.TemplateName @ "Setting SourceAmmoRef" @ InventoryItem.GetMyTemplateName() @ Data.SourceAmmoRef.ObjectID,, 'RPG');
				}
			}
		}
	}

	foreach DataToAdd(Data)
	{
		SetupData.AddItem(Data);
	}
}

static function PatchAbilitiesWeaponCondition()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Condition_WeaponCategory	WeaponCondition;
	local AbilityWeaponCategoryRestriction Restriction;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.AbilityWeaponCategoryRestrictions(Restriction)
	{
		Template = TemplateManager.FindAbilityTemplate(Restriction.AbilityName);
		if (Template != none && !X2AbilityToHitCalc_StandardMelee(Template.AbilityToHitCalc).bReactionFire)
		{
			WeaponCondition = new class'X2Condition_WeaponCategory';
			WeaponCondition.IncludeWeaponCategories = Restriction.WeaponCategories;
			Template.AbilityTargetConditions.AddItem(WeaponCondition);
		}
	}
}

static function AddWeaponCategoryConditionToEffect(name AbilityName, X2Effect Effect)
{
	local X2Condition_WeaponCategory	WeaponCategoryCondition;
	local int							Index;
	local name							Category;

	Index = default.AbilityWeaponCategoryRestrictions.Find('AbilityName', AbilityName);
	if (Index != INDEX_NONE)
	{
		WeaponCategoryCondition = new class'X2Condition_WeaponCategory';

		foreach default.AbilityWeaponCategoryRestrictions[Index].WeaponCategories(Category)
		{
			WeaponCategoryCondition.IncludeWeaponCategories.AddItem(Category);
		}
		Effect.TargetConditions.AddItem(WeaponCategoryCondition);
	}
}

static function PatchAcademyUnlocks(name SoldierClassName)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local array<X2StrategyElementTemplate> Templates;
	local X2StrategyElementTemplate Template;
	local X2SoldierAbilityUnlockTemplate SoldierUnlockTemplate;
	local array<name> HeroClasses;
	local array<Name> TemplateNames;
	local Name TemplateName;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate;
	local int Difficulty;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Templates = TemplateManager.GetAllTemplatesOfClass(class'X2SoldierAbilityUnlockTemplate');

	HeroClasses.AddItem('Templar');
	HeroClasses.AddItem('Skirmisher');
	HeroClasses.AddItem('Reaper');

	foreach Templates(Template)
	{
		SoldierUnlockTemplate = X2SoldierAbilityUnlockTemplate(Template);

		if (SoldierUnlockTemplate == none)
		{
			continue;
		}
		
		//`LOG(GetFuncName() @ SoldierUnlockTemplate.DataName @ SoldierUnlockTemplate.bAllClasses @ SoldierUnlockTemplate.Requirements.RequiredSoldierClass,, 'RPG');
		
		if (!SoldierUnlockTemplate.bAllClasses &&
			SoldierUnlockTemplate.Requirements.RequiredSoldierClass != '' &&
			HeroClasses.Find(SoldierUnlockTemplate.Requirements.RequiredSoldierClass) == INDEX_NONE
		)
		{
			SoldierUnlockTemplate.AllowedClasses.AddItem(SoldierClassName);
			SoldierUnlockTemplate.Requirements.RequiredSoldierClass = SoldierClassName;
			SoldierUnlockTemplate.Cost.ResourceCosts[0].Quantity = 300;
			`LOG(GetFuncName() @ "patching template" @ Template.DataName,, 'RPG');
		}
	}

	TemplateManager.GetTemplateNames(TemplateNames);
	
	foreach TemplateNames(TemplateName)
	{
 		TemplateManager.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
		foreach DataTemplates(DataTemplate)
		{
			Template = X2StrategyElementTemplate(DataTemplate);
			if(Template != none)
			{
				Difficulty = GetDifficultyFromTemplateName(TemplateName);
				ReconfigFacilities(Template, Difficulty);
			}
		}
	}
}

static function ReconfigFacilities(X2StrategyElementTemplate Template, int Difficulty)
{
	local int						i;
	local ArtifactCost				Resources;
	local X2FacilityTemplate		FacilityTemplate;

	FacilityTemplate = X2FacilityTemplate (Template);
	if (FacilityTemplate != none)
	{
		if (FacilityTemplate.DataName == 'OfficerTrainingSchool')
		{
			FacilityTemplate.SoldierUnlockTemplates.RemoveItem('HuntersInstinctUnlock');
			FacilityTemplate.SoldierUnlockTemplates.RemoveItem('HitWhereItHurtsUnlock');
			FacilityTemplate.SoldierUnlockTemplates.RemoveItem('BiggestBoomsUnlock');
		}
	}
}

static function int GetDifficultyFromTemplateName(name TemplateName)
{
	return int(GetRightMost(string(TemplateName)));
}


static function PatchWeapons()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<name> TemplateNames;
	local array<X2DataTemplate> DifficultyVariants;
	local name TemplateName;
	local X2DataTemplate ItemTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local X2GremlinTemplate GremlinTemplate;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ItemTemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficultyVariants);
		// Iterate over all variants
		
		foreach DifficultyVariants(ItemTemplate)
		{
			WeaponTemplate = X2WeaponTemplate(ItemTemplate);
			if (WeaponTemplate != none)
			{
				//if (WeaponTemplate.BaseDamage.Damage > 0
				//	&& WeaponTemplate.WeaponCat != 'shotgun'
				//	&& WeaponTemplate.iRange == INDEX_NONE)
				//{
				//	`LOG(GetFuncName() @ "Add DamageModifierCoverType to" @ WeaponTemplate.DataName,, 'RPG');
				//	AddAbilityToWeaponTemplate(WeaponTemplate, 'DamageModifierCoverType');
				//}

				// @TODO Patch enviromental damage
				if (InStr(WeaponTemplate.DataName, "CV") != INDEX_NONE || InStr(WeaponTemplate.DataName, "T1") != INDEX_NONE)
				{
					//WeaponTemplate.BaseDamage
				}

				switch (WeaponTemplate.WeaponCat)
				{
					case 'Gremlin':
						GremlinTemplate = X2GremlinTemplate(WeaponTemplate);
						AddAbilityToGremlinTemplate(GremlinTemplate, 'IntrusionProtocol', true);
						AddAbilityToGremlinTemplate(GremlinTemplate, 'AidProtocol', true);
						AddAbilityToGremlinTemplate(GremlinTemplate, 'IntrusionProtocol', true);
						break;
					case 'rifle':
					case 'sparkrifle':
						if (InStr(WeaponTemplate.DataName, "SMG") == INDEX_NONE)
						{
							AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire', true);
							if (InStr(string(WeaponTemplate.DataName), "CV") != INDEX_NONE)
								WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireConvA');
							if (InStr(string(WeaponTemplate.DataName), "MG") != INDEX_NONE)
								WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireMagA');
							if (InStr(string(WeaponTemplate.DataName), "BM") != INDEX_NONE)
								WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireBeamA');
						}
						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'bullpup':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire', true);
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SkirmisherStrike', true);
						WeaponTemplate.iClipSize += 1;
						if (InStr(string(WeaponTemplate.DataName), "CV") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireConvA');
						if (InStr(string(WeaponTemplate.DataName), "MG") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireMagA');
						if (InStr(string(WeaponTemplate.DataName), "BM") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireBeamA');

						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'sniper_rifle':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'Squadsight', true);

						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'vektor_rifle':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SilentKillPassive');

						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'shotgun':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierCoverType');
						AddAbilityToWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierRange');
						
						WeaponTemplate.CritChance += default.ShotgunCritBonus;
						WeaponTemplate.Aim += default.ShotgunAimBonus;
						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'cannon':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire', true);
						AddAbilityToWeaponTemplate(WeaponTemplate, 'Suppression', true);
						AddAbilityToWeaponTemplate(WeaponTemplate, 'HeavyWeaponMobilityPenalty', true);
						//AddAbilityToWeaponTemplate(WeaponTemplate, 'AutoFireShot');
						//AddAbilityToWeaponTemplate(WeaponTemplate, 'AutoFireOverwatch');
						
						WeaponTemplate.BaseDamage.Damage += default.CannonDamageBonus;
						WeaponTemplate.iClipSize += 2;
						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'pistol':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'PistolStandardShot', true);
						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'sidearm':
						WeaponTemplate.RangeAccuracy = default.VERY_SHORT_RANGE;
						WeaponTemplate.CritChance += default.AutoPistolCritChanceBonus;
						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'sword':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SwordSlice', true);
						WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
						break;
					case 'grenade_launcher':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'LaunchGrenade', true);
						break;
					case 'wristblade':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SkirmisherGrapple', true);
						break;
					case 'claymore':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'ThrowClaymore', true);
						break;
					case 'holotargeter':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'RapidTargeting', true);
						break;
					default:
						//`LOG(GetFuncName() @ WeaponTemplate.GetItemFriendlyName() @ WeaponTemplate.DataName @ WeaponTemplate.WeaponCat @ "ignored",, 'RPG');
						break;
				}
			}

			// Patch hero weapons
			if (WeaponTemplate != none &&
				(WeaponTemplate.DataName == 'WristBlade_CV' ||
				WeaponTemplate.DataName == 'ShardGauntlet_CV' ||
				WeaponTemplate.DataName == 'VektorRifle_CV' ||
				WeaponTemplate.DataName == 'Bullpup_CV' ||
				WeaponTemplate.DataName == 'Reaper_Claymore' ||
				WeaponTemplate.DataName == 'Sidearm_CV')
			)
			{
				WeaponTemplate.StartingItem = true;
				`LOG("Unlock" @ WeaponTemplate.DataName,, 'RPG');
			}
		}
	}
}




static function UpdateStorage()
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local array<X2ItemTemplate> ItemTemplates;
	local XComGameState_Item NewItemState;
	local int i;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Musashi: Updating HQ Storage to add Axes");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('WristBlade_CV'));
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('ShardGauntlet_CV'));
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('VektorRifle_CV'));
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('Bullpup_CV'));
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('Reaper_Claymore'));
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('Sidearm_CV'));

	for (i = 0; i < ItemTemplates.Length; ++i)
	{
		if(ItemTemplates[i] != none)
		{
			if (!XComHQ.HasItem(ItemTemplates[i]))
			{
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " not found, adding to inventory",, 'RPG');
				NewItemState = ItemTemplates[i].CreateInstanceFromTemplate(NewGameState);
				NewGameState.AddStateObject(NewItemState);
				XComHQ.AddItemToHQInventory(NewItemState);
				History.AddGameStateToHistory(NewGameState);
			} else {
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " found, skipping inventory add",, 'RPG');
				History.CleanupPendingGameState(NewGameState);
			}
		}
	}
}


static function PatchAbilityPrerequisites()
{
	local X2AbilityTemplateManager				TemplateManager;
	local X2AbilityTemplate						Template;
	local AbilityPrerequisite					Prerequisite;
	local MutuallyExclusiveAbilityPool			Exclusive;
	local int									Index;
	local name									Ability;
	
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.AbilityPrerequisites(Prerequisite)
	{
		for (Index = 1; Index < Prerequisite.PrerequisiteTree.Length; Index++)
		{
			Template = TemplateManager.FindAbilityTemplate(Prerequisite.PrerequisiteTree[Index]);
			Template.PrerequisiteAbilities.AddItem(Prerequisite.PrerequisiteTree[Index - 1]);
			`LOG(GetFuncName() @ Template.DataName @ "adding" @ Prerequisite.PrerequisiteTree[Index - 1] @ "to PrerequisiteAbilities",, 'RPG');
		}
	}

	foreach default.MutuallyExclusiveAbilities(Exclusive)
	{
		for (Index = 0; Index < Exclusive.Abilities.Length; Index++)
		{
			Template = TemplateManager.FindAbilityTemplate(Exclusive.Abilities[Index]);
			foreach Exclusive.Abilities(Ability)
			{
				if (Template.DataName != Ability)
				{
					Template.PrerequisiteAbilities.AddItem(name("NOT_" $ Ability));
					`LOG(GetFuncName() @ Template.DataName @ "adding" @ name("NOT_" $ Ability) @ "to PrerequisiteAbilities",, 'RPG');
				}
			}
		}
	}
}

static function PatchSpecialShotAbiitiesForLightEmUp()
{
	local X2AbilityTemplateManager						TemplateManager;
	local X2AbilityTemplate								Template;
	local name											TemplateName;
	local X2AbilityCost_ActionPoints					ActionPointCost;
	local int											Index;
	
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.ValidLightEmUpAbilities(TemplateName)
	{
		Template = TemplateManager.FindAbilityTemplate(TemplateName);
		if (Template != none)
		{
			for (Index = 0; Index < Template.AbilityCosts.Length; Index++)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(Template.AbilityCosts[Index]);
				if (ActionPointCost != none)
				{
					ActionPointCost.AllowedTypes.AddItem(class'X2Effect_LightEmUp'.default.LightEmUpActionPoint);
				}
			}
		}
	}
}

static function PatchPistolStandardShot()
{
	local X2AbilityTemplateManager						TemplateManager;
	local X2AbilityTemplate								Template;
	local array<name>									TemplateNames;
	local name											TemplateName;
	local X2AbilityCost_ActionPoints					ActionPointCost;
	
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	TemplateNames.AddItem('PistolStandardShot');
	
	foreach TemplateNames(TemplateName)
	{
		Template = TemplateManager.FindAbilityTemplate(TemplateName);
		if (Template != none)
		{
			ActionPointCost = GetAbilityCostActionPoints(Template);
			if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllSoldierAbilities.Find('QuickdrawNew') == INDEX_NONE)
			{
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('QuickDrawPrimary');
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('QuickdrawNew');
			}
		}
	}
}

static function X2AbilityCost_ActionPoints GetAbilityCostActionPoints(X2AbilityTemplate Template)
{
	local X2AbilityCost Cost;
	foreach Template.AbilityCosts(Cost)
	{
		if (X2AbilityCost_ActionPoints(Cost) != none)
		{
			return X2AbilityCost_ActionPoints(Cost);
		}
	}
	return none;
}

static function PatchTraceRounds()
{
	local X2ItemTemplateManager					TemplateManager;
	local X2AmmoTemplate						Template;

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	Template = X2AmmoTemplate(TemplateManager.FindItemTemplate('TracerRounds'));
	Template.Abilities.Length = 0;
	Template.Abilities.AddItem('Holotargeting');

	Template.Cost.ResourceCosts.Length = 0;
	Template.TradingPostValue = 0;
	Template.RewardDecks.Length = 0;
	Template.bInfiniteItem = true;
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
}

static function PatchSteadyHands()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Condition_UnitValue			ValueCondition;
	
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SteadyHands');

	ValueCondition = new class'X2Condition_UnitValue';
	ValueCondition.AddCheckValue('MovesThisTurn', 0, eCheck_Exact);

	X2Effect_PersistentStatChange(X2Effect_Persistent(Template.AbilityShooterEffects[0]).ApplyOnTick[0]).TargetConditions.AddItem(ValueCondition);
	`LOG("PatchSteadyHands" @ X2Effect_PersistentStatChange(X2Effect_Persistent(Template.AbilityShooterEffects[0]).ApplyOnTick[0]).TargetConditions.Length,, 'RPG');
}

static function PatchMedicalProtocol()
{
	local X2AbilityTemplateManager				TemplateManager;
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPointsExtended	ActionPointCost;
	local int									Index;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	ActionPointCost = new class'X2AbilityCost_ActionPointsExtended';
	ActionPointCost.iNumPoints = 1;	
	ActionPointCost.FreeCostAbilities.AddItem('EmergencyProtocol');

	Template = TemplateManager.FindAbilityTemplate('GremlinHeal');
	for (Index = 0; Index < Template.AbilityCosts.Length; Index++)
	{
		if (X2AbilityCost_ActionPoints(Template.AbilityCosts[Index]) != none)
		{
			Template.AbilityCosts[Index] = ActionPointCost;
		}
	}

	Template = TemplateManager.FindAbilityTemplate('GremlinStabilize');
	for (Index = 0; Index < Template.AbilityCosts.Length; Index++)
	{
		if (X2AbilityCost_ActionPoints(Template.AbilityCosts[Index]) != none)
		{
			Template.AbilityCosts[Index] = ActionPointCost;
		}
	}
}

static function PatchClaymoreCharges()
{
	local X2AbilityTemplateManager				TemplateManager;
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPointsExtended	ActionPointCost;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('ThrowClaymore');
	Template.AbilityCharges.AddBonusCharge('Overkill', 1);

	Template = TemplateManager.FindAbilityTemplate('HomingMine');
	Template.AbilityCharges.AddBonusCharge('Overkill', 1);
}



static function PatchHolotargeting()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Effect_TargetDefinition		Effect;
	local XMBCondition_SourceAbilities	RequiredAbilitiesCondition;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	RequiredAbilitiesCondition = new class'XMBCondition_SourceAbilities';
	RequiredAbilitiesCondition.AddRequireAbility('PermanentTracking', 'AA_AbilityRequired');

	Effect = new class'X2Effect_TargetDefinition';
	Effect.BuildPersistentEffect(1, true, false, false);
	//Effect.TargetConditions.AddItem(class'X2Ability'.default.LivingHostileUnitDisallowMindControlProperty);
	Effect.TargetConditions.AddItem(RequiredAbilitiesCondition);

	Template = TemplateManager.FindAbilityTemplate('Holotarget');
	Template.AddTargetEffect(Effect);

	Template = TemplateManager.FindAbilityTemplate('Rapidtargeting');
	Template.AddTargetEffect(Effect);

	Template = TemplateManager.FindAbilityTemplate('Multitargeting');
	Template.AddTargetEffect(Effect);
	Template.AddMultiTargetEffect(Effect);
	
	Template = TemplateManager.FindAbilityTemplate('BattleScanner');
	Template.AddMultiTargetEffect(Effect);
}

static function PatchSwordSlice()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SwordSlice');
	Template.AdditionalAbilities.AddItem('BlueMoveSlash');
	Template.bUniqueSource = true;
}

static function PatchBladestormAttack()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('BladestormAttack');
	X2AbilityToHitCalc_StandardMelee(Template.AbilityToHitCalc).bReactionFire = false;

	Template = TemplateManager.FindAbilityTemplate('RetributionAttack');
	X2AbilityToHitCalc_StandardMelee(Template.AbilityToHitCalc).bReactionFire = false;
}

static function PatchThrowClaymore()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('ThrowClaymore');
	Template.bUniqueSource = true;
}


static function PatchSkirmisherGrapple()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SkirmisherGrapple');
	Template.bUniqueSource = true;
}


static function PatchKillZone()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('KillZone');
	Template.IconImage = "img:///UILibrary_RPG.UIPerk_killzone";
}


static function PatchStandardShot()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('StandardShot');

	GetAbilityCostActionPoints(Template).AllowedTypes.AddItem(class'X2Effect_LightEmUp'.default.LightEmUpActionPoint);
}

static function PatchRemoteStart()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('RemoteStart');
	GetAbilityCostActionPoints(Template).DoNotConsumeAllSoldierAbilities.AddItem('AsymmetricWarfare');
}

static function PatchSniperStandardFire()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SniperStandardFire');
	GetAbilityCostActionPoints(Template).bAddWeaponTypicalCost = false;
}

static function PatchLongWatch()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('LongWatch');
	GetAbilityCostActionPoints(Template).bAddWeaponTypicalCost = false;
}


static function PatchSuppression()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('Suppression');
	Template.AdditionalAbilities.AddItem('LockdownBonuses');
}

static function PatchSquadSight()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Effect_Squadsight			Squadsight;
	local X2Condition_UnitActionPoints	ActionPointCondition;
	local X2AbilityTrigger_EventListener EventTrigger;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('Squadsight');

	Template.AbilityTriggers.Length = 0;
	Template.AbilityTargetEffects.Length = 0;
	Template.Hostility = eHostility_Neutral;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'PlayerTurnBegun';
	EventTrigger.ListenerData.Filter = eFilter_Player;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);

	ActionPointCondition = new class'X2Condition_UnitActionPoints';
	ActionPointCondition.AddActionPointCheck(0, class'X2CharacterTemplateManager'.default.StandardActionPoint, false, eCheck_GreaterThanOrEqual, 2, 0);

	Squadsight = new class'X2Effect_Squadsight';
	Squadsight.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnBegin);
	Squadsight.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Squadsight.TargetConditions.AddItem(ActionPointCondition);
	Template.AddTargetEffect(Squadsight);

	Template.AdditionalAbilities.AddItem('RemoveSquadSightOnMove');
}

static function bool CanAddItemToInventory(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason)
{
	local X2AbilityTemplateManager	TemplateManager;
	local X2AbilityTemplate			Template;
	local X2WeaponTemplate			WeaponTemplate, LoadoutWeaponTemplate;
	local bool						bEvaluate;
	local UniqueItemCategories		ItemCategories;
	local array<name>				Categories;
	local array<XComGameState_Item> InventoryItems;
	local XComGameState_Item		Item;
	local int						Index, Index2;
	local XGParamTag				LocTag;
	local WeaponProficiency			Proficiency;

	//If (UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
	//{
	WeaponTemplate = X2WeaponTemplate(ItemTemplate);

	InventoryItems = UnitState.GetAllInventoryItems(CheckGameState, true);
	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

	foreach InventoryItems(Item)
	{
		LoadoutWeaponTemplate = X2WeaponTemplate(Item.GetMyTemplate());

		if (LoadoutWeaponTemplate == none || WeaponTemplate == none)
			continue;

		foreach default.LoadoutUniqueItemCategories(ItemCategories)
		{
			Categories = ItemCategories.Categories;
			Index = Categories.Find(LoadoutWeaponTemplate.WeaponCat);
			Index2 = Categories.Find(WeaponTemplate.WeaponCat);
			if (Index != INDEX_NONE && Index2 != INDEX_NONE &&
				LoadoutWeaponTemplate.InventorySlot != WeaponTemplate.InventorySlot)
			{
				bCanAddItem = 0;
				LocTag.StrValue0 = WeaponTemplate.GetLocalizedCategory();
				DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(
					`XEXPAND.ExpandString(
						class'XGLocalizedData_RPG'.default.m_strCategoryRestricted
					)
				);
				bEvaluate = true;
			}
		}
	}
	//}

	if (!bEvaluate)
	{
		foreach default.WeaponProficiencies(Proficiency)
		{
			if (MissesWeaponProficiency(UnitState, WeaponTemplate, Proficiency) && !UnitState.IsResistanceHero())
			{
				TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
				Template = TemplateManager.FindAbilityTemplate(Proficiency.AbilityName);
				bCanAddItem = 0;
				LocTag.StrValue0 = Template.LocFriendlyName;
				DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(
					`XEXPAND.ExpandString(
						class'XGLocalizedData_RPG'.default.m_strAbilityRequired
					)
				);
				bEvaluate = true;
				break;
			}
		}
	}

	if (bEvaluate)
		`LOG(GetFuncName() @ DisabledReason @ bEvaluate,, 'RPG');

	if(CheckGameState == none)
		return !bEvaluate;

	return bEvaluate;
	
}

private static function bool MissesWeaponProficiency(XComGameState_Unit UnitState, X2WeaponTemplate WeaponTemplate, WeaponProficiency Proficiency)
{
	return (WeaponTemplate != none && WeaponTemplate.WeaponCat == Proficiency.UnlocksWeaponCategory && !UnitState.HasSoldierAbility(Proficiency.AbilityName));
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	local X2WeaponTemplate PrimaryWeaponTemplate; //, SecondaryWeaponTemplate;
	local AnimSet AnimSetIter;
	local int i;

	if (!UnitState.IsSoldier() || UnitState.GetSoldierClassTemplateName() == 'Templar')
	{
		return;
	}

	//SecondaryWeaponTemplate = X2WeaponTemplate( UnitState.GetSecondaryWeapon().GetMyTemplate());
	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());

	//`LOG(GetFuncName() @ UnitState.GetFullName() @ SecondaryWeaponTemplate.DataName @ PrimaryWeaponTemplate.DataName @ string(XComWeapon(Pawn.Weapon).ObjectArchetype) @ `XCOMVISUALIZATIONMGR.GetCurrentActionForVisualizer(Pawn),, 'RPG');

	// SecondaryWeaponTemplate.WeaponCat == 'sidearm' &&
	if (InStr(string(XComWeapon(Pawn.Weapon).ObjectArchetype), "WP_TemplarAutoPistol") != INDEX_NONE)
	{
		for (i = 0; i < Pawn.Mesh.AnimSets.Length; i++)
		{
			if (string(Pawn.Mesh.AnimSets[i]) == "AS_TemplarAutoPistol")
			{
				//`LOG(GetFuncName() @ UnitState.GetFullName() @ "Removing" @ Pawn.Mesh.AnimSets[i],, 'RPG');
				Pawn.Mesh.AnimSets.Remove(i, 1);
				break;
			}
		}
		AddAnimSet(Pawn, AnimSet(`CONTENT.RequestGameArchetype("AutoPistol_ANIM.Anims.AS_AutoPistol")));

		Pawn.Mesh.UpdateAnimations();
	}

	if (InStr(string(XComWeapon(Pawn.Weapon).ObjectArchetype), "WP_SkirmisherGauntlet") != INDEX_NONE)
	{
		AddAnimSet(Pawn, AnimSet(`CONTENT.RequestGameArchetype("skirmisher.Anims.AS_Skirmisher")));
	}

	if (PrimaryWeaponTemplate.WeaponCat == 'rifle' || PrimaryWeaponTemplate.WeaponCat == 'bullpup')
	{
		AddAnimSet(Pawn, AnimSet(`CONTENT.RequestGameArchetype("AutoFire_ANIM.Anims.AS_AssaultRifleAutoFire")));
		Pawn.Mesh.UpdateAnimations();
	}

	
	foreach Pawn.Mesh.AnimSets(AnimSetIter)
	{
		//`LOG(GetFuncName() @ UnitState.GetFullName() @ "current animsets: " @ AnimSetIter,, 'RPG');
	}
	//`LOG(GetFuncName() @ UnitState.GetFullName() @ "------------------",, 'RPG');
}

static function AddAnimSet(XComUnitPawn Pawn, AnimSet AnimSetToAdd)
{
	if (Pawn.Mesh.AnimSets.Find(AnimSetToAdd) == INDEX_NONE)
	{
		Pawn.Mesh.AnimSets.AddItem(AnimSetToAdd);
		//`LOG(GetFuncName() @ "adding" @ AnimSetToAdd,, 'RPG');
	}
}

static function EInventorySlot FindInventorySlotForItemCategory(XComGameState_Unit UnitState, name WeaponCategory, out XComGameState_Item FoundItemState, optional XComGameState StartState)
{
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2WeaponTemplate WeaponTemplate;
	local X2PairedWeaponTemplate PairedWeaponTemplate;
	local array<name> PairedTemplates;

	CurrentInventory = UnitState.GetAllInventoryItems(StartState);

	foreach CurrentInventory(InventoryItem)
	{
		PairedWeaponTemplate = X2PairedWeaponTemplate(InventoryItem.GetMyTemplate());
		if (PairedWeaponTemplate != none)
		{
			PairedTemplates.AddItem(PairedWeaponTemplate.PairedTemplateName);
		}
	}

	foreach CurrentInventory(InventoryItem)
	{
		PairedWeaponTemplate = X2PairedWeaponTemplate(InventoryItem.GetMyTemplate());
		// Ignore loot mod created paired templates
		if (PairedWeaponTemplate != none && InStr(string(PairedWeaponTemplate.DataName), "Paired") != INDEX_NONE)
		{
			continue;
		}

		// ignore paired targets like WristBladeLeft_CV
		if (PairedTemplates.Find(InventoryItem.GetMyTemplateName()) != INDEX_NONE)
		{
			continue;
		}

		WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
		if (WeaponTemplate != none && WeaponTemplate.WeaponCat == WeaponCategory)
		{
			`LOG(GetFuncName() @ InventoryItem.GetMyTemplate().DataName @ InventoryItem.GetMyTemplate().Class.Name @ X2WeaponTemplate(InventoryItem.GetMyTemplate()).WeaponCat @ WeaponCategory,, 'RPG');
			FoundItemState = InventoryItem;
			return InventoryItem.InventorySlot;
		}
	}
	return eInvSlot_Unknown;
}

static function bool IsPrimaryMelee(XComGameState_Unit UnitState)
{
	return (X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate()).iRange == 0);
}

static function AddAbilityToWeaponTemplate(out X2WeaponTemplate Template, name Ability, bool bShowInTactical = false)
{
	if (Template.Abilities.Find(Ability) == INDEX_NONE)
	{
		//`LOG(GetFuncName() @ Template.DataName @ Ability,, 'RPG');
		Template.Abilities.AddItem(Ability);
		if (bShowInTactical)
			ShowInTacticalText(Ability);
	}
}

static function AddAbilityToGremlinTemplate(out X2GremlinTemplate Template, name Ability, bool bShowInTactical = false)
{
	if (Template.Abilities.Find(Ability) == INDEX_NONE)
	{
		//`LOG(GetFuncName() @ Template.DataName @ Ability,, 'RPG');
		Template.Abilities.AddItem(Ability);
		if (bShowInTactical)
			ShowInTacticalText(Ability);
	}
}

static function ShowInTacticalText(name Ability)
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				AbilityTemplate;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = TemplateManager.FindAbilityTemplate(Ability);
	AbilityTemplate.bDisplayInUITacticalText = true;
}

