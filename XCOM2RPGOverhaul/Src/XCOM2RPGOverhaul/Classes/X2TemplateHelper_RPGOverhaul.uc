class X2TemplateHelper_RPGOverhaul extends Object config (RPG);

var config array<AbilityWeaponCategoryRestriction> AbilityWeaponCategoryRestrictions;
var config array<AbilityPrerequisite> AbilityPrerequisites;
var config array<MutuallyExclusiveAbilityPool> MutuallyExclusiveAbilities;
var config array<UniqueItemCategories> LoadoutUniqueItemCategories;
var config array<WeaponProficiency> WeaponProficiencies;
var config array<int> VERY_SHORT_RANGE;
var config array<SoldierSpecialization> Specializations;
var config array<name> ValidLightEmUpAbilities;
var config array<name> IgnoreWeaponTemplatesForPatch;

var config int ShotgunAimBonus;
var config int ShotgunCritBonus;
var config int CannonDamageBonus;
var config int AutoPistolCritChanceBonus;
var config int DefaultWeaponUpgradeSlots;

static function bool IsPrerequisiteAbility(name AbiliityName)
{
	local AbilityPrerequisite					Prerequisite;
	local int									Index;
	
	foreach default.AbilityPrerequisites(Prerequisite)
	{
		for (Index = 0; Index < Prerequisite.PrerequisiteTree.Length; Index++)
		{
			if (Prerequisite.PrerequisiteTree[Index] == AbiliityName)
			{
				return true;
			}
		}
	}
	return false;
}



static function AddSecondWaveOptions()
{
	
	AddSecondWaveOption(
		'RPGO_SWO_WeaponRestriction',
		class'XGLocalizedData_RPG'.default.strRPGO_SWO_WeaponRestriction_Description,
		class'XGLocalizedData_RPG'.default.strRPGO_SWO_WeaponRestriction_Tooltip
	);

	AddSecondWaveOption(
		'RPGOSpecRoulette',
		class'XGLocalizedData_RPG'.default.strSWO_SpecRoulette_Description,
		class'XGLocalizedData_RPG'.default.strSWO_SpecRoulette_Tooltip
	);

	 AddSecondWaveOption(
	 	'RPGO_SWO_RandomClasses',
	 	class'XGLocalizedData_RPG'.default.strRPGO_SWO_RandomClasses_Description,
	 	class'XGLocalizedData_RPG'.default.strRPGO_SWO_RandomClasses_Tooltip
	 );
	
	AddSecondWaveOption(
		'RPGOCommandersChoice',
		class'XGLocalizedData_RPG'.default.strSWO_CommandersChoice_Description,
		class'XGLocalizedData_RPG'.default.strSWO_CommandersChoice_Tooltip
	);

	AddSecondWaveOption(
		'RPGOTrainingRoulette',
		class'XGLocalizedData_RPG'.default.strSWO_TrainingRoulette_Description,
		class'XGLocalizedData_RPG'.default.strSWO_TrainingRoulette_Tooltip
	);
	
	AddSecondWaveOption(
		'RPGOOrigins',
		class'XGLocalizedData_RPG'.default.strSWO_Origins_Description,
		class'XGLocalizedData_RPG'.default.strSWO_Origins_Tooltip
	);
}

static function AddSecondWaveOption(name ID, string Description, string Tooltip)
{
	local array<Object>			UIShellDifficultyArray;
	local Object				ArrayObject;
	local UIShellDifficulty		UIShellDifficulty;
	local SecondWaveOption		Option;
	
	Option.ID = ID;
	Option.DifficultyValue = 0;

	UIShellDifficultyArray = class'XComEngine'.static.GetClassDefaultObjects(class'UIShellDifficulty');
	foreach UIShellDifficultyArray(ArrayObject)
	{
		UIShellDifficulty = UIShellDifficulty(ArrayObject);
		UIShellDifficulty.SecondWaveOptions.AddItem(Option);
		UIShellDifficulty.SecondWaveDescriptions.AddItem(Description);
		UIShellDifficulty.SecondWaveToolTips.AddItem(Tooltip);
	}
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
	local int Index, ConfigIndex;
	local name WeaponCategory;
	local array<XComGameState_Item> CurrentInventory, FoundItems;
	local XComGameState_Item InventoryItem;
	local AbilitySetupData Data, EmptyData;
	local array<AbilitySetupData> DataToAdd;
	local StateObjectReference ItemRef;
	local array<StateObjectReference> ItemRefs;

	if (!UnitState.IsSoldier())
		return;

	CurrentInventory = UnitState.GetAllInventoryItems(StartState);

	for(Index = SetupData.Length; Index >= 0; Index--)
	{
		ConfigIndex = default.AbilityWeaponCategoryRestrictions.Find('AbilityName', SetupData[Index].TemplateName);
		
		if (ConfigIndex != INDEX_NONE)
		{
			// Reset ref
			SetupData[Index].SourceWeaponRef.ObjectID = 0;

			foreach default.AbilityWeaponCategoryRestrictions[ConfigIndex].WeaponCategories(WeaponCategory)
			{
				FoundItems = GetInventoryItemsForCategory(UnitState, WeaponCategory, StartState);

				//`LOG(GetFuncName() @ UnitState.SummaryString() @ SetupData[Index].TemplateName @ WeaponCategory @ `ShowVar(FoundItems.Length),, 'RPG');

				if (FoundItems.Length > 0)
				{
					ItemRefs.Length = 0;
					// Checking slots in descending priority
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_PrimaryWeapon));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_SecondaryWeapon));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Armor));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Pistol));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_PsiAmp));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_HeavyWeapon));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_ExtraSecondary));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_GrenadePocket));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_AmmoPocket));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Utility));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_CombatDrugs));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_CombatSim));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Plating));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Vest));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_SparkLauncher));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_SecondaryPayload));
					
					foreach ItemRefs(ItemRef)
					{
						If (ItemRef.ObjectID != 0)
						{
							//InventoryItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ItemRef.ObjectID));
							//`LOG(GetFuncName() @ UnitState.SummaryString() @ `ShowVar(ItemRef.ObjectID) @ InventoryItem.SummaryString() @ InventoryItem.InventorySlot,, 'RPG');
							SetupData[Index].SourceWeaponRef = ItemRef;
							break;
						}
					}

					// We havent found anything above, take the first found item
					if (SetupData[Index].SourceWeaponRef.ObjectID == 0)
					{
						SetupData[Index].SourceWeaponRef = FoundItems[0].GetReference();
						break;
					}
					else
					{
						break;
					}
				}
			}

			// havent found any items for ability, lets remove it
			if (SetupData[Index].SourceWeaponRef.ObjectID == 0)
			{
				//SetupData[Index].Template.AbilityTargetConditions.AddItem(new class'X2ConditionDisabled');
				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"Removing" @ SetupData[Index].TemplateName @
					"cause no matching items found"
				,, 'RPG');

				SetupData.Remove(Index, 1);
			}
			else
			{
				InventoryItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID));

				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"Patching" @ SetupData[Index].TemplateName @
					"to" @ InventoryItem.InventorySlot
					@ InventoryItem.SummaryString()
				,, 'RPG');
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

static function StateObjectReference GetItemReferenceForInventorySlot(array<XComGameState_Item> Items, EInventorySlot InventorySlot)
{
	local XComGameState_Item Item;
	local StateObjectReference EmptyRef;

	foreach Items(Item)
	{
		if (Item.InventorySlot == InventorySlot)
		{
			return Item.GetReference();
		}
	}

	return EmptyRef;
}

static function PatchWeapons()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<name> TemplateNames;
	local array<X2DataTemplate> DifficultyVariants;
	local name TemplateName;
	local X2DataTemplate ItemTemplate;
	local X2WeaponTemplate WeaponTemplate;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ItemTemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficultyVariants);
		// Iterate over all variants
		foreach DifficultyVariants(ItemTemplate)
		{
			WeaponTemplate = X2WeaponTemplate(ItemTemplate);
			PatchWeaponTemplate(WeaponTemplate);
		}

		// Also patch base template
		WeaponTemplate = X2WeaponTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));
		PatchWeaponTemplate(WeaponTemplate);
	}
}

static function PatchWeaponTemplate(X2WeaponTemplate WeaponTemplate)
{
	local X2WeaponTemplate UnpatchedTemplate;
	local X2GremlinTemplate GremlinTemplate;
	local array<string> AutofireWeaponCategories, PatchUpgradeSlotWeaponCategories;

	if (WeaponTemplate != none)
	{
		AutofireWeaponCategories = class'RPGOAbilityConfigManager'.static.GetConfigStringArray("AUTOFIRE_WEAPON_CATEGORIES");
		PatchUpgradeSlotWeaponCategories = class'RPGODefaultSettingsConfigManager'.static.GetConfigStringArray("PATCH_UPGRADESLOT_WEAPON_CATEGORIES");

		class'RPGOTemplateCache'.static.AddWeaponTemplate(WeaponTemplate);
		UnpatchedTemplate = class'RPGOTemplateCache'.static.GetWeaponTemplate(WeaponTemplate.DataName);

		// @TODO Patch enviromental damage
		if (InStr(WeaponTemplate.DataName, "CV") != INDEX_NONE || InStr(WeaponTemplate.DataName, "T1") != INDEX_NONE)
		{
			//WeaponTemplate.BaseDamage
		}

		if (default.IgnoreWeaponTemplatesForPatch.Find(WeaponTemplate.DataName) != INDEX_NONE)
		{
			return;
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
				break;
			case 'bullpup':
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_BULLPUPS"))
				{
					WeaponTemplate.iClipSize = UnpatchedTemplate.iClipSize + 1;
					AddAbilityToWeaponTemplate(WeaponTemplate, 'BullpupDesign', true);
				}
				else
				{
					WeaponTemplate.iClipSize = UnpatchedTemplate.iClipSize;
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'BullpupDesign');
				}

				// Fix for bullpup & pistol combo always trigger bullpup overwatch shots
				RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'PistolReturnFire');
				AddAbilityToWeaponTemplate(WeaponTemplate, 'BullpupReturnFire', false);

				break;
			case 'sniper_rifle':
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SNIPER_RIFLES"))
				{
					AddAbilityToWeaponTemplate(WeaponTemplate, 'Squadsight', true);
				}
				else
				{
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'Squadsight');
				}
				break;
			case 'vektor_rifle':
				
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_VECTOR_RIFLES"))
				{
					AddAbilityToWeaponTemplate(WeaponTemplate, 'SilentKillPassive');
				}
				else
				{
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'SilentKillPassive');
				}
				break;
			case 'shotgun':
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SHOTGUNS"))
				{					
					AddAbilityToWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierCoverType', false);
					AddAbilityToWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierRange', false);
							
					WeaponTemplate.CritChance = UnpatchedTemplate.CritChance + default.ShotgunCritBonus;
					WeaponTemplate.Aim = UnpatchedTemplate.Aim + default.ShotgunAimBonus;
				}
				else
				{
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierCoverType');
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierRange');

					WeaponTemplate.CritChance = UnpatchedTemplate.CritChance;
					WeaponTemplate.Aim = UnpatchedTemplate.Aim;
				}
				break;
			case 'cannon':
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_CANNONS"))
				{
					AddAbilityToWeaponTemplate(WeaponTemplate, 'Suppression', true);
					AddAbilityToWeaponTemplate(WeaponTemplate, 'HeavyWeaponMobilityPenalty', true);
					WeaponTemplate.BaseDamage.Damage = UnpatchedTemplate.BaseDamage.Damage + default.CannonDamageBonus;
					WeaponTemplate.iClipSize = UnpatchedTemplate.iClipSize + 2;
				}
				else
				{
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'Suppression');
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'HeavyWeaponMobilityPenalty');
					WeaponTemplate.BaseDamage.Damage = UnpatchedTemplate.BaseDamage.Damage;
					WeaponTemplate.iClipSize = UnpatchedTemplate.iClipSize;
				}
				break;
			case 'pistol':
				AddAbilityToWeaponTemplate(WeaponTemplate, 'PistolStandardShot', true);
						
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_PISTOLS"))
				{
					AddAbilityToWeaponTemplate(WeaponTemplate, 'ReturnFire', true);
					AddAbilityToWeaponTemplate(WeaponTemplate, 'PistolDamageModifierRange', false);
				}
				else
				{
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'ReturnFire');
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'PistolDamageModifierRange');
				}
				break;
			case 'sidearm':
				if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_AUTO_PISTOLS"))
				{
					WeaponTemplate.RangeAccuracy = default.VERY_SHORT_RANGE;
					WeaponTemplate.CritChance = UnpatchedTemplate.CritChance + default.AutoPistolCritChanceBonus;
					AddAbilityToWeaponTemplate(WeaponTemplate, 'Spray', true);
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'PistolReturnFire');

					if (InStr(string(WeaponTemplate.DataName), "CV",, true) != INDEX_NONE)
						WeaponTemplate.SetAnimationNameForAbility('Spray', 'FF_FireMultiShotConvA');
					if (InStr(string(WeaponTemplate.DataName), "MG",, true) != INDEX_NONE)
						WeaponTemplate.SetAnimationNameForAbility('Spray', 'FF_FireMultiShotMagA');
					if (InStr(string(WeaponTemplate.DataName), "BM",, true) != INDEX_NONE)
						WeaponTemplate.SetAnimationNameForAbility('Spray', 'FF_FireMultiShotBeamA');
				}
				else
				{
					WeaponTemplate.RangeAccuracy = UnpatchedTemplate.RangeAccuracy;
					WeaponTemplate.CritChance = UnpatchedTemplate.CritChance;
					RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'Spray');
					WeaponTemplate.AbilitySpecificAnimations.Remove(
						WeaponTemplate.AbilitySpecificAnimations.Find('AbilityName', 'Spray'),
						1
					);
				}
				break;
			case 'sword':
				AddAbilityToWeaponTemplate(WeaponTemplate, 'SwordSlice', true);
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

		if (InStr(WeaponTemplate.DataName, "SMG", false, true) == INDEX_NONE &&
			class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_FULLAUTOFIRE") &&
			AutofireWeaponCategories.Find(string(WeaponTemplate.WeaponCat)) != INDEX_NONE)
		{
			AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire', true);
			if (InStr(string(WeaponTemplate.DataName), "CV", false, true) != INDEX_NONE)
			{
				WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_BulletShredConvA');
			}
			else if (InStr(string(WeaponTemplate.DataName), "MG", false, true) != INDEX_NONE)
			{
				WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_BulletShredMagA');
			}
			else if (InStr(string(WeaponTemplate.DataName), "BM", false, true) != INDEX_NONE)
			{
				WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_BulletShredBeamA');
			}
			else
			{
				WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_BulletShredConvA');
			}
		}
		else if (WeaponTemplate.Abilities.Find('FullAutoFire') != INDEX_NONE)
		{
			RemoveAbilityFromWeaponTemplate(WeaponTemplate, 'FullAutoFire');
			WeaponTemplate.AbilitySpecificAnimations.Remove(
				WeaponTemplate.AbilitySpecificAnimations.Find('AbilityName', 'FullAutoFire'),
				1
			);
		}

		if (PatchUpgradeSlotWeaponCategories.Find(string(WeaponTemplate.WeaponCat)) != INDEX_NONE)
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_DEFAULTWEAPON_UPGRADESLOTS"))
			{
				WeaponTemplate.NumUpgradeSlots = default.DefaultWeaponUpgradeSlots;
			}
			else
			{
				WeaponTemplate.NumUpgradeSlots = UnpatchedTemplate.NumUpgradeSlots;
			}
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

static function PatchAbilitiesWeaponCondition()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Condition_WeaponCategory	WeaponCondition;
	local AbilityWeaponCategoryRestriction Restriction;
	local bool							bMeleeReaction;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.AbilityWeaponCategoryRestrictions(Restriction)
	{
		Template = TemplateManager.FindAbilityTemplate(Restriction.AbilityName);
		
		if (Template != none)
		{
			bMeleeReaction = X2AbilityToHitCalc_StandardMelee(Template.AbilityToHitCalc) != none && X2AbilityToHitCalc_StandardMelee(Template.AbilityToHitCalc).bReactionFire;
			if (!bMeleeReaction)
			{
				WeaponCondition = new class'X2Condition_WeaponCategory';
				WeaponCondition.IncludeWeaponCategories = Restriction.WeaponCategories;
				Template.AbilityTargetConditions.AddItem(WeaponCondition);

				// Hide active abilities if no weapon matches
				if (
					(Template.eAbilityIconBehaviorHUD == eAbilityIconBehavior_AlwaysShow ||
					 Template.eAbilityIconBehaviorHUD == eAbilityIconBehavior_HideSpecificErrors) &&
					!Template.bIsPassive &&
					Template.HasTrigger('X2AbilityTrigger_PlayerInput')
				)
				{
					Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
					Template.HideErrors.AddItem('AA_WeaponIncompatible');
				}
			}
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
	local array<X2DataTemplate> DataTemplates, DifficultyTemplates;
	local X2DataTemplate DataTemplate, DifficultyTemplate;
	local int Difficulty;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Templates = TemplateManager.GetAllTemplatesOfClass(class'X2SoldierAbilityUnlockTemplate');

	HeroClasses.AddItem('Templar');
	HeroClasses.AddItem('Skirmisher');
	HeroClasses.AddItem('Reaper');

	foreach Templates(Template)
	{
		TemplateManager.FindDataTemplateAllDifficulties(Template.DataName, DifficultyTemplates);

		foreach DifficultyTemplates(DifficultyTemplate)
		{

			SoldierUnlockTemplate = X2SoldierAbilityUnlockTemplate(DifficultyTemplate);

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
			} else {
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " found, skipping inventory add",, 'RPG');
			}
		}
	}

	History.AddGameStateToHistory(NewGameState);
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
			if (Template != none)
			{
				Template.PrerequisiteAbilities.AddItem(Prerequisite.PrerequisiteTree[Index - 1]);
				`LOG(GetFuncName() @ Template.DataName @ "adding" @ Prerequisite.PrerequisiteTree[Index - 1] @ "to PrerequisiteAbilities",, 'RPG');
			}
		}
	}

	foreach default.MutuallyExclusiveAbilities(Exclusive)
	{
		for (Index = 0; Index < Exclusive.Abilities.Length; Index++)
		{
			Template = TemplateManager.FindAbilityTemplate(Exclusive.Abilities[Index]);
			if (Template != none)
			{
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


// Mr. Nice: Only really safe if you *know* there is never more than one of that cost type
// For example, RapidFire/ChainShot have two ammo costs, a free cost for 2 ammo, and the actual cose for 1 ammo.
static function X2AbilityCost GetAbilityCostByClassName(X2AbilityTemplate Template, name CostClassName)
{
	local X2AbilityCost Cost;

	foreach Template.AbilityCosts(Cost)
	{
		if (Cost.IsA(CostClassName))
		{
			return Cost;
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

	//Template.Cost.ResourceCosts.Length = 0;
	//Template.TradingPostValue = 0;
	//Template.RewardDecks.Length = 0;
	//Template.bInfiniteItem = true;
	//Template.StartingItem = true;
	//Template.CanBeBuilt = false;
}

static function PatchSkirmisherReturnFire()
{
	local X2AbilityTemplateManager				TemplateManager;
	local X2AbilityTemplate						Template;
	local X2Effect								Effect;
	local X2Effect_ReturnFire					ReturnFireEffect;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SkirmisherReturnFire');

	foreach Template.AbilityTargetEffects(Effect)
	{
		ReturnFireEffect = X2Effect_ReturnFire(Effect);
		if (ReturnFireEffect != none)
		{
			ReturnFireEffect.AbilityToActivate = 'BullpupReturnFire';
			ReturnFireEffect.GrantActionPoint = 'SkirmisherReturnFireActionPoint';
			break;
		}
	}
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
	
	if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SNIPER_RIFLES"))
	{
		GetAbilityCostActionPoints(Template).bAddWeaponTypicalCost = false;
	}
	else
	{
		GetAbilityCostActionPoints(Template).bAddWeaponTypicalCost = true;
	}
}

static function PatchLongWatch()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Effect_Squadsight			Squadsight;
	local int							Index;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = TemplateManager.FindAbilityTemplate('LongWatch');

	if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SNIPER_RIFLES"))
	{
		// Readd squad sight in case it was removed on movement on playerturn
		Squadsight = new class'X2Effect_Squadsight';
		Squadsight.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
		Squadsight.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
		Template.AddTargetEffect(Squadsight);
	}
	else
	{
		for(Index = Template.AbilityTargetEffects.Length; Index >= 0; Index--)
		{
			Squadsight = X2Effect_Squadsight(Template.AbilityTargetEffects[Index]);
			if (Squadsight != none)
			{
				Template.AbilityTargetEffects.Remove(Index, 1);
			}
		}
	}
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
	local X2AbilityTemplate				Template, UnpatchedTemplate;
	local X2Effect_Squadsight			Squadsight;
	local X2AbilityTrigger_EventListener EventTrigger;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = TemplateManager.FindAbilityTemplate('Squadsight');

	class'RPGOTemplateCache'.static.AddAbilityTemplate(Template);
	UnpatchedTemplate = class'RPGOTemplateCache'.static.GetAbilityTemplate(Template.DataName);

	if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SNIPER_RIFLES"))
	{
		Template.AbilityTriggers.Length = 0;
		Template.AbilityTargetEffects.Length = 0;
		Template.Hostility = eHostility_Neutral;

		EventTrigger = new class'X2AbilityTrigger_EventListener';
		EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
		EventTrigger.ListenerData.EventID = 'PlayerTurnBegun';
		EventTrigger.ListenerData.Filter = eFilter_Player;
		EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
		Template.AbilityTriggers.AddItem(EventTrigger);

		Squadsight = new class'X2Effect_Squadsight';
		Squadsight.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnBegin);
		Squadsight.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
		Template.AddTargetEffect(Squadsight);

		Template.AdditionalAbilities.AddItem('RemoveSquadSightOnMove');
	}
	else
	{
		Template.AbilityTriggers = UnpatchedTemplate.AbilityTriggers;
		Template.AbilityTargetEffects = UnpatchedTemplate.AbilityTargetEffects;
		Template.AdditionalAbilities = UnpatchedTemplate.AdditionalAbilities;
	}
}

static function bool CanAddItemToInventory_WeaponRestrictions(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason)
{
    local X2WeaponTemplate				WeaponTemplate;
    local XGParamTag					LocTag;
	local array<SoldierSpecialization>	PrimarySpecs;
	local SoldierSpecialization			PrimarySpec;
	local X2UniversalSoldierClassInfo	PrimarySpecTemplate;
	local array<SoldierSpecialization>	SecondarySpecs;
	local SoldierSpecialization			SecondarySpec;
	local X2UniversalSoldierClassInfo	SecondarySpecTemplate;
	local bool							bAllowed;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);

	//	Perform the check ONLY if the item has not been forbidden by another mod already, if the soldier is an RPGO soldier, and only if we're looking at a weapon
	if (DisabledReason == "" && UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' && WeaponTemplate != none && (Slot == eInvSlot_PrimaryWeapon || Slot == eInvSlot_SecondaryWeapon))
	{
		PrimarySpecs = class'X2SoldierClassTemplatePlugin'.static.GetTrainedPrimaryWeaponSpecializations(UnitState);
		foreach PrimarySpecs(PrimarySpec)
		{
			PrimarySpecTemplate = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplate(PrimarySpec);
			//	If soldier's primary specialization is a Dual Wield one, then look only at primary specialization for both Primary and Secondary weapons.
			if (PrimarySpecTemplate.SpecializationMetaInfo.bDualWield || Slot == eInvSlot_PrimaryWeapon)
			{
				bAllowed = PrimarySpecTemplate != none && PrimarySpecTemplate.IsWeaponAllowed(WeaponTemplate.InventorySlot, WeaponTemplate.WeaponCat);
				if (bAllowed)
				{
					break;
				}
			}
		}

		if (!bAllowed)
		{
			SecondarySpecs = class'X2SoldierClassTemplatePlugin'.static.GetTrainedSecondaryWeaponSpecializations(UnitState);
			foreach SecondarySpecs(SecondarySpec)
			{
				SecondarySpecTemplate = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplate(SecondarySpec);
				bAllowed = SecondarySpecTemplate != none && SecondarySpecTemplate.IsWeaponAllowed(WeaponTemplate.InventorySlot, WeaponTemplate.WeaponCat);
				if (bAllowed)
				{
					break;
				}
			}
		}
		
		if (bAllowed)
		{
			//	Weapon allowed
			DisabledReason = "";
			bCanAddItem = 1;

			// Exit function, overriding normal behavior
			return CheckGameState != none;
		}
		else
		{
			//	Weapon NOT Allowed
			LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
			LocTag.StrValue0 = UnitState.GetSoldierClassTemplate().DisplayName;
			DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(`XEXPAND.ExpandString(class'UIArmory_Loadout'.default.m_strUnavailableToClass));

			bCanAddItem = 0;

			// Exit function, overriding normal behavior
			return CheckGameState != none;
		}
	}	
	//	Otherwise pass the torch to the original RPGO function.
	return CanAddItemToInventory(bCanAddItem, Slot, ItemTemplate, Quantity, UnitState, CheckGameState, DisabledReason);
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

		//`LOG(GetFuncName() @ "Testing" @ LoadoutWeaponTemplate.WeaponCat @ LoadoutWeaponTemplate.InventorySlot @ Slot,, 'RPG');

		foreach default.LoadoutUniqueItemCategories(ItemCategories)
		{
			Categories = ItemCategories.Categories;
			Index = Categories.Find(LoadoutWeaponTemplate.WeaponCat);
			Index2 = Categories.Find(WeaponTemplate.WeaponCat);
			if (Index != INDEX_NONE && Index2 != INDEX_NONE &&
				LoadoutWeaponTemplate.InventorySlot != WeaponTemplate.InventorySlot &&
				(LoadoutWeaponTemplate.InventorySlot == eInvSlot_PrimaryWeapon ||
				 LoadoutWeaponTemplate.InventorySlot == eInvSlot_SecondaryWeapon ||
				 LoadoutWeaponTemplate.InventorySlot == eInvSlot_Utility
				))
			{
				`LOG(GetFuncName() @ LoadoutWeaponTemplate.InventorySlot @ WeaponTemplate.InventorySlot,, 'RPG');
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

	if (!bEvaluate && !`SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
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

	//if (bEvaluate)
		//`LOG(GetFuncName() @ DisabledReason @ bEvaluate,, 'RPG');

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

	if (!UnitState.IsSoldier() || UnitState.GetSoldierClassTemplateName() == 'Templar')
	{
		return;
	}

	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());

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

static function array<XComGameState_Item> GetInventoryItemsForCategory(
	XComGameState_Unit UnitState,
	name WeaponCategory,
	optional XComGameState StartState
	)
{
	local array<XComGameState_Item> CurrentInventory, FoundItems;
	local X2WeaponTemplate WeaponTemplate;
	local X2PairedWeaponTemplate PairedWeaponTemplate;
	local array<name> PairedTemplates;
	local XComGameState_Item InventoryItem;

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
			FoundItems.AddItem(InventoryItem);
		}
	}
	return FoundItems;
}

static function bool IsPrimaryMelee(XComGameState_Unit UnitState)
{
	return (X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate()).iRange == 0);
}

static function RemoveAbilityFromWeaponTemplate(out X2WeaponTemplate Template, name Ability)
{
	if (Template.Abilities.Find(Ability) != INDEX_NONE)
	{
		Template.Abilities.RemoveItem(Ability);
	}
}

static function AddAbilityToWeaponTemplate(out X2WeaponTemplate Template, name Ability, bool bShowInTactical = false)
{
	if (class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(Ability) != none)
	{
		if (Template.Abilities.Find(Ability) == INDEX_NONE)
		{
			//`LOG(GetFuncName() @ Template.DataName @ Ability,, 'RPG');
			Template.Abilities.AddItem(Ability);
			if (bShowInTactical)
				ShowInTacticalText(Ability);
		}
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


static function string GetAbilityMetaInfo(X2AbilityTemplate AbilityTemplate)
{
	local int Index;
	local AbilityWeaponCategoryRestriction Restriction;
	local array<string> LocalizedCategories;
	local string Info;

	Index = class'X2TemplateHelper_RPGOverhaul'.default.AbilityWeaponCategoryRestrictions.Find('AbilityName', AbilityTemplate.DataName);
	if (Index != INDEX_NONE)
	{
		Restriction = default.AbilityWeaponCategoryRestrictions[Index];
		LocalizedCategories = GetLocalizedCategories(Restriction.WeaponCategories);
		if (LocalizedCategories.Length > 0)
		{
			Info = class'UIUtilities_Text'.static.GetColoredText(class'XGLocalizedData_RPG'.default.AbilityWeaponRestrictions, eUIState_Header);
			Info @= class'RPGO_UI_Helper'.static.Join(LocalizedCategories, ", ") $ " ";
			return Info;
		}
	}

	return "";
}

static function array<String> GetLocalizedCategories(array<name> WeaponCategories)
{
	local name WeaponCat;
	local array<string> LocalizedCategories;

	foreach WeaponCategories(WeaponCat)
	{
		if (LocalizedCategories.Find(LocalizeCategory(WeaponCat)) == INDEX_NONE)
		{
			LocalizedCategories.AddItem(LocalizeCategory(WeaponCat));
		}
	}

	return LocalizedCategories;
}


static public function string LocalizeCategory(name Key)
{
	switch (Key)
	{
		case 'rifle':
			return class'XGLocalizedData_RPG'.default.ItemCategoryRifle;
			break;
		case 'sniper_rifle':
			return class'XGLocalizedData_RPG'.default.ItemCategorySniperRifle;
			break;
		case 'shotgun':
			return class'XGLocalizedData_RPG'.default.ItemCategoryShotgun;
			break;
		case 'cannon':
			return class'XGLocalizedData_RPG'.default.ItemCategoryCannon;
			break;
		case 'vektor_rifle':
			return class'XGLocalizedData_RPG'.default.ItemCategoryVektorRifle;
			break;
		case 'bullpup':
			return class'XGLocalizedData_RPG'.default.ItemCategoryBullpup;
			break;
		case 'pistol':
			return class'XGLocalizedData_RPG'.default.ItemCategoryPistol;
			break;
		case 'sidearm':
			return class'XGLocalizedData_RPG'.default.ItemCategorySidearm;
			break;
		case 'sword':
			return class'XGLocalizedData_RPG'.default.ItemCategorySword;
			break;
		case 'gremlin':
			return class'XGLocalizedData_RPG'.default.ItemCategoryGremlin;
			break;
		case 'psiamp':
			return class'XGLocalizedData_RPG'.default.ItemCategoryPsiamp;
			break;
		case 'grenade_launcher':
			return class'XGLocalizedData_RPG'.default.ItemCategoryGrenadeLauncher;
			break;
		case 'claymore':
			return class'XGLocalizedData_RPG'.default.ItemCategoryClaymore;
			break;
		case 'wristblade':
			return class'XGLocalizedData_RPG'.default.ItemCategoryWristblade;
			break;
		case 'arcthrower':
			return class'XGLocalizedData_RPG'.default.ItemCategoryArcthrower;
			break;
		case 'combatknife':
			return class'XGLocalizedData_RPG'.default.ItemCategoryCombatknife;
			break;
		case 'holotargeter':
			return class'XGLocalizedData_RPG'.default.ItemCategoryHolotargeter;
			break;
		case 'sawedoffshotgun':
			return class'XGLocalizedData_RPG'.default.ItemCategorySawedoffshotgun;
			break;
		case 'lw_gauntlet':
			return class'XGLocalizedData_RPG'.default.ItemCategoryLWGauntlet;
			break;
		case 'empty':
			return class'XGLocalizedData_RPG'.default.ItemCategoryEmpty;
			break;
		case 'Utility':
			return class'XGLocalizedData_RPG'.default.ItemCategoryUtility;
			break;
		case 'Tech':
			return class'XGLocalizedData_RPG'.default.ItemCategoryTech;
			break;
		case 'conventional':
			return class'XGLocalizedData_RPG'.default.ItemCategoryConventional;
			break;
		case 'plated':
			return class'XGLocalizedData_RPG'.default.ItemCategoryPlated;
			break;
		case 'powered':
			return class'XGLocalizedData_RPG'.default.ItemCategoryPowered;
			break;
		case 'sparkrifle':
			return class'XGLocalizedData_RPG'.default.ItemCategorySparkrifle;
			break;
		case 'gauntlet':
			return class'XGLocalizedData_RPG'.default.ItemCategoryGauntlet;
			break;
		case 'Basic':
			return class'XGLocalizedData_RPG'.default.ItemCategoryBasic;
			break;
		case 'Unknown':
			return class'XGLocalizedData_RPG'.default.ItemCategoryUnknown;
			break;
		case 'Medium':
			return class'XGLocalizedData_RPG'.default.ItemCategoryMedium;
			break;
		case 'Light':
			return class'XGLocalizedData_RPG'.default.ItemCategoryLight;
			break;
		case 'Heavy':
			return class'XGLocalizedData_RPG'.default.ItemCategoryHeavy;
			break;
		case 'iri_rocket_launcher':
		case 'iri_disposable_launcher':
			return class'XGLocalizedData_RPG'.default.ItemCategoryRocketLauncher;
			break;
	}

	return string(Key);
}
