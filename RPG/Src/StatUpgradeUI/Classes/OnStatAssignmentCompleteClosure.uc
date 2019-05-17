class OnStatAssignmentCompleteClosure extends Object dependson (DataStructure_StatUpgradeUI);

var public delegate<X2CharacterTemplate.OnStatAssignmentComplete> OnStatAssignmentCompleteOriginalFn;

public function OnStatAssignmentCompleteFn(XComGameState_Unit UnitState)
{
	local ENaturalAptitude Apt;
	
	if (OnStatAssignmentCompleteOriginalFn != none)
	{
		//`LOG(default.Class @ GetFuncName() @ "calling original delegate" @ OnStatAssignmentCompleteOriginalFn,, 'RPG');
		OnStatAssignmentCompleteOriginalFn(UnitState);
	}
	
	Apt = class'StatUIHelper'.static.RollNaturalAptitude();
	
	//`LOG(default.Class @ GetFuncName() @ Apt @ float(Apt),, 'RPG');
	UnitState.SetUnitFloatValue('NaturalAptitude', float(Apt), eCleanUp_Never);	
}