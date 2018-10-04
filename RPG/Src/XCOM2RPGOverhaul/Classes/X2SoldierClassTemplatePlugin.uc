class X2SoldierClassTemplatePlugin extends X2SoldierClassTemplate;

static function AddSlot(X2SoldierClassTemplate Template, SoldierClassAbilitySlot Slot, int RankIndex)
{
	Template.SoldierRanks[RankIndex].AbilitySlots.AddItem(Slot);
}

static function ResetDummySlot(X2SoldierClassTemplate Template)
{
	local int Index;

	for(Index = 1; Index < Template.SoldierRanks.Length; Index++)
	{
		//Template.SoldierRanks[Index].AbilitySlots.Remove(0, 1);
		Template.SoldierRanks[Index].AbilitySlots.Length = 0;
	}
}

static function DeleteSpecialization(X2SoldierClassTemplate Template, name SpecializationName, int SpecializationIndex)
{
	local int Index;

	for(Index = 1; Index < Template.SoldierRanks.Length; Index++)
	{
		`LOG("Removing" @ SpecializationIndex @ Template.SoldierRanks[Index].AbilitySlots[SpecializationIndex].AbilityType.AbilityName,, 'RPG');
		Template.SoldierRanks[Index].AbilitySlots.Remove(SpecializationIndex, 1);
		Template.SoldierRanks[Index].aStatProgression.Remove(SpecializationIndex, 1);
	}

	Template.AbilityTreeTitles.RemoveItem(string(SpecializationName));
}