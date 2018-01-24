class X2Effect_Augmentations_GrantActionPoints extends X2Effect_Persistent;

var array<name> ActionPoints;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit			UnitState;
	local name							ActionPoint;
	
	UnitState = XComGameState_Unit(kNewTargetState);

	if (UnitState != none)
	{
		UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
		
		foreach ActionPoints(ActionPoint)
		{
			UnitState.ActionPoints.AddItem(ActionPoint); // class'X2CharacterTemplateManager'.default.StandardActionPoint

			NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID);
			NewGameState.ModifyStateObject(class'XComGameState_Ability', ApplyEffectParameters.AbilityStateObjectRef.ObjectID);

			`LOG(self.Class.name @ "added" @ ActionPoint,, 'Augmentations');
		}
	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}