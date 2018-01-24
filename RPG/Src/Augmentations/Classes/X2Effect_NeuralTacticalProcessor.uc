class X2Effect_NeuralTacticalProcessor extends X2Effect_Persistent;

var int BonusPerViewer;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local int SquadmateViewers;
	local ShotModifierInfo ModInfo;

	SquadmateViewers = class'X2TacticalVisibilityHelpers'.static.GetNumEnemyViewersOfTarget(Target.ObjectID);

	if (SquadmateViewers > 1)
	{
		ModInfo.ModType = eHit_Success;
		ModInfo.Value = BonusPerViewer * (SquadmateViewers - 1);
		ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ModInfo);
	}
}