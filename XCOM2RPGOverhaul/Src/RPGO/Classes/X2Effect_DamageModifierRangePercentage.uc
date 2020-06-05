class X2Effect_DamageModifierRangePercentage extends X2Effect_Persistent config (RPG);

//var array<int> DamageFalloff;
var array<float> DamageFalloff;
var config array<name> AbilityRemovesDamageFalloff;
var config array<name> AttackAbilityIgnoreDamageFalloff;
var config array<name> EffectRemovesDamageFalloff;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item WeaponState;
	local int Tiles, RangeDamageModifier;
	local name Ability, LocalEffectName;

	History = `XCOMHISTORY;

	if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		return 0;
	}

	foreach default.EffectRemovesDamageFalloff (LocalEffectName)
	{
		if (Attacker.AffectedByEffectNames.Find(LocalEffectName) != INDEX_NONE)
		{
			return 0;
		}
	}

	foreach default.AttackAbilityIgnoreDamageFalloff (Ability)
	{
		if (AbilityState.GetMyTemplateName() == Ability)
		{
			return 0;
		}
	}

	if (class'RPGO_Helper'.static.HasAnyOfTheAbilitiesFromAnySource(Attacker, default.AbilityRemovesDamageFalloff))
	{
		return 0;
	}

	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AppliedData.AbilityInputContext.PrimaryTarget.ObjectID));
	WeaponState = XComGameState_Item(History.GetGameStateForObjectID(AppliedData.ItemStateObjectRef.ObjectID));

	if (TargetUnit != none && WeaponState != none)
	{
		if (AbilityState.SourceWeapon.ObjectID != EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
			return 0;

		Tiles = Attacker.TileDistanceBetween(TargetUnit);
		RangeDamageModifier = int(CurrentDamage * DamageFalloff[Tiles]) * -1;			

		//`LOG(Class.Name @ GetFuncName() @ "Range Damage Modifier:" @ RangeDamageModifier,, 'RPG');

		if (CurrentDamage + RangeDamageModifier > 0)
		{
			return RangeDamageModifier; 
		}
		else
		{
			// minimum damage is 1
			return (CurrentDamage * -1) + 1;
		}
	}

	return 0;
}