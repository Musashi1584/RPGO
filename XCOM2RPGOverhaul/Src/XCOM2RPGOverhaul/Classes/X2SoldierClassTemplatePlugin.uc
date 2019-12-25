// Subclasses X2SoldierClassTemplate to access some of the private variables
class X2SoldierClassTemplatePlugin extends X2SoldierClassTemplate config (JustForStaticVarHack);

// Static caching for better perfomance
var config bool bHasProcessedSpecs;
var config array<SoldierSpecialization> CachedSpecializations;

static function array<X2AbilityTemplate> GetRandomStartingAbilities(XComGameState_Unit UnitState, int Count)
{
	local X2SoldierClassTemplate ClassTemplate;
	local array<SoldierClassRandomAbilityDeck> RandomStartingAbilityDecks;
	local SoldierClassAbilityType AbilityType;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<X2AbilityTemplate> Templates;
	local X2AbilityTemplate Template;
	local int Index;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	
	ClassTemplate = UnitState.GetSoldierClassTemplate();
	RandomStartingAbilityDecks = ClassTemplate.RandomAbilityDecks;

	for(Index = 0; Index < Count; Index++)
	{
		AbilityType = class'X2SecondWaveConfigOptions'.static.GetAbilityFromRandomDeck(RandomStartingAbilityDecks[Index % RandomStartingAbilityDecks.Length]);
		if (AbilityType.AbilityName != 'None')
		{
			Template = AbilityTemplateManager.FindAbilityTemplate(AbilityType.AbilityName);
			if (Template != none)
			{
				Templates.AddItem(Template);
			}
		}
	}

	return Templates;
}

// Get all owned ability templates for rank
static function array<X2AbilityTemplate> GetAbilityTemplatesForRank(XComGameState_Unit UnitState, int Rank)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<X2AbilityTemplate> Templates;
	local X2AbilityTemplate Template;
	local array<SoldierClassAbilityType> AbilityTypes;
	local SoldierClassAbilityType AbilityType;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	AbilityTypes = UnitState.GetRankAbilities(Rank);

	foreach AbilityTypes(AbilityType)
	{
		if (AbilityType.AbilityName != 'None')
		{
			Template = AbilityTemplateManager.FindAbilityTemplate(AbilityType.AbilityName);
			if (Template != none)
			{
				Templates.AddItem(Template);
			}
		}
	}
	return Templates;
}

// get spec template
static function X2UniversalSoldierClassInfo GetSpecializationTemplate(SoldierSpecialization Spec)
{
	return GetSpecializationTemplateByName(Spec.TemplateName);
}

//	IRI Random Classes
//	get ALL spec templates
static function array<X2UniversalSoldierClassInfo> GetAllSpecializationTemplates()
{
	local array<SoldierSpecialization>			Specs;
	local SoldierSpecialization					Spec;
	local array<X2UniversalSoldierClassInfo>	ReturnArray;
	
	Specs = GetSpecializations();

	foreach Specs(Spec)
	{	
		ReturnArray.AddItem(GetSpecializationTemplateByName(Spec.TemplateName));
	}
	return ReturnArray;
}

static function bool IsSpecializationValidToBeComplementary(array<X2UniversalSoldierClassInfo> SelectedSpecTemplates, X2UniversalSoldierClassInfo SpecTemplate)
{
	local X2UniversalSoldierClassInfo CycleSpecTemplate;

	//	Specialization cannot be used if it's missing meta information
	//	Or it is explicitly forbidden from being complementary
	if (!SpecTemplate.IRIMetaInfo.bMeta || SpecTemplate.IRIMetaInfo.bCantBeComplementary) return false;

	//	If the Spec Template is Universal, then it can Complement any other specialization just fine.
	if (SpecTemplate.IRIMetaInfo.bUniversal) return true;

	//	Otherwise, cycle through Specs that have already been selected.
	foreach SelectedSpecTemplates(CycleSpecTemplate)
	{
		//	At least one of the selected specializations roughly does the same thing as this specialization, then this specialization can complement that one.
		if (DoSpecializationsUseTheSameSlots(CycleSpecTemplate, SpecTemplate) &&
			DoSpecializationsUseTheSameWeapons(CycleSpecTemplate, SpecTemplate) ||
			 SpecTemplate.IRIMetaInfo.bShoot && CycleSpecTemplate.IRIMetaInfo.bShoot ||
			 SpecTemplate.IRIMetaInfo.bGremlin && CycleSpecTemplate.IRIMetaInfo.bGremlin ||
			 SpecTemplate.IRIMetaInfo.bPsionic && CycleSpecTemplate.IRIMetaInfo.bPsionic ||
			 SpecTemplate.IRIMetaInfo.bMelee && CycleSpecTemplate.IRIMetaInfo.bMelee)
		{
			return true;
		}
	}
	return false;
}

/*
{
	local X2UniversalSoldierClassInfo CycleSpecTemplate;

	//	Specialization cannot be used if it's missing meta information
	//	Or if it is explicitly forbidden from being complementary
	if (!SpecTemplate.IRIMetaInfo.bMeta || SpecTemplate.IRIMetaInfo.bCantBeComplementary) return false;

	//	If the Spec Template is Universal, then it can Complement any other specialization just fine.
	if (SpecTemplate.IRIMetaInfo.bUniversal) return true;

	//	If both the Primary Specailization and this Specialization are Dual Wielding, then just compare their weapon categories.
	if (SelectedSpecTemplates[0] != none && 
		SelectedSpecTemplates[0].IRIMetaInfo.bDualWield && 
					SpecTemplate.IRIMetaInfo.bDualWield)
	{
		return DoSpecializationsUseTheSameWeapons(SelectedSpecTemplates[0], SpecTemplate);
	}

	//	Otherwise, cycle through Specs that have already been selected.
	foreach SelectedSpecTemplates(CycleSpecTemplate)
	{
		//	At least one of the selected specializations roughly does the same thing as this specialization, then this specialization can complement that one.
		if (DoSpecializationsUseTheSameSlots(CycleSpecTemplate, SpecTemplate) &&
			(DoSpecializationsUseTheSameWeapons(CycleSpecTemplate, SpecTemplate) ||
			 SpecTemplate.IRIMetaInfo.bShoot && CycleSpecTemplate.IRIMetaInfo.bShoot ||
			 SpecTemplate.IRIMetaInfo.bGremlin && CycleSpecTemplate.IRIMetaInfo.bGremlin ||
			 SpecTemplate.IRIMetaInfo.bPsionic && CycleSpecTemplate.IRIMetaInfo.bPsionic ||
			 SpecTemplate.IRIMetaInfo.bMelee && CycleSpecTemplate.IRIMetaInfo.bMelee))
		{
			return true;
		}
	}
	return false;
}
*/

static function bool DoSpecializationsUseTheSameSlots(X2UniversalSoldierClassInfo SpecTemplateA, X2UniversalSoldierClassInfo SpecTemplateB)
{
	local EInventorySlot InventorySlot;
	
	foreach SpecTemplateA.IRIMetaInfo.InventorySlots(InventorySlot)
	{
		if (SpecTemplateB.IRIMetaInfo.InventorySlots.Find(InventorySlot) != INDEX_NONE)
		{
			return true;
		}
	}
	return false;
}

static function bool DoSpecializationsUseTheSameWeapons(X2UniversalSoldierClassInfo SpecTemplateA, X2UniversalSoldierClassInfo SpecTemplateB)
{
	local name WeaponCat;
	
	foreach SpecTemplateA.IRIMetaInfo.AllowedWeaponCategories(WeaponCat)
	{
		if (SpecTemplateB.IRIMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE)
		{
			return true;
		}
	}
	return false;
}
//	END OF IRI Random Classes

static function X2UniversalSoldierClassInfo GetSpecializationTemplateByName(name TemplateName)
{
	return new(None, string(TemplateName))class'X2UniversalSoldierClassInfo';
}

static function X2UniversalSoldierClassInfo GetSpecializationTemplateForSlotIndex(int SlotIndex)
{
	local array<SoldierSpecialization> Specs;

	Specs = GetSpecializations();

	return GetSpecializationTemplate(Specs[SlotIndex]);
}

static function int GetSpecializationIndex(name SpecTemplateName)
{
	local array<SoldierSpecialization> Specs;

	Specs = GetSpecializations();

	return Specs.Find('TemplateName', SpecTemplateName);
}

static function array<SoldierSpecialization> GetComplementarySpecializations(SoldierSpecialization Spec)
{
	local X2UniversalSoldierClassInfo SpecTemplate;
	local name ForceComplementarySpec;
	local array<SoldierSpecialization> AllSpecs, ComplementarySpecs;
	local int ComplementarySpecIndex;

	AllSpecs = GetSpecializations();
	SpecTemplate = GetSpecializationTemplate(Spec);

	if (SpecTemplate.ForceComplementarySpecializations.Length > 0)
	{
		foreach SpecTemplate.ForceComplementarySpecializations(ForceComplementarySpec)
		{
			ComplementarySpecIndex = GetSpecializationIndex(ForceComplementarySpec);
			if (ComplementarySpecIndex != INDEX_NONE)
			{
				ComplementarySpecs.AddItem(AllSpecs[ComplementarySpecIndex]);
			}
		}
	}

	return ComplementarySpecs;
}
// adds all specializations to the universal soldier class template
static function SetupSpecialization(name SoldierClassTemplate)
{
	local X2SoldierClassTemplateManager Manager;
	local X2SoldierClassTemplate Template;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;
	local SoldierClassAbilityType RandomAbility;
	local name TemplateName;
	local int Index;

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	Template = Manager.FindSoldierClassTemplate(SoldierClassTemplate);

	Template.AbilityTreeTitles.Length = 0;
	class'X2SoldierClassTemplatePlugin'.static.ResetDummySlot(Template);

	class'X2TemplateHelper_RPGOverhaul'.default.Specializations = GetSpecializations();

	for (Index = 0; Index < class'X2TemplateHelper_RPGOverhaul'.default.Specializations.Length; Index++)
	{
		TemplateName = class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].TemplateName;
		UniversalSoldierClassTemplate = GetSpecializationTemplate(class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index]);

		`LOG("Specialization" @ Index @ TemplateName @
			class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].bEnabled @
			UniversalSoldierClassTemplate.ClassSpecializationTitle
		,, 'RPG');
		
		AddAbilityRanks(UniversalSoldierClassTemplate.ClassSpecializationTitle, UniversalSoldierClassTemplate.AbilitySlots);

		foreach UniversalSoldierClassTemplate.AdditionalRandomTraits(RandomAbility)
		{
			Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'TraitsXComAbilities')].Abilities.AddItem(RandomAbility);
			`LOG("Specialization" @ UniversalSoldierClassTemplate.ClassSpecializationTitle @
				"adding" @ RandomAbility.AbilityName @ "to" @ Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'TraitsXComAbilities')].DeckName
			,, 'RPG');
		}

		foreach UniversalSoldierClassTemplate.AdditionalRandomAptitudes(RandomAbility)
		{
			Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'InnateAptitudesDeck')].Abilities.AddItem(RandomAbility);
			`LOG("Specialization" @ UniversalSoldierClassTemplate.ClassSpecializationTitle @
				"adding" @ RandomAbility.AbilityName @ "to" @ Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'InnateAptitudesDeck')].DeckName
			,, 'RPG');
		}
	}
}

// get all ability templates for a certain spec
static function array<X2AbilityTemplate> GetAbilityTemplatesForSpecializations(SoldierSpecialization Spec)
{
	return GetSpecializationTemplate(Spec).GetAbilityTemplates();
}

// get all specializations ordered
static function array<SoldierSpecialization> GetSpecializations()
{
	local X2SoldierClassTemplateManager Manager;
	local X2SoldierClassTemplate Template;
	local array<SoldierSpecialization> ValidSpecs;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;
	local int Index;
	local bool bHasAnyAbilitiesInDeck;

	if (default.bHasProcessedSpecs)
	{
		return default.CachedSpecializations;
	}

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	Template = Manager.FindSoldierClassTemplate('UniversalSoldier');

	// Sort here cause plugin mods which loaded first could added to the array already
	class'X2TemplateHelper_RPGOverhaul'.default.Specializations.Sort(SortSpecializations);

	for (Index = 0; Index < class'X2TemplateHelper_RPGOverhaul'.default.Specializations.Length; Index++)
	{
		UniversalSoldierClassTemplate = new(None, string(class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].TemplateName))class'X2UniversalSoldierClassInfo';
		if (UniversalSoldierClassTemplate.AbilitySlots.Length > 0 && class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].bEnabled)
		{
			bHasAnyAbilitiesInDeck = UniversalSoldierClassTemplate.HasAnyAbilitiesInDeck();
			
			if (bHasAnyAbilitiesInDeck && ValidSpecs.Find('TemplateName', class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].TemplateName) == INDEX_NONE)
			{
				ValidSpecs.AddItem(class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index]);
			}
		}
		else
		{
			`LOG("Removing Specialization" @ Index @ class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].TemplateName,, 'RPG');
			class'X2SoldierClassTemplatePlugin'.static.DeleteSpecialization(Template, class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].TemplateName, Index);
		}
	}

	default.CachedSpecializations = ValidSpecs;
	default.bHasProcessedSpecs = true;

	return ValidSpecs;
}

function int SortSpecializations(SoldierSpecialization A, SoldierSpecialization B)
{
	return A.Order > B.Order ? -1 : 0;
}

// add a specialization to the universal soldier class template
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
}

// find the spec title for a slot by inspecting the perks in the slot
static function string GetAbilityTreeTitle(XComGameState_Unit UnitState, int SlotIndex)
{
	local X2UniversalSoldierClassInfo Template;

	if (UnitState.GetSoldierClassTemplateName() != 'UniversalSoldier')
	{
		return UnitState.GetSoldierClassTemplate().AbilityTreeTitles[SlotIndex];
	}

	Template = GetSpecializationTemplateForSlot(UnitState, SlotIndex);

	if (Template != none)
	{
		return Template.ClassSpecializationTitle;
	}
}

static function array<int> GetTrainedSpecializationsIndices(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> AllSpecs, SoldierSpecs;
	local SoldierSpecialization Spec;
	local array<int> Indices;
	local int Index;

	SoldierSpecs = GetTrainedSpecializations(UnitState);
	AllSpecs = GetSpecializations();

	foreach SoldierSpecs(Spec)
	{
		Index = AllSpecs.Find('TemplateName', Spec.TemplateName);
		if (Index != INDEX_NONE)
		{
			`LOG(GetFuncName() @ Spec.TemplateName @ Index,, 'RPG');
			Indices.AddItem(Index);
		}
	}
	return Indices;
}

static function array<SoldierSpecialization> GetTrainedSpecializations(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> Specs;
	local SoldierSpecialization Spec;
	local int Index;
	local array<SoldierClassAbilityType> Abilities;
	
	Abilities = UnitState.GetRankAbilities(1);

	for (Index = 0; Index < Abilities.Length; Index++)
	{
		if (GetSpecializationForSlot(UnitState, Index, Spec))
		{
			Specs.AddItem(Spec);
		}
	}

	return Specs;
}

static function bool GetSpecializationForSlot(XComGameState_Unit UnitState, int SlotIndex, out SoldierSpecialization Spec)
{
	local array<SoldierSpecialization> Specs;
	local SoldierSpecialization PossibleSpec;
	local X2UniversalSoldierClassInfo Template;
	local SoldierClassAbilitySlot SpecAbilitySlot;
	local array<name> SoldierAbilitiesForSlot;
	local array<name> SpecAbilitiesForSlot;
	local name Ability;
	local int Index;
	local bool bFound;

	//`LOG(default.class @ GetFuncName() @ UnitState.SummaryString() @ UnitState.GetSoldierClassTemplateName(),, 'RPG');
	
	for (Index = 1; Index < UnitState.GetSoldierClassTemplate().GetMaxConfiguredRank(); Index++)
	{
		if (UnitState.AbilityTree.Length > Index && UnitState.AbilityTree[Index].Abilities.Length > SlotIndex)
		{
			SoldierAbilitiesForSlot.AddItem(UnitState.AbilityTree[Index].Abilities[SlotIndex].AbilityName);
		}
	}

	Specs = class'X2TemplateHelper_RPGOverhaul'.default.Specializations;

	foreach Specs(PossibleSpec)
	{
		Template = new(None, string(PossibleSpec.TemplateName))class'X2UniversalSoldierClassInfo';
		
		SpecAbilitiesForSlot.Length = 0;

		foreach Template.AbilitySlots(SpecAbilitySlot)
		{
			SpecAbilitiesForSlot.AddItem(SpecAbilitySlot.AbilityType.AbilityName);
		}

		//`LOG(default.class @ GetFuncName() @ Template.ClassSpecializationTitle @ SoldierAbilitiesForSlot[0] @ SpecAbilitiesForSlot[0],, 'RPG');

		bFound = (SoldierAbilitiesForSlot.Length > 0);

		foreach SoldierAbilitiesForSlot(Ability)
		{
			if(SpecAbilitiesForSlot.Find(Ability) == INDEX_NONE)
			{
				bFound = false;
				break;
			}
		}

		if(bFound)
		{
			Spec = PossibleSpec;
			return true;
		}
	}

	return false;
}

static function X2UniversalSoldierClassInfo GetSpecializationTemplateForSlot(XComGameState_Unit UnitState, int SlotIndex)
{
	local SoldierSpecialization Spec;

	if(GetSpecializationForSlot(UnitState, SlotIndex, Spec))
	{
		return new(None, string(Spec.TemplateName))class'X2UniversalSoldierClassInfo';
	}
	return none;
}

static function AddSlot(X2SoldierClassTemplate Template, SoldierClassAbilitySlot Slot, int RankIndex)
{
	Template.SoldierRanks[RankIndex].AbilitySlots.AddItem(Slot);
}

static function ResetDummySlot(X2SoldierClassTemplate Template)
{
	local int Index;

	for(Index = 1; Index < Template.SoldierRanks.Length; Index++)
	{
		Template.SoldierRanks[Index].AbilitySlots.Remove(0, 1);
	}
}

static function DeleteSpecialization(X2SoldierClassTemplate Template, name SpecializationName, int SpecializationIndex)
{
	local int Index;

	for(Index = 1; Index < Template.SoldierRanks.Length; Index++)
	{
		//`LOG("Removing" @ SpecializationIndex @ Template.SoldierRanks[Index].AbilitySlots[SpecializationIndex].AbilityType.AbilityName,, 'RPG');
		Template.SoldierRanks[Index].AbilitySlots.Remove(SpecializationIndex, 1);
		Template.SoldierRanks[Index].aStatProgression.Remove(SpecializationIndex, 1);
	}

	Template.AbilityTreeTitles.RemoveItem(string(SpecializationName));
}