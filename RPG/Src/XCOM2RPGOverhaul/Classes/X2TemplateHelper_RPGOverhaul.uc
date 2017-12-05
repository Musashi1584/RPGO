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
var config array<UniqueItemCategories> LoadoutUniqueItemCategories;
var config array<WeaponProficiency> WeaponProficiencies;
var config array<int> VERY_SHORT_RANGE;

var config int ShotgunAimBonus;
var config int ShotgunCritBonus;
var config int CannonDamageBonus;
var config int AutoPistolDamageBonus;

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
	local X2Condition_WeaponCategory WeaponCondition;
	local int Index, CategoryIndex;
	local name WeaponCategory;
	local EInventorySlot InvSlot;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	if (!UnitState.IsSoldier())
		return;

	CurrentInventory = UnitState.GetAllInventoryItems(StartState);

	for(Index = 0; Index < SetupData.Length; Index++)
	{
		// Deactivate all ranged abilities
		if (class'X2TemplateHelper_RPGOverhaul'.static.IsPrimaryMelee(UnitState) && SetupData[Index].Template.DefaultSourceItemSlot == eInvSlot_PrimaryWeapon)
		{
			WeaponCondition = new class'X2Condition_WeaponCategory';
			WeaponCondition.ExcludeWeaponCategories.AddItem('sword');
			SetupData[Index].Template.AbilityTargetConditions.AddItem(WeaponCondition);
		}

		`LOG(GetFuncName() @ UnitState.GetFullName() @ SetupData[Index].TemplateName @ SetupData[Index].Template.DefaultSourceItemSlot,, 'RPG');

		//if (SetupData[Index].Template.DefaultSourceItemSlot != eInvSlot_Unknown)
		//{
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
		//}

		// Do this here again because the launch grenade ability is now on the grenade lanucher itself and not in earned soldier abilities
		if (SetupData[Index].Template.bUseLaunchedGrenadeEffects)
		{
			//  populate a version of the ability for every grenade in the inventory
			foreach CurrentInventory(InventoryItem)
			{
				if (InventoryItem.bMergedOut) 
					continue;

				if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
				{ 
					SetupData[Index].SourceAmmoRef = InventoryItem.GetReference();
				}
			}
		}
	}
}

static function bool IsPrimaryMelee(XComGameState_Unit UnitState)
{
	// @TODO externalize in config
	return (X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate()).WeaponCat == 'sword');
}

static function EInventorySlot FindInventorySlotForItemCategory(XComGameState_Unit UnitState, name WeaponCategory, out XComGameState_Item FoundItemState, optional XComGameState StartState)
{
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2WeaponTemplate WeaponTemplate;
	local X2PairedWeaponTemplate PairedWeaponTemplate;

	CurrentInventory = UnitState.GetAllInventoryItems(StartState);
	foreach CurrentInventory(InventoryItem)
	{
		`LOG(GetFuncName() @ InventoryItem.GetMyTemplate().DataName @ InventoryItem.GetMyTemplate().Class.Name @ X2WeaponTemplate(InventoryItem.GetMyTemplate()).WeaponCat @ WeaponCategory,, 'RPG');
		PairedWeaponTemplate = X2PairedWeaponTemplate(InventoryItem.GetMyTemplate());
		if (PairedWeaponTemplate != none  && InStr(string(PairedWeaponTemplate.DataName), "Paired") != INDEX_NONE)
		{
			continue;
		}

		WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
		if (WeaponTemplate != none && WeaponTemplate.WeaponCat == WeaponCategory)
		{
			FoundItemState = InventoryItem;
			return InventoryItem.InventorySlot;
		}
	}
	return eInvSlot_Unknown;
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
		if (Template != none)
		{
			WeaponCondition = new class'X2Condition_WeaponCategory';
			WeaponCondition.IncludeWeaponCategories = Restriction.WeaponCategories;
			Template.AbilityTargetConditions.AddItem(WeaponCondition);
		}
	}
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
				if (WeaponTemplate.BaseDamage.Damage > 0
					&& WeaponTemplate.WeaponCat != 'shotgun'
					&& WeaponTemplate.iRange == INDEX_NONE)
				{
					`LOG(GetFuncName() @ "Add DamageModifierCoverType to" @ WeaponTemplate.DataName,, 'RPG');
					AddAbilityToWeaponTemplate(WeaponTemplate, 'DamageModifierCoverType');
				}

				// @TODO Patch enviromental damage
				if (InStr(WeaponTemplate.DataName, "CV") != INDEX_NONE || InStr(WeaponTemplate.DataName, "T1") != INDEX_NONE)
				{
					//WeaponTemplate.BaseDamage
				}

				switch (WeaponTemplate.WeaponCat)
				{
					case 'Gremlin':
						GremlinTemplate = X2GremlinTemplate(WeaponTemplate);
						AddAbilityToGremlinTemplate(GremlinTemplate, 'AidProtocol');
						break;
					case 'rifle':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire');
						if (InStr(string(WeaponTemplate.DataName), "CV") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireConvA');
						if (InStr(string(WeaponTemplate.DataName), "MG") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireMagA');
						if (InStr(string(WeaponTemplate.DataName), "BM") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireBeamA');

						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'bullpup':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire');
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SkirmisherStrike');
						WeaponTemplate.iClipSize += 1;
						if (InStr(string(WeaponTemplate.DataName), "CV") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireConvA');
						if (InStr(string(WeaponTemplate.DataName), "MG") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireMagA');
						if (InStr(string(WeaponTemplate.DataName), "BM") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireBeamA');

						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'sniper_rifle':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'Squadsight');

						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'vektor_rifle':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SilentKillPassive');

						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'shotgun':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierCoverType');
						AddAbilityToWeaponTemplate(WeaponTemplate, 'ShotgunDamageModifierRange');
						
						WeaponTemplate.CritChance += default.ShotgunCritBonus;
						WeaponTemplate.Aim += default.ShotgunAimBonus;
						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'cannon':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'FullAutoFire');
						AddAbilityToWeaponTemplate(WeaponTemplate, 'Suppression');
						AddAbilityToWeaponTemplate(WeaponTemplate, 'HeavyWeaponMobilityPenalty');
						//AddAbilityToWeaponTemplate(WeaponTemplate, 'AutoFireShot');
						//AddAbilityToWeaponTemplate(WeaponTemplate, 'AutoFireOverwatch');
						
						WeaponTemplate.BaseDamage.Damage += default.CannonDamageBonus;
						WeaponTemplate.iClipSize += 2;
						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'pistol':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'PistolStandardShot');
						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'sidearm':
						WeaponTemplate.RangeAccuracy = default.VERY_SHORT_RANGE;
						WeaponTemplate.BaseDamage.Damage += default.AutoPistolDamageBonus;
						break;
					case 'sword':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SwordSlice');
						WeaponTemplate.NumUpgradeSlots = 3;
						break;
					case 'gremlin':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'IntrusionProtocol');
						break;
					case 'grenade_launcher':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'LaunchGrenade');
						break;
					case 'wristblade':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'SkirmisherGrapple');
						break;
					case 'claymore':
						AddAbilityToWeaponTemplate(WeaponTemplate, 'ThrowClaymore');
						break;
					default:
						//`LOG(GetFuncName() @ WeaponTemplate.GetItemFriendlyName() @ WeaponTemplate.DataName @ WeaponTemplate.WeaponCat @ "ignored",, 'RPG');
						break;
				}
			}

			// Patch hero weapons
			if (WeaponTemplate.DataName == 'WristBlade_CV' ||
				WeaponTemplate.DataName == 'ShardGauntlet_CV' ||
				WeaponTemplate.DataName == 'VektorRifle_CV' ||
				WeaponTemplate.DataName == 'Bullpup_CV' ||
				WeaponTemplate.DataName == 'Reaper_Claymore' ||
				WeaponTemplate.DataName == 'Sidearm_CV')
			{
				WeaponTemplate.StartingItem = true;
				`LOG("Unlock" @ WeaponTemplate.DataName,, 'RPG');
			}
		}
	}
}

static function AddAbilityToWeaponTemplate(out X2WeaponTemplate Template, name Ability)
{
	if (Template.Abilities.Find(Ability) == INDEX_NONE)
	{
		//`LOG(GetFuncName() @ Template.DataName @ Ability,, 'RPG');
		Template.Abilities.AddItem(Ability);
	}
}

static function AddAbilityToGremlinTemplate(out X2GremlinTemplate Template, name Ability)
{
	if (Template.Abilities.Find(Ability) == INDEX_NONE)
	{
		//`LOG(GetFuncName() @ Template.DataName @ Ability,, 'RPG');
		Template.Abilities.AddItem(Ability);
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
	local int									Index;
	
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.AbilityPrerequisites(Prerequisite)
	{
		for (Index = 1; Index < Prerequisite.PrerequisiteTree.Length; Index++)
		{
			Template = TemplateManager.FindAbilityTemplate(Prerequisite.PrerequisiteTree[Index]);
			Template.PrerequisiteAbilities.AddItem(Prerequisite.PrerequisiteTree[Index - 1]);
		}
	}
}

static function PatchMedicalProtocol()
{
	local X2AbilityTemplateManager				TemplateManager;
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPointsExtended	ActionPointCost;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	ActionPointCost = new class'X2AbilityCost_ActionPointsExtended';
	ActionPointCost.iNumPoints = 1;	
	ActionPointCost.FreeCostAbilities.AddItem('EmergencyProtocol');

	Template = TemplateManager.FindAbilityTemplate('GremlinHeal');
	Template.AbilityCosts[0] = ActionPointCost;

	Template = TemplateManager.FindAbilityTemplate('GremlinStabilize');
	Template.AbilityCosts[0] = ActionPointCost;
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
	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).DoNotConsumeAllSoldierAbilities.AddItem('LightEmUp');
}

static function PatchRemoteStart()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('RemoteStart');
	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).DoNotConsumeAllSoldierAbilities.AddItem('AsymmetricWarfare');
}

static function PatchSniperStandardFire()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SniperStandardFire');
	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).bAddWeaponTypicalCost = false;
}

static function PatchLongWatch()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('LongWatch');
	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).bAddWeaponTypicalCost = false;
}


static function PatchSuppression()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('Suppression');
	Template.AdditionalAbilities.AddItem('LockdownBonuses');
}

static function PatchCombatProtocol()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('CombatProtocol');
	Template.AdditionalAbilities.AddItem('CombatProtocolHackingBonus');
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

	If (UnitState.GetSoldierClassTemplateName() != 'UniversalSoldier')
	{
		return false;
	}

	
	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
	InventoryItems = UnitState.GetAllInventoryItems(CheckGameState, true);
	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

	foreach InventoryItems(Item)
	{
		LoadoutWeaponTemplate = X2WeaponTemplate(Item.GetMyTemplate());
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

	if (!bEvaluate)
	{
		foreach default.WeaponProficiencies(Proficiency)
		{
			if (MissesWeaponProficiency(UnitState, WeaponTemplate, Proficiency))
			{
				TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
				Template = TemplateManager.FindAbilityTemplate(Proficiency.AbilityName);
				bCanAddItem = 0;
				// @TODO get localization from ability
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
	local X2WeaponTemplate PrimaryWeaponTemplate, SecondaryWeaponTemplate;
	local AnimSet AnimSetIter;
	local int i;

	if (!UnitState.IsSoldier() || UnitState.GetSoldierClassTemplateName() == 'Templar')
	{
		return;
	}

	SecondaryWeaponTemplate = X2WeaponTemplate( UnitState.GetSecondaryWeapon().GetMyTemplate());
	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());

	`LOG(GetFuncName() @ UnitState.GetFullName() @ SecondaryWeaponTemplate.DataName @ PrimaryWeaponTemplate.DataName @ string(XComWeapon(Pawn.Weapon).ObjectArchetype) @ `XCOMVISUALIZATIONMGR.GetCurrentActionForVisualizer(Pawn),, 'RPG');

	if (SecondaryWeaponTemplate.WeaponCat == 'sidearm' &&
		InStr(string(XComWeapon(Pawn.Weapon).ObjectArchetype), "WP_TemplarAutoPistol") != INDEX_NONE)
	{
		for (i = 0; i < Pawn.Mesh.AnimSets.Length; i++)
		{
			if (string(Pawn.Mesh.AnimSets[i]) == "AS_TemplarAutoPistol")
			{
				`LOG(GetFuncName() @ UnitState.GetFullName() @ "Removing" @ Pawn.Mesh.AnimSets[i],, 'RPG');
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
		`LOG(GetFuncName() @ UnitState.GetFullName() @ "current animsets: " @ AnimSetIter,, 'RPG');
	}
	`LOG(GetFuncName() @ UnitState.GetFullName() @ "------------------",, 'RPG');
}

static function AddAnimSet(XComUnitPawn Pawn, AnimSet AnimSetToAdd)
{
	if (Pawn.Mesh.AnimSets.Find(AnimSetToAdd) == INDEX_NONE)
	{
		Pawn.Mesh.AnimSets.AddItem(AnimSetToAdd);
		`LOG(GetFuncName() @ "adding" @ AnimSetToAdd,, 'RPG');
	}
}