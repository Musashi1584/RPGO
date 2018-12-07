class X2DownloadableContentInfo_StatUpgradeUI extends X2DownloadableContentInfo;

// Error Messages
var localized string	strNoUnitSelected;
var localized string	strClassNotFound;
var localized string	strIncorrectCharacterTemplate;
var localized string	strIncorrectRankValue;
var localized string	strCantRespecRookie;
var localized string	strInvalidCombatInt;
var localized string	strNoValidUnit;
// Success Messages
var localized string	strRankSet;
var localized string	strClassSet;
var localized string	strComIntSet;
// Note Messages
var localized string	strCappingRank;

static event OnPostTemplatesCreated()
{
	class'StatUIHelper'.static.OnPostCharacterTemplatesCreated();
}

// 	0 = eComInt_Standard,
// 	1 = eComInt_AboveAverage,e,
// 	2 = eComInt_Gifted,
// 	3 = eComInt_Genius,
// 	4 = eComInt_Savant,
exec function RPGO_SetCombatIntelligence(int NewComInt)
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local XComGameState						NewGameState;
	local int								OldComInt, Index;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_SetCombatIntelligence");

	Armory = GetArmory();
	UnitState = GetSelectedUnit();

	if (UnitState == none || Armory == none)
		return;

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

	OldComInt = UnitState.ComInt;

	// Retroactively give AP if combat intelligence was improved
	if (OldComInt < NewComInt)
	{
		for (Index = 0; Index < (NewComInt - OldComInt); Index++)
		{
			UnitState.ImproveCombatIntelligence();
		}
	}

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
	
	Armory.PopulateData();
}


// 0 = eNaturalAptitude_Standard,
// 1 = eNaturalAptitude_AboveAverage,
// 2 = eNaturalAptitude_Gifted,
// 3 = eNaturalAptitude_Genius,
// 4 = eNaturalAptitude_Savant,
exec function RPGO_SetNaturalAptitude(int NewNaturalAptitude)
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local XComGameState						NewGameState;
	local int								OldNaturalAptitude, Index;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_SetNaturalAptitude");

	Armory = GetArmory();
	UnitState = GetSelectedUnit();

	if (UnitState == none || Armory == none)
		return;

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	OldNaturalAptitude = int(class'StatUIHelper'.static.GetNaturalAptitude(UnitState));

	// Retroactively give SP if natural aptitude was improved
	if (OldNaturalAptitude < NewNaturalAptitude)
	{
		for (Index = 0; Index < (NewNaturalAptitude - OldNaturalAptitude); Index++)
		{
			class'StatUIHelper'.static.ImproveNaturalAptitude(UnitState);
		}
	}

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
	
	Armory.PopulateData();
}

exec function RPGO_GiveAbiltiyPoints(int AbilitsPoints)
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local XComGameState						NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_GiveAbiltiyPoints");

	Armory = GetArmory();
	UnitState = GetSelectedUnit();

	if (UnitState == none || Armory == none)
		return;

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

	UnitState.AbilityPoints += AbilityPoints;

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
	
	Armory.PopulateData();
}

exec function RPGO_GiveStatPoints(int StatPoints)
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local XComGameState						NewGameState;
	local int								CurrentSP;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_SetNaturalAptitude");

	Armory = GetArmory();
	UnitState = GetSelectedUnit();

	if (UnitState == none || Armory == none)
		return;

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

	CurrentSP = class'StatUIHelper'.static.GetSoldierSP(UnitState);

	UnitState.SetUnitFloatValue('StatPoints', float(CurrentSP + StatPoints), eCleanUp_Never);

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
	
	Armory.PopulateData();
}

exec function RPGO_AssignSquaddieAbilities(optional name OPTIONAL_Ability1 = '', optional name OPTIONAL_Ability2 = '', optional name OPTIONAL_Ability3 = '', optional name OPTIONAL_Ability4 = '')
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local XComGameState						NewGameState;
	local int								i;
	local array<SCATProgression>			SoldierProgressionAbilties;
	local SCATProgression					AbilityProgression;
	local SoldierClassAbilityType			AbilityType;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_AssignSquaddieAbilities");

	Armory = GetArmory();
	UnitState = GetSelectedUnit();

	if (UnitState == none || Armory == none)
		return;

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

	UnitState.AbilityTree[0].Abilities.Length = 0;

	// Reset the squaddie abilities
	SoldierProgressionAbilties = UnitState.m_SoldierProgressionAbilties;
	for (i = SoldierProgressionAbilties.Length; i >= 0; i--)
	{
		`LOG("Rank:" @ SoldierProgressionAbilties[i].iRank @ "Branch:" @ SoldierProgressionAbilties[i].iBranch,, 'RPG');
		`LOG("------------------------------------------------------------------------------------------",, 'RPG');
		if (SoldierProgressionAbilties[i].iRank == 0)
		{
			SoldierProgressionAbilties.Remove(i, 1);
		}
	}

	UnitState.SetSoldierProgression(SoldierProgressionAbilties);

	// Assign the new abilities
	if (OPTIONAL_Ability1 != '' && ValidateAbility(OPTIONAL_Ability1))
	{
		AbilityType.AbilityName = OPTIONAL_Ability1;
		UnitState.AbilityTree[0].Abilities.Additem(AbilityType);

		AbilityProgression = UnitState.GetSCATProgressionForAbility(OPTIONAL_Ability1);

		`LOG("Buy new squaddie ability" @ OPTIONAL_Ability1 @ "Rank:" @ AbilityProgression.iRank @ "Branch:" @ AbilityProgression.iBranch,, 'RPG');

		UnitState.BuySoldierProgressionAbility(NewGameState, AbilityProgression.iRank, AbilityProgression.iBranch);
	}
	
	if (OPTIONAL_Ability2 != '' && ValidateAbility(OPTIONAL_Ability2))
	{
		AbilityType.AbilityName = OPTIONAL_Ability2;
		UnitState.AbilityTree[0].Abilities.Additem(AbilityType);

		AbilityProgression = UnitState.GetSCATProgressionForAbility(OPTIONAL_Ability2);
		UnitState.BuySoldierProgressionAbility(NewGameState, AbilityProgression.iRank, AbilityProgression.iBranch);
	}

	if (OPTIONAL_Ability3 != '' && ValidateAbility(OPTIONAL_Ability3))
	{
		AbilityType.AbilityName = OPTIONAL_Ability3;
		UnitState.AbilityTree[0].Abilities.Additem(AbilityType);

		AbilityProgression = UnitState.GetSCATProgressionForAbility(OPTIONAL_Ability3);
		UnitState.BuySoldierProgressionAbility(NewGameState, AbilityProgression.iRank, AbilityProgression.iBranch);
	}

	if (OPTIONAL_Ability4 != '' && ValidateAbility(OPTIONAL_Ability4))
	{
		AbilityType.AbilityName = OPTIONAL_Ability4;
		UnitState.AbilityTree[0].Abilities.Additem(AbilityType);

		AbilityProgression = UnitState.GetSCATProgressionForAbility(OPTIONAL_Ability4);
		UnitState.BuySoldierProgressionAbility(NewGameState, AbilityProgression.iRank, AbilityProgression.iBranch);
	}

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
	
	Armory.PopulateData();
}

// Refresh a soldier's ability tree and XCOM abilities from the armory screen, with the option to
// change their class and rank. Specifiying a class for a rookie will rank them up to Squaddie.
// Like the Training Center respec, you will lose any XCOM AP spent, but not soldier AP.
exec function RPGO_RebuildSelectedSoldiersClass(optional name OPTIONAL_ChangeClassTo = '', optional int OPTIONAL_SetRankTo = 0)
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local XComGameState						NewGameState;
	local XComGameState_HeadquartersXCom	XComHQ;
	local X2SoldierClassTemplateManager		ClassTemplateManager;
	local X2SoldierClassTemplate			ClassTemplate;
	local name								ClassName;
	local bool								bChangeClass;
	local int								i, NumRanks, iXP;
	
	History = `XCOMHISTORY;

	Armory = GetArmory();
	UnitState = GetSelectedUnit();

	if (UnitState == none || Armory == none)
		return;
	
	ClassName = UnitState.GetSoldierClassTemplateName();
	ClassTemplateManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	if (OPTIONAL_ChangeClassTo != '')
	{
		if (OPTIONAL_ChangeClassTo == 'Random')
		{
			class'Helpers'.static.OutputMsg(Repl(default.strClassSet, "'<ClassName/>'", OPTIONAL_ChangeClassTo));
			ClassName = OPTIONAL_ChangeClassTo;
			bChangeClass = true;
		}
		else
		{
			ClassTemplate = ClassTemplateManager.FindSoldierClassTemplate(OPTIONAL_ChangeClassTo);
			if (ClassTemplate == none)
			{
				class'Helpers'.static.OutputMsg(Repl(default.strClassNotFound, "<ClassName/>", OPTIONAL_ChangeClassTo));
			}
			else if (ClassTemplate.AcceptedCharacterTemplates.Length != 0 && ClassTemplate.AcceptedCharacterTemplates.Find(UnitState.GetSoldierClassTemplateName()) == Index_None)
			{
				class'Helpers'.static.OutputMsg(Repl(default.strIncorrectCharacterTemplate, "<ClassName/>", OPTIONAL_ChangeClassTo));
			}
			else
			{
				class'Helpers'.static.OutputMsg(Repl(default.strClassSet, "<ClassName/>", OPTIONAL_ChangeClassTo));
				ClassName = OPTIONAL_ChangeClassTo;
				bChangeClass = true;
	}	}	}
	
	if (OPTIONAL_SetRankTo < 0)
	{
		class'Helpers'.static.OutputMsg(default.strIncorrectRankValue);
	}

	NumRanks = UnitState.GetRank();
	if (OPTIONAL_SetRankTo > 0)
	{
		NumRanks = OPTIONAL_SetRankTo;
		if (NumRanks > class'X2ExperienceConfig'.static.GetMaxRank())
		{
			class'Helpers'.static.OutputMsg(default.strCappingRank);
			NumRanks = class'X2ExperienceConfig'.static.GetMaxRank();
		}
			
		class'Helpers'.static.OutputMsg(Repl(default.strRankSet, "<RankLevel/>", NumRanks));
	}
	
	// If the UnitState is a rookie and the class is being set, rank them up to 1, otherwise exit (can't respec a rookie)
	if (NumRanks == 0)
	{
		if (bChangeClass)
		{
			NumRanks = 1;
		}
		else
		{
			class'Helpers'.static.OutputMsg(default.strCantRespecRookie);
			return;
	}	}
	
	iXP = UnitState.GetXPValue();
	iXP -= class'X2ExperienceConfig'.static.GetRequiredXp(NumRanks);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Respec Soldier");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	
	if (ClassName == 'Random' || ClassName == 'Rookie')
	{
		ClassName = XComHQ.SelectNextSoldierClass();
	}

	UnitState.SetUnitFloatValue('StatPoints', 0, eCleanup_Never);
	UnitState.SetUnitFloatValue('SpentStatPoints', 0, eCleanup_Never);

	UnitState.AbilityPoints = 0; // Reset Ability Points
	UnitState.SpentAbilityPoints = 0; // And reset the spent AP tracker
	UnitState.ResetSoldierRank(); // Clear their rank
	UnitState.ResetSoldierAbilities(); // Clear their current abilities
	for (i = 0; i < NumRanks; ++i) // Rank soldier back up to previous level
	{
		UnitState.RankUpSoldier(NewGameState, ClassName);
	}
	UnitState.ApplySquaddieLoadout(NewGameState, XComHQ);

	// Reapply Stat Modifiers (Beta Strike HP, etc.)
	UnitState.bEverAppliedFirstTimeStatModifiers = false;
	if (UnitState.GetMyTemplate().OnStatAssignmentCompleteFn != none)
	{
		UnitState.GetMyTemplate().OnStatAssignmentCompleteFn(UnitState);
	}
	UnitState.ApplyFirstTimeStatModifiers();

	// Restore any partial XP the soldier had
	if (iXP > 0)
	{
		UnitState.AddXp(iXP);
	}

	// Skip AWC for classes that are excluded (the RollForTrainingCenterAbilities function does no such checks internally)
	if (class'CHHelpers'.default.ClassesExcludedFromAWCRoll.Find(ClassName) == Index_None || !UnitState.GetSoldierClassTemplate().bAllowAWCAbilities)
	{
		UnitState.bRolledForAWCAbility = false;
		UnitState.RollForTrainingCenterAbilities(); // Reroll XCOM abilities
	}

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

	Armory.PopulateData();
}

private function UIArmory GetArmory()
{
	local UIArmory Armory;

	Armory = UIArmory(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory'));

	if (Armory == none)
	{
		class'Helpers'.static.OutputMsg(default.strNoUnitSelected);
	}

	return Armory;
}

private function XComGameState_Unit GetSelectedUnit()
{
	local XComGameStateHistory				History;
	local UIArmory							Armory;
	local XComGameState_Unit				UnitState;
	local StateObjectReference				UnitRef;

	History = `XCOMHISTORY;

	Armory = UIArmory(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory'));
	if (Armory == none)
	{
		class'Helpers'.static.OutputMsg(default.strNoUnitSelected);
		return none;
	}

	UnitRef = Armory.GetUnitRef();
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

	if (UnitState == none)
	{
		class'Helpers'.static.OutputMsg(default.strNoUnitSelected);
	}

	return UnitState;
}

private function bool ValidateAbility(name AbilityName)
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate(AbilityName);

	return (Template != none);
}


exec function DebugStatUIHeader(
	int StatNameHeaderWidth,
	int StatValueHeaderWidth,
	int UpgradePointsHeaderWidth,
	int StatCostHeaderWidth,
	int UpgradeCostHeaderWidth
)
{
	local UIScreen_StatUI UI;
	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));
	UI.InitStatHeaders(StatNameHeaderWidth, StatValueHeaderWidth, UpgradePointsHeaderWidth, StatCostHeaderWidth, UpgradeCostHeaderWidth);
}

exec function DebugStatUI(
	int OffsetY = 100,
	int RowHeight = 30,
	int StatNameWidth = 260,
	int StatValueTextWidth = 100,
	int UpgradePointsWidth = 100,
	int ButtonWidth = 150,
	int StatCostTextWidth = 200,
	int UpgradeCostSumWidth = 140)
{
	local UIScreen_StatUI UI;
	local UIPanel_StatUI_StatLine StatLine;
	local int Index, OffsetX;

	UI = UIScreen_StatUI(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_StatUI'));
	
	Index = 0;
	foreach UI.StatLines(StatLine)
	{
		OffsetX = 40;
		StatLine.InitChildPanels(UI.MCName, StatNameWidth, StatValueTextWidth, UpgradePointsWidth, ButtonWidth, StatCostTextWidth, UpgradeCostSumWidth);
		StatLine.SetPosition(OffsetX, OffsetY + (RowHeight * Index));
		
		`LOG(self.class.name @ GetFuncName() @ StatLine.MCName, , 'RPG');
		Index++;
	}
}

// Testing non linear stat progression
//static event OnPostTemplatesCreated()
//{
//	local int i;
//	local float div, f, res;
//
//	for (i=0;i<=150;i++)
//	{
//		f = float(i) / float(100);
//		res = Exp(Pow(f, 6)) * 3;
//		`LOG(GetFuncName() @ i @ res @ int(res + 0.5f),, 'RPG');
//	}
//}
//
//static function float Pow(Float Base, int Exponent)
//{
//	local int i;
//	local float Result;
//	
//	Result = Base;
//	
//	for(i=1; i <= Exponent; i++)
//	{
//		Result *= Base;
//	}
//	return Result;
//}