class X2Effect_Speed extends X2Effect_Persistent config (Augmentations);

var config float SpeedGameSpeedMutliplier;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kNewTargetState);
	XComHumanPawn(XGUnit(UnitState.GetVisualizer()).GetPawn()).Mesh.GlobalAnimRateScale = default.SpeedGameSpeedMutliplier;
	XComHumanPawn(XGUnit(UnitState.GetVisualizer()).GetPawn()).Mesh.bPerBoneMotionBlur = true;
	`LOG("X2Effect_Speed.OnEffectAdded" @ class'X2Effect_Speed'.default.SpeedGameSpeedMutliplier @ "active ForceSpeed on" @ XComGameState_Unit(kNewTargetState).GetFullName(),, 'Augmentations');
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	`LOG("X2Effect_Speed.OnEffectRemoved SetGameSpeed 1",, 'Augmentations');
	XComHumanPawn(XGUnit(UnitState.GetVisualizer()).GetPawn()).Mesh.GlobalAnimRateScale = 1;
	XComHumanPawn(XGUnit(UnitState.GetVisualizer()).GetPawn()).Mesh.bPerBoneMotionBlur = false;
}

DefaultProperties
{
	EffectName = "ForceSpeed"
}