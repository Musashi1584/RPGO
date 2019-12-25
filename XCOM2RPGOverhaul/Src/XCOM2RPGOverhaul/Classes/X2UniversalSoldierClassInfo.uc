class X2UniversalSoldierClassInfo extends Object PerObjectConfig PerObjectLocalized config (RPG);

var config string ClassSpecializationIcon;
var config array<name> ForceComplementarySpecializations;
var config array<SoldierClassAbilitySlot> AbilitySlots;

var config array<SoldierClassAbilityType> AdditionalRandomTraits;
var config array<SoldierClassAbilityType> AdditionalRandomAptitudes;

var localized string ClassSpecializationSummary;
var localized string ClassSpecializationTitle;

//	IRI Random Classes
struct IRIMetaInfoStruct
{
	var bool bMeta;
	var array<name> AllowedWeaponCategories;
	var array<EInventorySlot> InventorySlots;

	//	This specialization can be rolled only as Primary one, and then will provide access to the same AllowedWeaponCategories for both weapon slots.
	var bool bDualWield;

	//	Use to determine whether this specialization is valid to complement other soldier's specializations.
	var bool bUniversal;
	var bool bShoot;
	var bool bMelee;
	var bool bGremlin;
	var bool bPsionic;
	var bool bCantBeComplementary;
	var int  iWeightPrimary;
	var int  iWeightSecondary;
	var int  iWeightComplementary;

	//	check necromancer skills that are weapon agnostic
	//	look at AllowedWeapons instead of using bool flags?..
	structdefaultproperties
	{
		iWeightPrimary = 1
		iWeightSecondary = 1
		iWeightComplementary = 1
	}
};
var config IRIMetaInfoStruct IRIMetaInfo;

function bool IRI_IsWeaponAllowed(EInventorySlot Slot, name WeaponCat)
{
	if (IRIMetaInfo.bDualWield)
	{
		return IRIMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE;
	}
	else return IRIMetaInfo.InventorySlots.Find(Slot) != INDEX_NONE && IRIMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE;
}

function bool IRI_IsPrimaryWeaponSpecialization()
{
	//	Specialization is valid to be soldier's Primary specialization only if has meta information set up, if it is valid for Primry Weapon slot, and only if it specifies some weapon categories it can unlock.
	return IRIMetaInfo.bMeta && IRIMetaInfo.AllowedWeaponCategories.Length > 0 && IRIMetaInfo.InventorySlots.Find(eInvSlot_PrimaryWeapon) != INDEX_NONE;
}

function bool IRI_IsSecondaryWeaponSpecialization()
{
	return IRIMetaInfo.bMeta && IRIMetaInfo.AllowedWeaponCategories.Length > 0 && IRIMetaInfo.InventorySlots.Find(eInvSlot_SecondaryWeapon) != INDEX_NONE;
}
/*
{
	if (IRIMetaInfo.bMeta)
	{
		//	If both the Primary Specailization and this Specialization are Dual Wielding, then just compare their weapon categories.
		if (PrimarySpecTemplate.IRIMetaInfo.bDualWield && IRIMetaInfo.bDualWield) //-- No need to check if the Secondary Specialization is for Dual Wielding, it's enough for it to just use the same weapons.
		{
			return class'X2SoldierClassTemplatePlugin'.static.DoSpecializationsUseTheSameWeapons(PrimarySpecTemplate, self);
		}

		return IRIMetaInfo.AllowedWeaponCategories.Length > 0 && IRIMetaInfo.InventorySlots.Find(eInvSlot_SecondaryWeapon) != INDEX_NONE;
	}
	//	Can't be Secondary Speci if no meta info is set up.
	return false;
}
*/

//	END OF IRI Random Classes

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

	CheckSum = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationIndex(Name);

	if (ForceComplementarySpecializations.Length > 0)
	{
		foreach ForceComplementarySpecializations(ComplementarySpecialization)
		{
			CheckSum += class'X2SoldierClassTemplatePlugin'.static.GetSpecializationIndex(ComplementarySpecialization);
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