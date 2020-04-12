//-----------------------------------------------------------
//	Class:	X2Effect_RemoveEffectAfterMove
//	Author: Musashi
//	
//-----------------------------------------------------------
class X2Effect_RemoveEffectAfterMove extends X2Effect_Persistent;

var array<name> EffectsToRemove;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Effect EffectStateToRemove;
	// Moving will cancel effects
	if (AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length > 0)
	{
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Effect', EffectStateToRemove)
		{
			if (EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == SourceUnit.ObjectID ||
				EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID == SourceUnit.ObjectID )
			{
				if (EffectsToRemove.Find(EffectStateToRemove.GetX2Effect().EffectName) != INDEX_NONE)
				{
					EffectStateToRemove.RemoveEffect(NewGameState, NewGameState, true);
				}
			}
		}
	}
	return false;
}