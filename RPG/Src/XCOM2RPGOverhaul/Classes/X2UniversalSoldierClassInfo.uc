class X2UniversalSoldierClassInfo extends Object PerObjectConfig PerObjectLocalized config (RPG);

var config string ClassSpecializationIcon;
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
