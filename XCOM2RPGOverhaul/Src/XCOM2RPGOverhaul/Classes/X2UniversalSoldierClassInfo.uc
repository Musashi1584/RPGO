class X2UniversalSoldierClassInfo extends Object dependson(RPGO_Structs) PerObjectConfig PerObjectLocalized config (RPG);

var config string ClassSpecializationIcon;
var config array<name> ForceComplementarySpecializations;
var config array<SoldierClassAbilitySlot> AbilitySlots;
var config array<SoldierClassAbilityType> AdditionalRandomTraits;
var config array<SoldierClassAbilityType> AdditionalRandomAptitudes;

// soldier needs on of these abilities to unlock the specialization
// currently this works only for the commanders choice and spec roulette swo
// in default rpgo mode you still have all enabled specs available
var config array<name> RequiredAbilities;

var localized string ClassSpecializationSummary;
var localized string ClassSpecializationTitle;

var config SpecializationMetaInfoStruct SpecializationMetaInfo;

function bool IsWeaponAllowed(EInventorySlot Slot, name WeaponCat)
{
	if (SpecializationMetaInfo.bDualWield)
	{
		return SpecializationMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE;
	}
	else return SpecializationMetaInfo.InventorySlots.Find(Slot) != INDEX_NONE && SpecializationMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE;
}

function string GetClassSpecializationTitleWithMetaData()
{
	local string Title;

	Title = ClassSpecializationTitle;
	Title @= GetSpecializationWeaponSlotInfo();
	Title @= GetSpecializationAllowedWeaponCategoriesInfo();

	return Title;
}

function string GetSpecializationWeaponSlotInfo()
{
	local string Info;

	if (`SecondWaveEnabled('RPGO_SWO_RandomClasses') || `SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		if (IsPrimaryWeaponSpecialization())
		{
			Info = "[";
			Info $= class'XGLocalizedData_RPG'.default.SpecializationPrimary;
		}
		
		if (IsSecondaryWeaponSpecialization())
		{
			if (Info != "")
			{
				Info $= ", ";
			}
			else
			{
				Info = "[";
			}

			Info $= class'XGLocalizedData_RPG'.default.SpecializationSecondary;
		}
		
		if (Info != "")
		{
			Info $= "]";
		}

		//if (IsComplemtarySpecialization())
		//{
		//	Info @= class'UIUtilities_Text'.static.GetSizedText(
		//		class'XGLocalizedData_RPG'.default.SpecializationComplementary, 14
		//	);
		//}

		return class'UIUtilities_Text'.static.GetSizedText(Info, 16);
	}
	return "";
}

function string GetSpecializationAllowedWeaponCategoriesInfo()
{
	local string Categories;
	local array<string> LocalizedCategories;

	if (`SecondWaveEnabled('RPGO_SWO_WeaponRestriction') && SpecializationMetaInfo.AllowedWeaponCategories.Length > 0)
	{
		LocalizedCategories = GetLocalizedWeaponCategories();
		
		Categories = "(";
		Categories $= class'RPGO_UI_Helper'.static.Join(LocalizedCategories, ",");
		Categories $= ")";

		return class'UIUtilities_Text'.static.GetSizedText(Categories, 16);
	}

	return "";
}

function array<String> GetLocalizedWeaponCategories()
{
	local name WeaponCat;
	local array<string> LocalizedCategories;

	foreach SpecializationMetaInfo.AllowedWeaponCategories(WeaponCat)
	{
		if (LocalizedCategories.Find(LocalizeCategory(WeaponCat)) == INDEX_NONE)
		{
			LocalizedCategories.AddItem(LocalizeCategory(WeaponCat));
		}
	}

	return LocalizedCategories;
}

function bool IsPrimaryWeaponSpecialization()
{
	//	Specialization is valid to be soldier's Primary specialization only if has meta information set up, if it is valid for Primry Weapon slot, and only if it specifies some weapon categories it can unlock.
	return SpecializationMetaInfo.AllowedWeaponCategories.Length > 0 && SpecializationMetaInfo.InventorySlots.Find(eInvSlot_PrimaryWeapon) != INDEX_NONE;
}

function bool IsSecondaryWeaponSpecialization()
{
	return SpecializationMetaInfo.AllowedWeaponCategories.Length > 0 && SpecializationMetaInfo.InventorySlots.Find(eInvSlot_SecondaryWeapon) != INDEX_NONE;
}

function bool IsComplemtarySpecialization()
{
	return (!SpecializationMetaInfo.bCantBeComplementary && SpecializationMetaInfo.bUniversal);
}
/*
{
	if (SpecializationMetaInfo.bUseForRandomClasses)
	{
		//	If both the Primary Specailization and this Specialization are Dual Wielding, then just compare their weapon categories.
		if (PrimarySpecTemplate.SpecializationMetaInfo.bDualWield && SpecializationMetaInfo.bDualWield) //-- No need to check if the Secondary Specialization is for Dual Wielding, it's enough for it to just use the same weapons.
		{
			return class'X2SoldierClassTemplatePlugin'.static.DoSpecializationsUseTheSameWeapons(PrimarySpecTemplate, self);
		}

		return SpecializationMetaInfo.AllowedWeaponCategories.Length > 0 && SpecializationMetaInfo.InventorySlots.Find(eInvSlot_SecondaryWeapon) != INDEX_NONE;
	}
	//	Can't be Secondary Speci if no meta info is set up.
	return false;
}
*/

//	END OF Random Classes

function bool HasAnyAbilitiesInDeck()
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local SoldierClassAbilitySlot Slot;
	local X2AbilityTemplate Ability;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilitySlots(Slot)
	{
		Ability = AbilityTemplateManager.FindAbilityTemplate(Slot.AbilityType.AbilityName);
		if (Ability != none)
		{
			return true;
		}
	}

	return false;
}

function array<X2AbilityTemplate> GetAbilityTemplates()
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<X2AbilityTemplate> Templates;
	local X2AbilityTemplate Template;
	local SoldierClassAbilitySlot Slot;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilitySlots(Slot)
	{
		if (Slot.AbilityType.AbilityName != 'None')
		{
			Template = AbilityTemplateManager.FindAbilityTemplate(Slot.AbilityType.AbilityName);
			if (Template != none)
			{
				Templates.AddItem(Template);
			}
		}
	}
	return Templates;
}

function int GetComplementarySpecializationCheckSum()
{
	local name ComplementarySpecialization;
	local int CheckSum;

	CheckSum = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationIndex(none, Name);

	if (ForceComplementarySpecializations.Length > 0)
	{
		foreach ForceComplementarySpecializations(ComplementarySpecialization)
		{
			CheckSum += class'X2SoldierClassTemplatePlugin'.static.GetSpecializationIndex(none, ComplementarySpecialization);
		}
	}
	return CheckSum;
}

function string GetComplementarySpecializationInfo()
{
	local name ComplementarySpecialization;
	local array<string> SpecTitles;
	local string Info;
	
	if (ForceComplementarySpecializations.Length > 0)
	{
		foreach ForceComplementarySpecializations(ComplementarySpecialization)
		{
			SpecTitles.AddItem(
				class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateByName(ComplementarySpecialization).ClassSpecializationTitle
			);
		}

		JoinArray(SpecTitles, Info, ",");
	}

	return Info;
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

private function static string MakeBulletList(array<string> List)
{
	local string TipText;
	local int i;

	if (List.Length == 0)
	{
		return "";
	}

	TipText = "<ul>";
	for(i=0; i<List.Length; i++)
	{
		TipText $= "<li>" $ List[i] $ "</li>";
	}
	TipText $= "</ul>";
	
	return TipText;
}