//-----------------------------------------------------------
//	Class:	RPGO_Helper
//	Author: Musashi
//	
//-----------------------------------------------------------
class RPGO_Helper extends Object;

static function bool HasAnyOfTheAbilitiesFromAnySource(XComGameState_Unit UnitState, array<name> AbilitiesToCheck)
{
	local bool bHasAbility;
	local name Ability;

	foreach AbilitiesToCheck(Ability)
	{
		if (UnitState.HasSoldierAbility(Ability))
		{
			return true;
		}
	}

	if (!bHasAbility)
	{
		bHasAbility = HasAnyOfTheAbilitiesFromInventory(UnitState, AbilitiesToCheck);
	}

	if (!bHasAbility)
	{
		bHasAbility = HasAnyOfTheAbilitiesFromCharacterTemplate(UnitState, AbilitiesToCheck);
	}

	return bHasAbility;
}


// Start helper methods for Issue #735
static function bool HasAnyOfTheAbilitiesFromInventory(XComGameState_Unit UnitState, array<name> AbilitiesToCheck)
{
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2EquipmentTemplate EquipmentTemplate;
	local name Ability;

	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		EquipmentTemplate = X2EquipmentTemplate(InventoryItem.GetMyTemplate());
		if (EquipmentTemplate != none)
		{
			foreach EquipmentTemplate.Abilities(Ability)
			{
				if (AbilitiesToCheck.Find(Ability) != INDEX_NONE)
				{
					return true;
				}
			}
		}
	}
	return false;
}

static function bool HasAnyOfTheAbilitiesFromCharacterTemplate(XComGameState_Unit UnitState, array<name> AbilitiesToCheck)
{
	local name Ability;

	foreach UnitState.GetMyTemplate().Abilities(Ability)
	{
		if (AbilitiesToCheck.Find(Ability) != INDEX_NONE)
		{
			return true;
		}
	}
	return false;
}