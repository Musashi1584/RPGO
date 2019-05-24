class X2SecondWaveConfigOptions extends Object config (SecondWaveOptions);

var config int SecondWaveSpecRouletteRandomSpecCount;
var config int SecondWaveCommandersChoiceSpecCount;

static function array<int> GetRandomSpecIndices(XComGameState_Unit UnitState)
{
	local int RandomSlotIndex, Index;
	local array<int> RandomAbilitySlotIndices;

	for (Index = 0; Index < default.SecondWaveSpecRouletteRandomSpecCount; Index++)
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

static function BuildRandomSpecAbilityTree(XComGameState_Unit UnitState)
{
	`LOG(default.class @ GetFuncName() @ "SecondWaveSpecRouletteRandomSpecCount" @ default.SecondWaveSpecRouletteRandomSpecCount,, 'RPG');
	BuildSpecAbilityTree(UnitState, GetRandomSpecIndices(UnitState));
}

static function BuildSpecAbilityTree(XComGameState_Unit UnitState, array<int> SpecIndices)
{
	local X2SoldierClassTemplate ClassTemplate;
	local SoldierRankAbilities RankAbilities, EmptyRankAbilities;
	local array<SoldierClassRandomAbilityDeck> RandomAbilityDecks;
	local SoldierClassRandomAbilityDeck RandomDeck;
	local array<SoldierClassAbilitySlot> AllAbilitySlots;
	local SoldierClassAbilitySlot AbilitySlot;
	local SoldierClassAbilityType EmptyAbility;
	local int RankIndex, SlotIndex, DeckIndex;

	ClassTemplate = UnitState.GetSoldierClassTemplate();

	// Reset everything above squaddie
	UnitState.AbilityTree.Length = 1;
	
	if(ClassTemplate != none)
	{
		// Grab random ability decks
		RandomAbilityDecks = ClassTemplate.RandomAbilityDecks;
		// Go rank by rank, filling in our tree
		for(RankIndex = 1; RankIndex < ClassTemplate.GetMaxConfiguredRank(); RankIndex++)
		{
			RankAbilities = EmptyRankAbilities;
			AllAbilitySlots = ClassTemplate.GetAbilitySlots(RankIndex);

			// Determine ability (or lack thereof) from each slot
			for(SlotIndex = 0; SlotIndex < AllAbilitySlots.Length; SlotIndex++)
			{
				if (SpecIndices.Find(SlotIndex) == INDEX_NONE)
				{
					continue;
				}

				AbilitySlot = AllAbilitySlots[SlotIndex];

				// First check for random ability from deck
				// Do not give random abilities to units in Skirmish Mode
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
						`RedScreen("Random ability deck" @ string(AbilitySlot.RandomDeckName) @ "not found. Probably a config error. @gameplay @mnauta");
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
			UnitState.AbilityTree.AddItem(RankAbilities);
		}
	}
	else
	{
		`RedScreen("Tried to build soldier ability tree without a set soldier class. @gameplay @mnauta");
	}
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
