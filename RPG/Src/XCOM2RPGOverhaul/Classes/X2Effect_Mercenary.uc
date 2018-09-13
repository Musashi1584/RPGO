class X2Effect_Mercenary extends X2Effect_Persistent;

var int Cap;
var int Factor;
var bool bSupplies, bIntel;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local XComGameStateHistory History;
	local ShotModifierInfo					CritInfo;
	local XComGameState_HeadquartersXCom	XComHQ;
	local int								Supplies, Intel, CritBonus;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));

	Supplies = XComHQ.GetSupplies();
	Intel = XComHQ.GetIntel();

	if(bSupplies)
		CritBonus = Supplies/Factor;
	else if(bIntel)
		CritBonus = Intel/Factor;

	if(CritBonus > Cap)
		CritBonus = Cap;

	CritInfo.ModType = eHit_Crit;
	CritInfo.Reason = FriendlyName;
	CritInfo.Value = CritBonus;
	ShotModifiers.AddItem(CritInfo);
}
