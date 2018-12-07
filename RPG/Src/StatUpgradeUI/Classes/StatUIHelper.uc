class StatUIHelper extends Object config(StatUpgradeUI);

enum ENaturalAptitude
{
	eNaturalAptitude_Standard,
	eNaturalAptitude_AboveAverage,
	eNaturalAptitude_Gifted,
	eNaturalAptitude_Genius,
	eNaturalAptitude_Savant,
};

var config array<name> NaturalAptitudeCharacterTemplates;
var config array<int> NaturalAptitudeThresholds;
var config int NaturalAptitudeAboveAverageChance;
var config array<ENaturalAptitude> BaseSoldierNaturalAptitude;

var localized string NaturalAptitudeLabel[ENaturalAptitude.EnumCount]<BoundEnum = ENaturalAptitude>;
var localized string NaturalAptitude;


static function OnPostCharacterTemplatesCreated()
{
	local X2CharacterTemplateManager CharacterTemplateMgr;
	local X2CharacterTemplate SoldierTemplate;
	local array<X2DataTemplate> DataTemplates;
	local int ScanTemplates, ScanAdditions;
	local OnStatAssignmentCompleteClosure DelegateClosure;

	CharacterTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	
	for ( ScanAdditions = 0; ScanAdditions < default.NaturalAptitudeCharacterTemplates.Length; ++ScanAdditions )
	{
		CharacterTemplateMgr.FindDataTemplateAllDifficulties(default.NaturalAptitudeCharacterTemplates[ScanAdditions], DataTemplates);
		for (ScanTemplates = 0; ScanTemplates < DataTemplates.Length; ++ScanTemplates)
		{
			SoldierTemplate = X2CharacterTemplate(DataTemplates[ScanTemplates]);
			if (SoldierTemplate != none)
			{
				DelegateClosure = new class'OnStatAssignmentCompleteClosure';
				DelegateClosure.OnStatAssignmentCompleteOriginalFn = SoldierTemplate.OnStatAssignmentCompleteFn;
				SoldierTemplate.OnStatAssignmentCompleteFn = DelegateClosure.OnStatAssignmentCompleteFn;
			}
		}
	}
}

static function int GetBonusStatPointsFromNaturalAptitude(XComGameState_Unit UnitState)
{
	//`LOG(default.Class @ GetFuncName() @ default.BaseSoldierNaturalAptitude[GetNaturalAptitude(UnitState)],, 'RPG');
	return default.BaseSoldierNaturalAptitude[GetNaturalAptitude(UnitState)];
}

static function ENaturalAptitude GetNaturalAptitude(XComGameState_Unit UnitState)
{
	local UnitValue NaturalAptitudeValue;
	
	UnitState.GetUnitValue('NaturalAptitude', NaturalAptitudeValue);

	//`LOG(default.Class @ GetFuncName() @ NaturalAptitudeValue.fValue @ GetEnum(Enum'ENaturalAptitude', NaturalAptitudeValue.fValue),, 'RPG');
	
	return ENaturalAptitude(NaturalAptitudeValue.fValue);
}

static function SetNaturalAptitude(XComGameState_Unit UnitState, ENaturalAptitude NewNaturalAptitude)
{
	UnitState.SetUnitFloatValue('NaturalAptitude', float(NewNaturalAptitude), eCleanUp_Never);	
}

static function ENaturalAptitude RollNaturalAptitude()
{
	local array<int> Thresholds;
	local int idx, NaturalAptitudeRoll;
	
	if (class'X2StrategyGameRulesetDataStructures'.static.Roll(default.NaturalAptitudeAboveAverageChance))
	{
		Thresholds = default.NaturalAptitudeThresholds;
		NaturalAptitudeRoll = `SYNC_RAND_STATIC(100);
		
		for (idx = 0; idx < Thresholds.Length; idx++)
		{
			if (NaturalAptitudeRoll < Thresholds[idx])
			{
				return ENaturalAptitude(1 + idx);
				break;
			}
		}
	}
	
	return eNaturalAptitude_Standard;
}

static function string GetNaturalAptitudeLabel(ENaturalAptitude NatApt)
{
	//`LOG(default.Class @ GetFuncName() @ NatApt @ default.NaturalAptitudeLabel[NatApt] @ default.NaturalAptitudeLabel[eNaturalAptitude_Standard],, 'RPGO');
	return default.NaturalAptitudeLabel[NatApt];
}

static function int GetSoldierSP(XComGameState_Unit UnitState)
{
	local UnitValue StatPointsValue;
	UnitState.GetUnitValue('StatPoints', StatPointsValue);
	return int(StatPointsValue.fValue);
}

static function SetSoldierSP(XComGameState_Unit UnitState, int StatPoints)
{
	UnitState.SetUnitFloatValue('StatPoints', float(StatPoints), eCleanUp_Never);
}

// Improves the NaturalAptitude by one and retroactivly provide SP as if the soldier had the higher NaturalAptitude the entire time 
static function ImproveNaturalAptitude(XComGameState_Unit UnitState)
{
	local int iRank, SPIncrease;
	local ENaturalAptitude CurrentNaturalAptitude;

	CurrentNaturalAptitude = GetNaturalAptitude(UnitState);

	// First improve Natural Aptitude to the next rank
	if (CurrentNaturalAptitude < eNaturalAptitude_Savant)
	{
		SetNaturalAptitude(UnitState, ENaturalAptitude(CurrentNaturalAptitude + 1));
	}

	// Provide additional SP as if the soldier had the higher NaturalAptitude the entire time
	for (iRank = UnitState.GetSoldierRank(); iRank >= 2; iRank--)
	{

		SPIncrease += (default.BaseSoldierNaturalAptitude[CurrentNaturalAptitude + 1] - default.BaseSoldierNaturalAptitude[CurrentNaturalAptitude]);
	}

	SetSoldierSP(UnitState, GetSoldierSP(UnitState) + Round(SPIncrease));
}