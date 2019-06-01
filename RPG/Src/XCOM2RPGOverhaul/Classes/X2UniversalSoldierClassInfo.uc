class X2UniversalSoldierClassInfo extends Object PerObjectConfig PerObjectLocalized config (RPG);

var config string ClassSpecializationIcon;
var config array<name> ForceComplementarySpecializations;
var config array<SoldierClassAbilitySlot> AbilitySlots;
var localized string ClassSpecializationSummary;
var localized string ClassSpecializationTitle;

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