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

function bool IsPrimaryWeaponSpecialization()
{
	//	Specialization is valid to be soldier's Primary specialization only if has meta information set up, if it is valid for Primry Weapon slot, and only if it specifies some weapon categories it can unlock.
	return SpecializationMetaInfo.bMeta && SpecializationMetaInfo.AllowedWeaponCategories.Length > 0 && SpecializationMetaInfo.InventorySlots.Find(eInvSlot_PrimaryWeapon) != INDEX_NONE;
}

function bool IsSecondaryWeaponSpecialization()
{
	return SpecializationMetaInfo.bMeta && SpecializationMetaInfo.AllowedWeaponCategories.Length > 0 && SpecializationMetaInfo.InventorySlots.Find(eInvSlot_SecondaryWeapon) != INDEX_NONE;
}
/*
{
	if (SpecializationMetaInfo.bMeta)
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