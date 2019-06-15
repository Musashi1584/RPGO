class X2SecondWaveConfigOptions extends Object config (SecondWaveOptions);

function static bool ShowChooseSpecScreen(XComGameState_Unit UnitState)
{
	local UnitValue AbilityChosen, SpecChosen;

	UnitState.GetUnitValue('SecondWaveCommandersChoiceAbilityChosen', AbilityChosen);
	UnitState.GetUnitValue('SecondWaveCommandersChoiceSpecChosen', SpecChosen);

	return UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' &&
		`SecondWaveEnabled('RPGOCommandersChoice') &&
		SpecChosen.fValue != 1 &&
		!ShowChooseAbilityScreen(UnitState);
}

function static bool ShowChooseAbilityScreen(XComGameState_Unit UnitState)
{
	local UnitValue AbilityChosen, SpecChosen;

	UnitState.GetUnitValue('SecondWaveCommandersChoiceAbilityChosen', AbilityChosen);
	UnitState.GetUnitValue('SecondWaveCommandersChoiceSpecChosen', SpecChosen);

	return UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' &&
		`SecondWaveEnabled('RPGOOrigins') &&
		AbilityChosen.fValue != 1 &&
		(class'X2SecondWaveConfigOptions'.static.GetOriginsAbiltiesCount() +
		 class'X2SecondWaveConfigOptions'.static.GetOriginsRandomAbiltiesCount() > 0);
}



static function int GetSpecRouletteCount()
{
	return (`SecondWaveEnabled('RPGOCommandersChoice') && `SecondWaveEnabled('RPGOSpecRoulette')) ?
		class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("SPEC_ROULETTE_RANDOM_SPEC_COUNT_COMBI") :
		class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("SPEC_ROULETTE_RANDOM_SPEC_COUNT");
}

static function int GetCommandersChoiceCount()
{
	return  (`SecondWaveEnabled('RPGOCommandersChoice') && `SecondWaveEnabled('RPGOSpecRoulette')) ?
		class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("COMMANDERS_CHOICE_SPEC_COUNT_COMBI") :
		class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("COMMANDERS_CHOICE_SPEC_COUNT");
}

static function int GetOriginsAbiltiesCount()
{
	return  class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("ORIGINS_CHOICE_ABILITY_COUNT");
}

static function int GetOriginsRandomAbiltiesCount()
{
	return  class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("ORIGINS_ADDITIONAL_RANDOM_ABILTIES");
}

static function AddStartingAbilities(
	XComGameState NewGameState,
	XComGameState_Unit UnitState,
	array<X2AbilityTemplate> Abilities
)
{
	local X2SoldierClassTemplate ClassTemplate;
	local SoldierClassAbilityType AbilityType;
	local X2AbilityTemplate Ability;
	local int iAbilityBranch;

	ClassTemplate = UnitState.GetSoldierClassTemplate();

	if(ClassTemplate != none && ClassTemplate.DataName == 'UniversalSoldier')
	{
		UnitState.AbilityTree[0].Abilities.Length = 0;
		UnitState.ResetSoldierAbilities();
		iAbilityBranch = 0;
		foreach Abilities(Ability)
		{
			AbilityType.AbilityName = Ability.DataName;
			AbilityType.ApplyToWeaponSlot = Ability.DefaultSourceItemSlot;
			UnitState.AbilityTree[0].Abilities.AddItem(AbilityType);
			UnitState.BuySoldierProgressionAbility(NewGameState, 0, iAbilityBranch);
			iAbilityBranch++;
			
		}
	}
}

// Get Random specs for spec roulette
static function array<int> GetRandomSpecIndices(XComGameState_Unit UnitState)
{
	local int Count, RandomSlotIndex, Index, ComplementarySpecIndex;
	local array<int> RandomAbilitySlotIndices;
	local X2UniversalSoldierClassInfo SpecTemplate;
	local name ForceComplementarySpec;

	`LOG(default.class @ GetFuncName() @ "Start profiling",, 'RPG');

	Count = GetSpecRouletteCount();

	for (Index = 0; Index < Count; Index++)
	{
		while (true)
		{
			RandomSlotIndex = `SYNC_RAND_STATIC(UnitState.GetSoldierClassTemplate().AbilityTreeTitles.Length);
			if (RandomAbilitySlotIndices.Find(RandomSlotIndex) == INDEX_NONE)
			{
				break;
			}
		}

		SpecTemplate = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateForSlotIndex(RandomSlotIndex);

		RandomAbilitySlotIndices.AddItem(RandomSlotIndex);

		if (SpecTemplate.ForceComplementarySpecializations.Length > 0)
		{
			foreach SpecTemplate.ForceComplementarySpecializations(ForceComplementarySpec)
			{
				ComplementarySpecIndex = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationIndex(ForceComplementarySpec);
				if (RandomAbilitySlotIndices.Find(ComplementarySpecIndex) == INDEX_NONE)
				{
					RandomAbilitySlotIndices.AddItem(ComplementarySpecIndex);
				}
			}
		}
		
		// if we already reached the limit due to complementary specs break here
		if (RandomAbilitySlotIndices.Length >= Count)
		{
			break;
		}
	}

	foreach RandomAbilitySlotIndices(Index)
	{
		`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette add random index" @ Index @ class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateForSlotIndex(Index).ClassSpecializationTitle,, 'RPG');
	}

	`LOG(default.class @ GetFuncName() @ "Stop profiling",, 'RPG');

	return RandomAbilitySlotIndices;
}


static function BuildRandomSpecAbilityTree(XComGameState_Unit UnitState, optional bool bRandomizePerkOrder = false)
{
	`LOG(default.class @ GetFuncName() @ "SPEC_ROULETTE_RANDOM_SPEC_COUNT" @ GetSpecRouletteCount(),, 'RPG');
	BuildSpecAbilityTree(UnitState, GetRandomSpecIndices(UnitState), true, bRandomizePerkOrder);
}

// Empty AddSpecializationIndices will be treated as all specs
static function BuildSpecAbilityTree(
	XComGameState_Unit UnitState,
	array<int> AddSpecializationIndices,
	optional bool bResetAbilityTree = true,
	optional bool bRandomizePerkOrder = false
)
{
	local X2SoldierClassTemplate ClassTemplate;
	local SoldierRankAbilities RankAbilities, EmptyRankAbilities;
	local array<SoldierClassRandomAbilityDeck> RandomAbilityDecks;
	local SoldierClassRandomAbilityDeck RandomDeck;
	local array<SoldierClassAbilitySlot> AllAbilitySlots;
	local SoldierClassAbilitySlot AbilitySlot;
	local SoldierClassAbilityType EmptyAbility, Ability;
	local int RankIndex, SlotIndex, DeckIndex;

	ClassTemplate = UnitState.GetSoldierClassTemplate();

	if(ClassTemplate != none && ClassTemplate.DataName == 'UniversalSoldier')
	{
		// Reset everything above squaddie
		if (bResetAbilityTree)
		{
			UnitState.AbilityTree.Length = 1;
		}
	
		// Grab random ability decks
		RandomAbilityDecks = ClassTemplate.RandomAbilityDecks;

		if (bRandomizePerkOrder)
		{
			AddSWORandomizedAbilityDecks(ClassTemplate, AddSpecializationIndices, RandomAbilityDecks);
		}

		// Go rank by rank, filling in our tree
		for(RankIndex = 1; RankIndex < ClassTemplate.GetMaxConfiguredRank(); RankIndex++)
		{
			RankAbilities = EmptyRankAbilities;
			AllAbilitySlots = ClassTemplate.GetAbilitySlots(RankIndex);

			// Determine ability (or lack thereof) from each slot
			for(SlotIndex = 0; SlotIndex < AllAbilitySlots.Length; SlotIndex++)
			{
				
				if (AddSpecializationIndices.Length > 0 && AddSpecializationIndices.Find(SlotIndex) == INDEX_NONE)
				{
					continue;
				}

				AbilitySlot = AllAbilitySlots[SlotIndex];

				if (bRandomizePerkOrder &&
					RankIndex >= Max(1, class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("TRAINING_ROULETTE_MIN_RANK")) &&
					RankIndex <= Min(ClassTemplate.GetMaxConfiguredRank() - 1, class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("TRAINING_ROULETTE_MAX_RANK")) &&
					!class'X2TemplateHelper_RPGOverhaul'.static.IsPrerequisiteAbility(AbilitySlot.AbilityType.AbilityName)
				)
				{
					AbilitySlot.RandomDeckName = GetTrainingRouletteDeckname(SlotIndex);
				}

				// First check for random ability from deck
				if(AbilitySlot.RandomDeckName != '')
				{
					DeckIndex = RandomAbilityDecks.Find('DeckName', AbilitySlot.RandomDeckName);

					if(DeckIndex != INDEX_NONE)
					{
						RandomDeck = RandomAbilityDecks[DeckIndex];
						RankAbilities.Abilities.AddItem(GetAbilityFromRandomDeck(RandomDeck));
						RandomAbilityDecks[DeckIndex] = RandomDeck; // Resave the deck so we don't get the same abilities multiple times
					}
					else
					{
						// Deck not found, probably a data error
						`LOG("Random ability deck" @ string(AbilitySlot.RandomDeckName) @ "not found.",, 'RPG');
						RankAbilities.Abilities.AddItem(EmptyAbility);
					}
				}
				else
				{
					// Use the ability type listed (can be blank)
					RankAbilities.Abilities.AddItem(AbilitySlot.AbilityType);
				}
			}

			// Add the rank to the ability tree
			if (RankIndex < UnitState.AbilityTree.Length)
			{
				foreach RankAbilities.Abilities(Ability)
				{
					UnitState.AbilityTree[RankIndex].Abilities.AddItem(Ability);
				}
			}
			else
			{
				UnitState.AbilityTree.AddItem(RankAbilities);
			}
		}
	}
	else
	{
		`LOG("Tried to build soldier ability tree without a set soldier class.",, 'RPG');
	}
}

static function AddSWORandomizedAbilityDecks(
	X2SoldierClassTemplate ClassTemplate,
	array<int> AddSpecializationIndices,
	out array<SoldierClassRandomAbilityDeck> RandomDecks
)
{
	
	local array<SoldierClassAbilitySlot> AllAbilitySlots;
	local SoldierClassAbilitySlot AbilitySlot;
	local SoldierClassRandomAbilityDeck SWORandomDeck;
	local int RankIndex, SlotIndex, DeckIndex;
	
	for(RankIndex = Max(1, class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("TRAINING_ROULETTE_MIN_RANK")); RankIndex <= Min(ClassTemplate.GetMaxConfiguredRank() - 1, class'RPGO_SWO_UserSettingsConfigManager'.static.GetConfigIntValue("TRAINING_ROULETTE_MAX_RANK")); RankIndex++)
	{
		AllAbilitySlots = ClassTemplate.GetAbilitySlots(RankIndex);

		// Determine ability (or lack thereof) from each slot
		for(SlotIndex = 0; SlotIndex < AllAbilitySlots.Length; SlotIndex++)
		{
				
			if (AddSpecializationIndices.Length > 0 && AddSpecializationIndices.Find(SlotIndex) == INDEX_NONE)
			{
				continue;
			}

			AbilitySlot = AllAbilitySlots[SlotIndex];
			if (!class'X2TemplateHelper_RPGOverhaul'.static.IsPrerequisiteAbility(AbilitySlot.AbilityType.AbilityName))
			{
				DeckIndex = RandomDecks.Find('DeckName', GetTrainingRouletteDeckname(SlotIndex));
				if (DeckIndex == INDEX_NONE)
				{
					SWORandomDeck.DeckName = GetTrainingRouletteDeckname(SlotIndex);
					SWORandomDeck.Abilities.Length = 0;
					SWORandomDeck.Abilities.AddItem(AbilitySlot.AbilityType);
					RandomDecks.AddItem(SWORandomDeck);
				}
				else
				{
					RandomDecks[DeckIndex].Abilities.AddItem(AbilitySlot.AbilityType);
				}
			}
		}
	}
}



static function name GetTrainingRouletteDeckname(int SlotIndex)
{
	return Name("RPGO_SWO_TrainingRoulette_Spec" $ SlotIndex);
}

static function SoldierClassAbilityType GetAbilityFromRandomDeck(out SoldierClassRandomAbilityDeck RandomDeck)
{
	local SoldierClassAbilityType AbilityToReturn;
	local int RandIndex;
	
	if(RandomDeck.Abilities.Length == 0)
	{
		return AbilityToReturn;
	}

	RandIndex = `SYNC_RAND_STATIC(RandomDeck.Abilities.Length);
	
	AbilityToReturn = RandomDeck.Abilities[RandIndex];
	RandomDeck.Abilities.Remove(RandIndex, 1);
	
	return AbilityToReturn;
}

// unused
static function int GetRequisiteIndex(array<SoldierClassAbilityType> Abilities, SoldierClassAbilityType SourceAbility, optional bool bHasPrerequisite = false)
{
	local SoldierClassAbilityType Ability;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local name PrerequisiteAbilityName;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(SourceAbility.AbilityName);

	if (AbilityTemplate == none)
	{
		return INDEX_NONE;
	}

	foreach AbilityTemplate.PrerequisiteAbilities(PrerequisiteAbilityName)
	{
		bHasPrerequisite = true;
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(PrerequisiteAbilityName);

		if (AbilityTemplate == none)
		{
			continue;
		}

		if (AbilityTemplate.PrerequisiteAbilities.Length > 0 &&
			Abilities.Find('AbilityName', PrerequisiteAbilityName) != INDEX_NONE)
		{
			Ability.AbilityName = PrerequisiteAbilityName;
			return GetRequisiteIndex(Abilities, Ability, true);
		}

		if (bHasPrerequisite)
		{
			return Abilities.Find('AbilityName', PrerequisiteAbilityName);
		}
	}

	return INDEX_NONE;
}
