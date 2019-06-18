//-----------------------------------------------------------
//	Class:	X2Effect_ConditionalModifyReactionFire
//	Author: Musashi
//	
//-----------------------------------------------------------
class X2Effect_ConditionalModifyReactionFire extends XMBEffect_ConditionalBonus;

var bool bAllowCrit;
var bool bOriginalAllowCrit;

var int ReactionModifier;
var int OriginalReactionModifier;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	bOriginalAllowCrit = bAllowCrit;
	OriginalReactionModifier = ReactionModifier;

	//`LOG(default.class @ GetFuncName() @ bAllowCrit @ ReactionModifier,, 'RPG');
}

function bool AllowReactionFireCrit(XComGameState_Unit UnitState, XComGameState_Unit TargetState) 
{ 
	//`LOG(default.class @ GetFuncName() @ bAllowCrit,, 'RPG');
	return bAllowCrit; 
}

function ModifyReactionFireSuccess(XComGameState_Unit UnitState, XComGameState_Unit TargetState, out int Modifier)
{
	//`LOG(default.class @ GetFuncName() @ ReactionModifier,, 'RPG');
	Modifier = ReactionModifier;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local XComGameState_Item				SourceWeapon;
	local X2AbilityToHitCalc_StandardAim	StandardToHit;

	SourceWeapon = AbilityState.GetSourceWeapon();
	if(SourceWeapon != none && SourceWeapon.ObjectID == EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
	{
		StandardToHit = X2AbilityToHitCalc_StandardAim(AbilityState.GetMyTemplate().AbilityToHitCalc);
		if (StandardToHit != none)
		{
			if (StandardToHit.bReactionFire && ValidateAttack(EffectState, Attacker, Target, AbilityState) == 'AA_Success')
			{
				bAllowCrit = bOriginalAllowCrit;
				ReactionModifier = OriginalReactionModifier;
				//`LOG(default.class @ GetFuncName() @ bAllowCrit @ ReactionModifier,, 'RPG');
			}
			else
			{
				bAllowCrit = false;
				ReactionModifier = 0;
				//`LOG(default.class @ GetFuncName() @ bAllowCrit @ ReactionModifier,, 'RPG');
			}
		}
	}
}
