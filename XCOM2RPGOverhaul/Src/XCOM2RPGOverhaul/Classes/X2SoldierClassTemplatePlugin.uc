// Subclasses X2SoldierClassTemplate to access some of the private variables
class X2SoldierClassTemplatePlugin extends X2SoldierClassTemplate config (JustForStaticVarHack);

// Static caching for better perfomance
var config bool bHasProcessedSpecs;
var config array<SoldierSpecialization> CachedSpecializations;


static function AddAdditionalSquaddieAbilities(
	XComGameState NewGameState,
	XComGameState_Unit UnitState
)
{
	local X2SoldierClassTemplate ClassTemplate;
	local SoldierClassAbilityType AbilityType;
	local array<X2UniversalSoldierClassInfo> SpecTemplates;
	local X2UniversalSoldierClassInfo SpecTemplate;
	local X2AbilityTemplate AbilityTemplate;
	local SCATProgression	AbilityProgression;
	local int iAbilityBranch;
	local name AbilityName;
	local array<name> AdditionalSquaddieAbilities;

	ClassTemplate = UnitState.GetSoldierClassTemplate();

	if(ClassTemplate != none && ClassTemplate.DataName == 'UniversalSoldier')
	{
		SpecTemplates = GetAssignedSpecializationTemplates(UnitState);
		foreach SpecTemplates(SpecTemplate)
		{
			
			foreach SpecTemplate.AdditionalSquaddieAbilities(AbilityName)
			{
				if (AdditionalSquaddieAbilities.Find(AbilityName) == INDEX_NONE)
				{
					AdditionalSquaddieAbilities.AddItem(AbilityName);
				}
			}
		}

		iAbilityBranch = UnitState.AbilityTree[0].Abilities.Length;
		
		foreach AdditionalSquaddieAbilities(AbilityName)
		{
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);
			if (AbilityTemplate != none)
			{
				AbilityType.AbilityName = AbilityTemplate.DataName;
				AbilityType.ApplyToWeaponSlot = AbilityTemplate.DefaultSourceItemSlot;
				UnitState.AbilityTree[0].Abilities.AddItem(AbilityType);

				AbilityProgression = UnitState.GetSCATProgressionForAbility(AbilityTemplate.DataName);
				UnitState.BuySoldierProgressionAbility(NewGameState, AbilityProgression.iRank, AbilityProgression.iBranch);

				`LOG(default.class @ GetFuncName() @ "adding" @ AbilityName @ `ShowVar(AbilityProgression.iRank) @ `ShowVar(AbilityProgression.iBranch),, 'RPG');
				iAbilityBranch++;
			}
		}
	}
}

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


// Get all available starting abilities
static function array<X2AbilityTemplate> GetAllStartingAbilities(XComGameState_Unit Unit)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<X2AbilityTemplate> AbilityTemplates;
	local array<SoldierClassRandomAbilityDeck> LocalRandomAbilityDecks;
	local SoldierClassRandomAbilityDeck Deck;
	local SoldierClassAbilityType AbilityType;
	
	if(Unit.IsSoldier())
	{
		AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

		LocalRandomAbilityDecks = Unit.GetSoldierClassTemplate().RandomAbilityDecks;

		foreach LocalRandomAbilityDecks(Deck)
		{
			foreach Deck.Abilities(AbilityType)
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityType.AbilityName);
				if(AbilityTemplate != none &&
					!AbilityTemplate.bDontDisplayInAbilitySummary &&
					AbilityTemplate.ConditionsEverValidForUnit(Unit, true) )
				{
					AbilityTemplate.DefaultSourceItemSlot = AbilityType.ApplyToWeaponSlot;
					AbilityTemplates.AddItem(AbilityTemplate);
				}
			}
		}
	}
	return AbilityTemplates;
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

//	Random Classes
//	get ALL spec templates
static function array<X2UniversalSoldierClassInfo> GetSpecializationTemplatesAvailableToSoldier(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization>			Specs;
	local SoldierSpecialization					Spec;
	local array<X2UniversalSoldierClassInfo>	ReturnArray;
	
	Specs = GetSpecializationsAvailableToSoldier(UnitState);

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
	
	if (SpecTemplate.SpecializationMetaInfo.bUseForRandomClasses)
	{
		//	If this spec is marked as Dual Wield one, it can be selected as a complementary spec to a primary spec that is also dual wield and uses the same weapons in the same slots.
		if (SpecTemplate.SpecializationMetaInfo.bDualWield && SelectedSpecTemplates.Length > 0 && SelectedSpecTemplates[0].SpecializationMetaInfo.bDualWield &&
			DoSpecializationsUseTheSameSlots(SelectedSpecTemplates[0], SpecTemplate) && DoSpecializationsUseTheSameWeapons(SelectedSpecTemplates[0], SpecTemplate))
		{
			 return true;
		}

		//	Exit now if the spec is explicitly forbidden from being complementary.
		if (SpecTemplate.SpecializationMetaInfo.bCantBeComplementary)
		{
			return false;
		}
		
		//	If the Spec Template is Universal, then it can Complement any other specialization just fine.
		if (SpecTemplate.IsComplemtarySpecialization()) return true;

		//	Otherwise, cycle through Specs that have already been selected.
		foreach SelectedSpecTemplates(CycleSpecTemplate)
		{
			//	At least one of the selected specializations roughly does the same thing as this specialization, then this specialization can complement that one.
			if (DoSpecializationsUseTheSameSlots(CycleSpecTemplate, SpecTemplate) &&
				DoSpecializationsUseTheSameWeapons(CycleSpecTemplate, SpecTemplate) ||
				 SpecTemplate.SpecializationMetaInfo.bShoot && CycleSpecTemplate.SpecializationMetaInfo.bShoot ||
				 SpecTemplate.SpecializationMetaInfo.bGremlin && CycleSpecTemplate.SpecializationMetaInfo.bGremlin ||
				 SpecTemplate.SpecializationMetaInfo.bPsionic && CycleSpecTemplate.SpecializationMetaInfo.bPsionic ||
				 SpecTemplate.SpecializationMetaInfo.bMelee && CycleSpecTemplate.SpecializationMetaInfo.bMelee)
			{
				return true;
			}
		}
	}
	return false;
}

static function bool IsSpecializationValidToBeSecondary(array<X2UniversalSoldierClassInfo> SelectedSpecTemplates, X2UniversalSoldierClassInfo SpecTemplate)
{
	//	Allow only specs with configured meta info.
	if (SpecTemplate.SpecializationMetaInfo.bUseForRandomClasses)
	{
		if (SelectedSpecTemplates.Length > 0)
		{
			//	Primary specs marked as Dual Wield do not get secondary specs.
			if (SelectedSpecTemplates[0].SpecializationMetaInfo.bDualWield) 
			{
				//`LOG(SpecTemplate.Name @ "is not valid, because primary spec is dual wield.",, 'RPG');
				return false;
			}
		
			//	If this spec is marked as Dual Wield spec, and it uses the same weapons as the primary spec,
			if (SpecTemplate.SpecializationMetaInfo.bDualWield && DoSpecializationsUseTheSameWeapons(SelectedSpecTemplates[0], SpecTemplate))
			{
				//	then this spec can become a secondary spec for it
				//	Looking up Secondary Weight allows to restrict specific specs from becoming secondary to dual wield specs.

				if (SpecTemplate.SpecializationMetaInfo.iWeightSecondary <= 0) `LOG(SpecTemplate.Name @ "is not valid, because iWeightSecondary is zero or lower.",, 'RPG');
				return SpecTemplate.SpecializationMetaInfo.iWeightSecondary > 0;
			}
		}
		//	If this spec is not a dual wield spec, then we only check if the spec itself is valid to be a secondary on its own.
		//if (!SpecTemplate.IsSecondaryWeaponSpecialization())
		//{
		//	`LOG(SpecTemplate.Name @ "is not valid, because it's not a secondary spec.",, 'RPG');
		//}
		return SpecTemplate.IsSecondaryWeaponSpecialization();		
	}
	return false;
}

static function bool DoSpecializationsUseTheSameSlots(X2UniversalSoldierClassInfo SpecTemplateA, X2UniversalSoldierClassInfo SpecTemplateB)
{
	local EInventorySlot InventorySlot;
	
	foreach SpecTemplateA.SpecializationMetaInfo.InventorySlots(InventorySlot)
	{
		if (SpecTemplateB.SpecializationMetaInfo.InventorySlots.Find(InventorySlot) != INDEX_NONE)
		{
			return true;
		}
	}
	return false;
}

static function bool DoSpecializationsUseTheSameWeapons(X2UniversalSoldierClassInfo SpecTemplateA, X2UniversalSoldierClassInfo SpecTemplateB)
{
	local name WeaponCat;
	
	foreach SpecTemplateA.SpecializationMetaInfo.AllowedWeaponCategories(WeaponCat)
	{
		if (SpecTemplateB.SpecializationMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE)
		{
			return true;
		}
	}
	return false;
}
//	END OF Random Classes


static function array<name> GetAllowedPrimaryWeaponCategories(XComGameState_Unit UnitState)
{	
	local array<SoldierSpecialization>	PrimarySpecs;
	local SoldierSpecialization			PrimarySpec;
	local X2UniversalSoldierClassInfo	PrimarySpecTemplate;
	local array<name>					ReturnArray;
	local name							WeaponCat;

	PrimarySpecs = GetTrainedPrimaryWeaponSpecializations(UnitState);
	foreach PrimarySpecs(PrimarySpec)
	{
		PrimarySpecTemplate = GetSpecializationTemplate(PrimarySpec);
		if (PrimarySpecTemplate != none)
		{
			foreach PrimarySpecTemplate.SpecializationMetaInfo.AllowedWeaponCategories(WeaponCat)
			{
				ReturnArray.AddItem(WeaponCat);
			}
		}
		else `LOG("Weapon Restrictions: GetAllowedPrimaryWeaponCategories: ERROR, could not get Spec Template for spec:" @ PrimarySpec.TemplateName,, 'RPG');
	}

	if (ReturnArray.Length == 0 || class'X2SecondWaveConfigOptions'.static.AlwaysAllowAssaultRifles())
	{
		//	Soldiers are always allowed to at least use an Assault Rifle.
		ReturnArray.AddItem('rifle');
	}

	return ReturnArray;
}

static function array<name> GetAllowedSecondaryWeaponCategories(XComGameState_Unit UnitState)
{	
	local array<SoldierSpecialization>	PrimarySpecs;
	local SoldierSpecialization			PrimarySpec;
	local X2UniversalSoldierClassInfo	PrimarySpecTemplate;

	local array<SoldierSpecialization>	SecondarySpecs;
	local SoldierSpecialization			SecondarySpec;
	local X2UniversalSoldierClassInfo	SecondarySpecTemplate;
	local array<name>					ReturnArray;
	local name							WeaponCat;

	//	Dual Wield specs allow their weapon categories to be used in the secondary weapon slot as well.
	PrimarySpecs = GetTrainedPrimaryWeaponSpecializations(UnitState);
	foreach PrimarySpecs(PrimarySpec)
	{
		PrimarySpecTemplate = GetSpecializationTemplate(PrimarySpec);
		if (PrimarySpecTemplate != none)
		{
			if (PrimarySpecTemplate.SpecializationMetaInfo.bDualWield)
			{
				foreach PrimarySpecTemplate.SpecializationMetaInfo.AllowedWeaponCategories(WeaponCat)
				{
					ReturnArray.AddItem(WeaponCat);
				}
			}
		}
		else `LOG("Weapon Restrictions: GetAllowedSecondaryWeaponCategories: ERROR, could not get Spec Template for spec:" @ PrimarySpec.TemplateName,, 'RPG');
	}

	SecondarySpecs = GetTrainedSecondaryWeaponSpecializations(UnitState);
	foreach SecondarySpecs(SecondarySpec)
	{
		SecondarySpecTemplate = GetSpecializationTemplate(SecondarySpec);
		if (SecondarySpecTemplate != none)
		{
			foreach SecondarySpecTemplate.SpecializationMetaInfo.AllowedWeaponCategories(WeaponCat)
			{
				ReturnArray.AddItem(WeaponCat);
			}
		}
		else `LOG("Weapon Restrictions: GetAllowedSecondaryWeaponCategories: ERROR, could not get Spec Template for spec:" @ SecondarySpec.TemplateName,, 'RPG');
	}

	if (ReturnArray.Length == 0)
	{
		//	Soldiers are always allowed to at least use an Empty Secondary.
		ReturnArray.AddItem('empty');
	}

	return ReturnArray;
}

static function bool IsPrimaryWeaponCategoryAllowed(XComGameState_Unit UnitState, name WeaponCat)
{	
	local array<SoldierSpecialization>	PrimarySpecs;
	local SoldierSpecialization			PrimarySpec;
	local X2UniversalSoldierClassInfo	PrimarySpecTemplate;

	PrimarySpecs = GetTrainedPrimaryWeaponSpecializations(UnitState);

	//`LOG("Weapon Restrictions: IsPrimaryWeaponCategoryAllowed:" @ UnitState.GetFullName() @ WeaponCat @ "Primary Specs:" @ PrimarySpecs.Length,, 'RPG');

	//	Cycle through all soldier's primary specs. 
	foreach PrimarySpecs(PrimarySpec)
	{
		//`LOG("Primary Spec:" @ PrimarySpec.TemplateName,, 'RPG');
		PrimarySpecTemplate = GetSpecializationTemplate(PrimarySpec);
		if (PrimarySpecTemplate != none)
		{
			//	If this spec allows using this weapon, return true.
			if (PrimarySpecTemplate.SpecializationMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE)
			{
				//`LOG("It has a matching WeaponCat, returning true",, 'RPG');
				return true;
			}
		}
		else `LOG("Weapon Restrictions: GetAllowedPrimaryWeaponCategories: ERROR, could not get Spec Template for spec:" @ PrimarySpec.TemplateName,, 'RPG');
	}

	//	If soldier has at least one primary spec, it means SOME weapon category is available to the soldier, just not THIS one. 
	//	So we return true ONLY if this weapon category is an Assault Rifle, and the option to always enable Assault Rifles is selected in MCM.
	if (PrimarySpecs.Length > 0)
	{
		//`LOG("No match found, returning false.",, 'RPG');
		return class'X2SecondWaveConfigOptions'.static.AlwaysAllowAssaultRifles() && WeaponCat == 'rifle';
	}
	else 
	{
		//	Soldier doesn't have any primary specs, so we allow using Assault Rifles as a fallback.
		//`LOG("WARNING No primary specs found, returning Rifle check.",, 'RPG');
		return WeaponCat == 'rifle';
	}
}


static function bool IsSecondaryWeaponCategoryAllowed(XComGameState_Unit UnitState, name WeaponCat)
{	
	local array<SoldierSpecialization>	PrimarySpecs;
	local SoldierSpecialization			PrimarySpec;
	local X2UniversalSoldierClassInfo	PrimarySpecTemplate;
	local bool							bAtLeastOnePrimaryDualWieldSpec;

	local array<SoldierSpecialization>	SecondarySpecs;
	local SoldierSpecialization			SecondarySpec;
	local X2UniversalSoldierClassInfo	SecondarySpecTemplate;

	//	Dual Wield specs allow their weapon categories to be used in the secondary weapon slot as well.
	PrimarySpecs = GetTrainedPrimaryWeaponSpecializations(UnitState);
	foreach PrimarySpecs(PrimarySpec)
	{
		PrimarySpecTemplate = GetSpecializationTemplate(PrimarySpec);
		if (PrimarySpecTemplate != none)
		{
			if (PrimarySpecTemplate.SpecializationMetaInfo.bDualWield)
			{
				bAtLeastOnePrimaryDualWieldSpec = true;
				if (PrimarySpecTemplate.SpecializationMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE)
				{
					return true;
				}
			}
		}
		else `LOG("Weapon Restrictions: GetAllowedSecondaryWeaponCategories: ERROR, could not get Spec Template for spec:" @ PrimarySpec.TemplateName,, 'RPG');
	}

	SecondarySpecs = GetTrainedSecondaryWeaponSpecializations(UnitState);
	foreach SecondarySpecs(SecondarySpec)
	{
		SecondarySpecTemplate = GetSpecializationTemplate(SecondarySpec);
		if (SecondarySpecTemplate != none)
		{
			if (SecondarySpecTemplate.SpecializationMetaInfo.AllowedWeaponCategories.Find(WeaponCat) != INDEX_NONE)
			{
				return true;
			}
		}
		else `LOG("Weapon Restrictions: GetAllowedSecondaryWeaponCategories: ERROR, could not get Spec Template for spec:" @ SecondarySpec.TemplateName,, 'RPG');
	}

	if (SecondarySpecs.Length == 0 && !bAtLeastOnePrimaryDualWieldSpec)
	{
		//	Soldiers are allowed to use an Empty Secondary if they don't have any Secondary specs nor primary dual wield specs.
		return WeaponCat == 'empty';
	}
	else 
	{
		//	Soldier has at least one Secondary Spec, or at least one Primary Dual Wield Spec, which means they can use SOME secondary weapon, just not THIS one.
		//	So return false, disallowing using this weapon cat.
		return false;
	}
}
//	END OF Weapon Restrictions

static function X2UniversalSoldierClassInfo GetSpecializationTemplateByName(name TemplateName)
{
	return new(None, string(TemplateName))class'X2UniversalSoldierClassInfo';
}


// This gets the specialization by index only looking intro the currently assigned specs
static function X2UniversalSoldierClassInfo GetSpecTemplateBySlotFromAssignedSpecs(XComGameState_Unit UnitState, int SlotIndex)
{
	local SoldierSpecialization Spec;

	if(GetSpecializationForSlotFromAssignedSpecs(UnitState, SlotIndex, Spec))
	{
		return GetSpecializationTemplateByName(Spec.TemplateName);
	}
	return none;
}

// This checks gets the specialization by checking ALL spec
static function X2UniversalSoldierClassInfo GetSpecTemplateBySlotFromAvailableSpecs(XComGameState_Unit UnitState, int SlotIndex)
{
	return GetSpecializationTemplate(GetSpecializationBySlotFromAvailableSpecs(UnitState, SlotIndex));
}

static function SoldierSpecialization GetSpecializationBySlotFromAvailableSpecs(XComGameState_Unit UnitState, int SlotIndex)
{
	local array<SoldierSpecialization> Specs;

	Specs = GetSpecializationsAvailableToSoldier(UnitState);

	return Specs[SlotIndex];
}

static function int GetSpecializationIndex(XComGameState_Unit UnitState, name SpecTemplateName)
{
	local array<SoldierSpecialization> Specs;

	if (UnitState != none)
	{
		Specs = GetSpecializationsAvailableToSoldier(UnitState);
	}
	else
	{
		Specs = GetSpecializations();
	}

	return Specs.Find('TemplateName', SpecTemplateName);
}


static function array<SoldierSpecialization> GetSpecializationsByIndex(XComGameState_Unit UnitState, array<int> IndexArray)
{
	local int Index;
	local array<SoldierSpecialization> Specs;

	foreach IndexArray(Index)
	{
		Specs.AddItem(GetSpecializationBySlotFromAvailableSpecs(UnitState, Index));
	}
	return Specs;
}

static function array<SoldierSpecialization> GetComplementarySpecializations(XComGameState_Unit UnitState, SoldierSpecialization Spec)
{
	local X2UniversalSoldierClassInfo SpecTemplate;
	local name ForceComplementarySpec;
	local array<SoldierSpecialization> AllSpecs, ComplementarySpecs;
	local int ComplementarySpecIndex;

	AllSpecs = GetSpecializationsAvailableToSoldier(UnitState);
	SpecTemplate = GetSpecializationTemplate(Spec);

	if (SpecTemplate.ForceComplementarySpecializations.Length > 0)
	{
		foreach SpecTemplate.ForceComplementarySpecializations(ForceComplementarySpec)
		{
			ComplementarySpecIndex = GetSpecializationIndex(UnitState, ForceComplementarySpec);
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
			UniversalSoldierClassTemplate.GetClassSpecializationTitleWithMetaData()
		,, 'RPG');
		
		AddAbilityRanks(UniversalSoldierClassTemplate.ClassSpecializationTitle, UniversalSoldierClassTemplate.AbilitySlots);

		foreach UniversalSoldierClassTemplate.AdditionalRandomTraits(RandomAbility)
		{
			Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'TraitsXComAbilities')].Abilities.AddItem(RandomAbility);
			`LOG("Specialization" @ UniversalSoldierClassTemplate.GetClassSpecializationTitleWithMetaData() @
				"adding" @ RandomAbility.AbilityName @ "to" @ Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'TraitsXComAbilities')].DeckName
			,, 'RPG');
		}

		foreach UniversalSoldierClassTemplate.AdditionalRandomAptitudes(RandomAbility)
		{
			Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'InnateAptitudesDeck')].Abilities.AddItem(RandomAbility);
			`LOG("Specialization" @ UniversalSoldierClassTemplate.GetClassSpecializationTitleWithMetaData() @
				"adding" @ RandomAbility.AbilityName @ "to" @ Template.RandomAbilityDecks[Template.RandomAbilityDecks.Find('DeckName', 'InnateAptitudesDeck')].DeckName
			,, 'RPG');
		}
	}
}

// get all ability template for a certain spec
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
		UniversalSoldierClassTemplate = GetSpecializationTemplateByName(class'X2TemplateHelper_RPGOverhaul'.default.Specializations[Index].TemplateName);

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

static function array<X2UniversalSoldierClassInfo> GetAllAvailableSpecializationTemplates()
{
	local array<SoldierSpecialization> AllSpecs;
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;
	local array<X2UniversalSoldierClassInfo> Templates;

	AllSpecs = GetSpecializations();

	foreach AllSpecs(Spec)
	{
		UniversalSoldierClassTemplate = GetSpecializationTemplateByName(Spec.TemplateName);
		Templates.AddItem(UniversalSoldierClassTemplate);
	}

	return Templates;
}

static function array<SoldierSpecialization> GetSpecializationsAvailableToSoldier(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> AllSpecs, SpecsAvailableToSoldier;
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;

	AllSpecs = GetSpecializations();

	foreach AllSpecs(Spec)
	{
		UniversalSoldierClassTemplate = GetSpecializationTemplateByName(Spec.TemplateName);
		if (UniversalSoldierClassTemplate.RequiredAbilities.Length > 0)
		{
			if (class'RPGO_Helper'.static.HasAnyOfTheAbilitiesFromAnySource(UnitState, UniversalSoldierClassTemplate.RequiredAbilities))
			{
				SpecsAvailableToSoldier.AddItem(Spec);
			}
		}
		else
		{
			SpecsAvailableToSoldier.AddItem(Spec);
		}
	}

	return SpecsAvailableToSoldier;
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

	Template = GetSpecTemplateBySlotFromAssignedSpecs(UnitState, SlotIndex);

	if (Template != none)
	{
		return Template.ClassSpecializationTitle;
	}
	return "";
}

static function string GetMetaInfoForSlot(XComGameState_Unit UnitState, int SlotIndex)
{
	local X2UniversalSoldierClassInfo Template;
	
	Template = GetSpecTemplateBySlotFromAssignedSpecs(UnitState, SlotIndex);
	if (Template != none)
	{
		return Template.GetSpecializationWeaponSlotInfo() @ Template.GetSpecializationAllowedWeaponCategoriesInfo();
	}
	return "";
}

static function string GetAssignedSpecsMetaInfo(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> SoldierSpecs;
	local SoldierSpecialization Spec;
	local array<string> PrimaryWeaponCategories, PrimaryWeaponCategoriesFromSpec, SecondaryWeaponCategories, SecondaryWeaponCategoriesFromSpec;
	local string WeaponCategory;
	local X2UniversalSoldierClassInfo Template;
	local string Info;
	local array<string> PrimarySpecs, SecondarySpecs;

	SoldierSpecs = GetTrainedPrimaryWeaponSpecializations(UnitState);
	foreach SoldierSpecs(Spec)
	{
		Template = GetSpecializationTemplateByName(Spec.TemplateName);
		PrimarySpecs.AddItem(Template.ClassSpecializationTitle);

		PrimaryWeaponCategoriesFromSpec = Template.GetLocalizedWeaponCategories();
		foreach PrimaryWeaponCategoriesFromSpec(WeaponCategory)
		{
			if (PrimaryWeaponCategories.Find(WeaponCategory) == INDEX_NONE)
			{
				PrimaryWeaponCategories.AddItem(WeaponCategory);
			}

			if (Template.SpecializationMetaInfo.bDualWield &&
				SecondaryWeaponCategories.Find(WeaponCategory) == INDEX_NONE)
			{
				SecondaryWeaponCategories.AddItem(WeaponCategory);
			}
		}
	}

	SoldierSpecs = GetTrainedSecondaryWeaponSpecializations(UnitState);
	foreach SoldierSpecs(Spec)
	{
		Template = GetSpecializationTemplateByName(Spec.TemplateName);
		SecondarySpecs.AddItem(Template.ClassSpecializationTitle);

		SecondaryWeaponCategoriesFromSpec = Template.GetLocalizedWeaponCategories();
		foreach SecondaryWeaponCategoriesFromSpec(WeaponCategory)
		{
			if (SecondaryWeaponCategories.Find(WeaponCategory) == INDEX_NONE)
			{
				SecondaryWeaponCategories.AddItem(WeaponCategory);
			}
		}
	}

	if (`SecondWaveEnabled('RPGO_SWO_RandomClasses') || `SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		if (PrimarySpecs.Length > 0)
		{
			Info = class'UIUtilities_Text'.static.GetColoredText(class'XGLocalizedData_RPG'.default.SpecializationPrimary, eUIState_Header);
			Info @= class'RPGO_UI_Helper'.static.Join(PrimarySpecs, ", ") $ " ";
		}
		if (SecondarySpecs.Length > 0)
		{
			Info $= class'UIUtilities_Text'.static.GetColoredText(class'XGLocalizedData_RPG'.default.SpecializationSecondary, eUIState_Header);
			Info @= class'RPGO_UI_Helper'.static.Join(SecondarySpecs, ", ") $ "<br />";
		}
	}

	if (`SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		if (PrimaryWeaponCategories.Length > 0)
		{
			Info $= class'UIUtilities_Text'.static.GetColoredText(class'XGLocalizedData_RPG'.default.AllowedWeaponCategoriesPrimary, eUIState_Header);
			Info @= class'RPGO_UI_Helper'.static.Join(PrimaryWeaponCategories, ", ") $ " ";
		}
		if (SecondaryWeaponCategories.Length > 0)
		{
			Info $= class'UIUtilities_Text'.static.GetColoredText(class'XGLocalizedData_RPG'.default.AllowedWeaponCategoriesSecondary, eUIState_Header);
			Info @= class'RPGO_UI_Helper'.static.Join(SecondaryWeaponCategories, ", ");
		}
	}
	return class'UIUtilities_Text'.static.GetSizedText(Info, 16);
}

static function array<int> GetAssignedSpecializationsIndices(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> AllSpecs, SoldierSpecs;
	local SoldierSpecialization Spec;
	local array<int> Indices;
	local int Index;

	SoldierSpecs = GetAssignedSpecializations(UnitState);
	AllSpecs = GetSpecializationsAvailableToSoldier(UnitState);

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

static function bool HasSpecializationAssigned(XComGameState_Unit UnitState, name TemplateName)
{
	local array<SoldierSpecialization> Specs;
	local int Index;

	Specs = GetAssignedSpecializations(UnitState);
	Index = Specs.Find('TemplateName', TemplateName);
	return (Index != INDEX_NONE);
}

static function bool HasTrainedPrimaryWeaponSpecializations(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> Specs;

	Specs = GetTrainedPrimaryWeaponSpecializations(UnitState);

	return Specs.length > 0;
}

static function bool HasTrainedSecondarySpecializations(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> Specs;

	Specs = GetTrainedSecondaryWeaponSpecializations(UnitState);

	return Specs.length > 0;
}

static function array<string> GetSpecializationTitles(array<SoldierSpecialization> Specs)
{
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo Template;
	local array<string> SpecsTitles;

	foreach Specs(Spec)
	{
		Template = GetSpecializationTemplateByName(Spec.TemplateName);
		SpecsTitles.AddItem(Template.ClassSpecializationTitle);
	}

	return SpecsTitles;
}

static function array<SoldierSpecialization> GetTrainedPrimaryWeaponSpecializations(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> Specs, PrimarySpecs;
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo Template;
	local UnitValue	ChosenPrimarySpec;

	if (`SecondWaveEnabled('RPGO_SWO_RandomClasses'))
	{
		if (UnitState.GetUnitValue('PrimarySpecialization_Value', ChosenPrimarySpec))
		{
			Spec = GetSpecializationBySlotFromAvailableSpecs(UnitState, ChosenPrimarySpec.fValue);
			PrimarySpecs.AddItem(Spec);
		}
	}
	else
	{
		Specs = GetAssignedSpecializations(UnitState);

		foreach Specs(Spec)
		{
			Template = GetSpecializationTemplateByName(Spec.TemplateName);
			if (Template.IsPrimaryWeaponSpecialization())
			{
				PrimarySpecs.AddItem(Spec);
			}
		}
	}
	
	return PrimarySpecs;
}

static function array<SoldierSpecialization> GetTrainedSecondaryWeaponSpecializations(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> Specs, SecondarySpecs;
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo Template;
	local UnitValue	ChosenSecondarySpec;

	if (`SecondWaveEnabled('RPGO_SWO_RandomClasses'))
	{
		if (UnitState.GetUnitValue('SecondarySpecialization_Value', ChosenSecondarySpec))
		{
			Spec = GetSpecializationBySlotFromAvailableSpecs(UnitState, ChosenSecondarySpec.fValue);
			SecondarySpecs.AddItem(Spec);
		}
	}
	else
	{
		Specs = GetAssignedSpecializations(UnitState);

		foreach Specs(Spec)
		{
			Template = GetSpecializationTemplateByName(Spec.TemplateName);
			if (Template.IsSecondaryWeaponSpecialization() || Template.SpecializationMetaInfo.bDualWield)
			{
				SecondarySpecs.AddItem(Spec);
			}
		}
	}
	
	return SecondarySpecs;
}

static function array<SoldierClassAbilitySlot> GetAllAbilitySlotsForRank(XComGameState_Unit UnitState, int RankIndex)
{
	local array<SoldierSpecialization> Specs;
	local SoldierSpecialization Spec;
	local array<SoldierClassAbilitySlot> AbilitySlots;
	local X2UniversalSoldierClassInfo Template;

	Specs = GetSpecializationsAvailableToSoldier(UnitState);
	foreach Specs(Spec)
	{
		Template = GetSpecializationTemplate(Spec);
		AbilitySlots.AddItem(Template.AbilitySlots[RankIndex - 1]);
	}
	return AbilitySlots;
}

static function array<SoldierSpecialization> GetAssignedSpecializations(XComGameState_Unit UnitState)
{
	local array<SoldierSpecialization> Specs;
	local SoldierSpecialization Spec;
	local int Index;
	local array<SoldierClassAbilityType> Abilities;
	
	Abilities = UnitState.GetRankAbilities(1);

	for (Index = 0; Index < Abilities.Length; Index++)
	{
		if (GetSpecializationForSlotFromAssignedSpecs(UnitState, Index, Spec))
		{
			Specs.AddItem(Spec);
		}
	}

	return Specs;
}

static function array<X2UniversalSoldierClassInfo> GetAssignedSpecializationTemplates(XComGameState_Unit UnitState)
{
	local array<X2UniversalSoldierClassInfo> Templates;
	local array<SoldierSpecialization> Specs;
	local SoldierSpecialization Spec;

	Specs = GetAssignedSpecializations(UnitState);
	foreach Specs(Spec)
	{
		Templates.AddItem(GetSpecializationTemplate(Spec));
	}
	return Templates;
}


static function bool GetSpecializationForSlotFromAssignedSpecs(XComGameState_Unit UnitState, int SlotIndex, out SoldierSpecialization Spec)
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

	if (SlotIndex != INDEX_NONE)
	{
		for (Index = 1; Index < UnitState.GetSoldierClassTemplate().GetMaxConfiguredRank(); Index++)
		{
			if (UnitState.AbilityTree.Length > Index && UnitState.AbilityTree[Index].Abilities.Length > SlotIndex)
			{
				SoldierAbilitiesForSlot.AddItem(UnitState.AbilityTree[Index].Abilities[SlotIndex].AbilityName);
			}
		}
	}

	Specs = class'X2TemplateHelper_RPGOverhaul'.default.Specializations;

	foreach Specs(PossibleSpec)
	{
		Template = GetSpecializationTemplateByName(PossibleSpec.TemplateName);
		
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
