class X2SecondWaveConfigOptions extends Object config (SecondWaveOptions);

var config int SpecRouletteRandomSpecCount;
var config int CommandersChoiceSpecCount;
var config int SpecRouletteRandomSpecCount_Combi;
var config int CommandersChoiceSpecCount_Combi;
var config int TrainingRouletteMinRank;
var config int TrainingRouletteMaxRank;

static function int GetSpecRouletteCount()
{
	return  (`SecondWaveEnabled('RPGOCommandersChoice') && `SecondWaveEnabled('RPGOSpecRoulette')) ?
		default.SpecRouletteRandomSpecCount_Combi :
		default.SpecRouletteRandomSpecCount;
}

static function int GetCommandersChoiceCount()
{
	return  (`SecondWaveEnabled('RPGOCommandersChoice') && `SecondWaveEnabled('RPGOSpecRoulette')) ?
		default.CommandersChoiceSpecCount_Combi :
		default.CommandersChoiceSpecCount;
}


static function array<int> GetRandomSpecIndices(XComGameState_Unit UnitState)
{
	local int Count, RandomSlotIndex, Index;
	local array<int> RandomAbilitySlotIndices;

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
		RandomAbilitySlotIndices.AddItem(RandomSlotIndex);
		`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette add random index" @ RandomAbilitySlotIndices[RandomAbilitySlotIndices.Length - 1],, 'RPG');
	}
	return RandomAbilitySlotIndices;
}

static function BuildRandomSpecAbilityTree(XComGameState_Unit UnitState, optional bool bRandomizePerkOrder = false)
{
	`LOG(default.class @ GetFuncName() @ "SpecRouletteRandomSpecCount" @ GetSpecRouletteCount(),, 'RPG');
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

	// Reset everything above squaddie
	if (bResetAbilityTree)
	{
		UnitState.AbilityTree.Length = 1;
	}
	
	if(ClassTemplate != none)
	{
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
					RankIndex >= Max(1, default.TrainingRouletteMinRank) &&
					RankIndex <= Min(ClassTemplate.GetMaxConfiguredRank() - 1, default.TrainingRouletteMaxRank))
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
	
	for(RankIndex = Max(1, default.TrainingRouletteMinRank); RankIndex <= Min(ClassTemplate.GetMaxConfiguredRank() - 1, default.TrainingRouletteMaxRank); RankIndex++)
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

static function name GetTrainingRouletteDeckname(int SlotIndex)
{
	return Name("RPGO_SWO_TrainingRoulette_Spec" $ SlotIndex);
}

static function SoldierClassAbilityType GetAbilityFromRandomDeck(out SoldierClassRandomAbilityDeck RandomDeck)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local SoldierClassAbilityType AbilityToReturn;
	local name PrerequisiteAbilityName;
	local int RandIndex, PrerequisiteAbilityIndex, SourceAbilityIndex, LoopTimeout;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if(RandomDeck.Abilities.Length == 0)
	{
		return AbilityToReturn;
	}

	while (LoopTimeout < RandomDeck.Abilities.Length)
	{
		RandIndex = `SYNC_RAND_STATIC(RandomDeck.Abilities.Length);
		AbilityToReturn = RandomDeck.Abilities[RandIndex];
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityToReturn.AbilityName);
		PrerequisiteAbilityIndex = GetRequisiteIndex(RandomDeck.Abilities, AbilityToReturn);

		if (AbilityTemplate.PrerequisiteAbilities.Length == 0 && PrerequisiteAbilityIndex == INDEX_NONE)
		{
			break;
		}

		if (PrerequisiteAbilityIndex != INDEX_NONE)
		{
			if (RandIndex > PrerequisiteAbilityIndex)
			{
				break;
			}
		}

		foreach AbilityTemplate.PrerequisiteAbilities(PrerequisiteAbilityName)
		{
			SourceAbilityIndex = RandomDeck.Abilities.Find('AbilityName', PrerequisiteAbilityName);
			if (SourceAbilityIndex != INDEX_NONE)
			{
				if (SourceAbilityIndex < RandIndex)
				{
					break;
				}
			}
		}

		LoopTimeout++;
	}


	RandomDeck.Abilities.Remove(RandIndex, 1);
	return AbilityToReturn;
}

static function int GetRequisiteIndex(array<SoldierClassAbilityType> Abilities, SoldierClassAbilityType SourceAbility)
{
	local SoldierClassAbilityType Ability;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local name PrerequisiteAbilityName;
	local int PrerequisiteAbilityIndex;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	for (PrerequisiteAbilityIndex = 0; PrerequisiteAbilityIndex < Abilities.Length; PrerequisiteAbilityIndex++)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(Abilities[PrerequisiteAbilityIndex].AbilityName);

		if (AbilityTemplate == none || AbilityTemplate.PrerequisiteAbilities.Length == 0)
		{
			continue;
		}

		foreach AbilityTemplate.PrerequisiteAbilities(PrerequisiteAbilityName)
		{
			if (PrerequisiteAbilityName == SourceAbility.AbilityName)
			{
				return PrerequisiteAbilityIndex;
			}
		}
	}
	return INDEX_NONE;
}
