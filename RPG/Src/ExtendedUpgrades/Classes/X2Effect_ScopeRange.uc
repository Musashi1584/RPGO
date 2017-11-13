class X2Effect_ScopeRange extends X2Effect_Persistent config(ExtendedUpgrades);

var config array<int> SHORT_LASER_RANGE;
var config array<int> MIDSHORT_LASER_RANGE;
var config array<int> MEDIUM_LASER_RANGE;
var config array<int> LONG_LASER_RANGE;
var config array<int> EXTREM_ALL_RANGE;

struct RangeTable
{
	var float RangeTier;
	var name TechCategory;
	var array<int> RangeTable;
};

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local int Tiles;
	local XComGameState_Item SourceWeapon;
	local ShotModifierInfo ShotInfo;
	local array<int> AimModifier;

	SourceWeapon = AbilityState.GetSourceWeapon();
	//`LOG("X2Effect_ScopeRange.GetToHitModifiers" @ SourceWeapon.ObjectID @ EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID,, 'ExtendedUpgrades');
	if(SourceWeapon != none && SourceWeapon.ObjectID == EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
	{
		AimModifier = GetRangeTableDiff(SourceWeapon);

		Tiles = Attacker.TileDistanceBetween(Target);
		if(AimModifier.Length > 0)
		{
			if(Tiles < AimModifier.Length)
			{
				ShotInfo.Value = AimModifier[Tiles];
			}
			else //Use last value
			{
				ShotInfo.Value = AimModifier[AimModifier.Length - 1];
			}

			`LOG("X2Effect_ScopeRange.GetToHitModifiers" @ SourceWeapon.GetMyTemplateName() @ "modifying range by" @ ShotInfo.Value,, 'ExtendedUpgrades');
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Reason = class'XLocalizedData'.default.WeaponRange;// FriendlyName;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}

function array<int> GetRangeTableDiff(XComGameState_Item SourceWeapon)
{
	local array<int> CurrentRangeTable, EmptyArray;
	local array<RangeTable> RangeTables;
	local RangeTable Table, NextTable;
	local bool bFound;

	CurrentRangeTable = X2WeaponTemplate(SourceWeapon.GetMyTemplate()).RangeAccuracy;
	RangeTables = GetRangeTables();
	EmptyArray.Length = 0;

	foreach RangeTables(Table)
	{
		if (ArrayEqual(Table.RangeTable, CurrentRangeTable))
		{
			bFound = true;
			break;
		}
	}

	if (bFound)
	{
		`LOG("Found range table" @ Table.RangeTier @ Table.TechCategory,, 'ExtendedUpgrades');

		NextTable = GetNextRangeTable(Table);

		`LOG("Next range table" @ NextTable.RangeTier @ NextTable.TechCategory,, 'ExtendedUpgrades');

		return GetDiff(Table.RangeTable, NextTable.RangeTable);
	}
	return EmptyArray;
}

function RangeTable GetNextRangeTable(RangeTable CurrentRangeTable)
{
	local array<RangeTable> RangeTables;
	local RangeTable Table;

	RangeTables = GetRangeTables();

	foreach RangeTables(Table)
	{
		if (Table.RangeTier > CurrentRangeTable.RangeTier &&
			Table.TechCategory == CurrentRangeTable.TechCategory)
		{
			return Table;
		}
	}
	return CurrentRangeTable;
}

function array<RangeTable> GetRangeTables()
{
	local array<RangeTable> RangeTables;
	local RangeTable Table;

	Table.RangeTier = 1.0f;
	Table.TechCategory = 'Conventional';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.SHORT_CONVENTIONAL_RANGE;
	RangeTables.AddItem(Table);
	
	Table.RangeTier = 2.0f;
	Table.TechCategory = 'Conventional';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.MEDIUM_CONVENTIONAL_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 3.0f;
	Table.TechCategory = 'Conventional';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.LONG_CONVENTIONAL_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 1.0f;
	Table.TechCategory = 'Magnetic';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.SHORT_MAGNETIC_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 2.0f;
	Table.TechCategory = 'Magnetic';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.MEDIUM_MAGNETIC_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 3.0f;
	Table.TechCategory = 'Magnetic';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.LONG_MAGNETIC_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 1.0f;
	Table.TechCategory = 'Beam';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.SHORT_BEAM_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 2.0f;
	Table.TechCategory = 'Beam';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.MEDIUM_BEAM_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 3.0f;
	Table.TechCategory = 'Beam';
	Table.RangeTable = class'X2Item_DefaultWeapons'.default.LONG_BEAM_RANGE;
	RangeTables.AddItem(Table);

	//if (class'X2Item_LaserWeapons' != none && class'TemplateHelper'.static.HasLaserWeapons())
	//{
	//	Table.RangeTier = 1.0f;
	//	Table.TechCategory = 'Laser';
	//	Table.RangeTable = class'X2Item_LaserWeapons'.default.SHORT_LASER_RANGE;
	//	RangeTables.AddItem(Table);
	//	`LOG("X2Item_LaserWeapons" @ Table.RangeTable.Length,, 'ExtendedUpgrades');
	//
	//	Table.RangeTier = 1.5f;
	//	Table.TechCategory = 'Laser';
	//	Table.RangeTable = class'X2Item_LaserWeapons'.default.MIDSHORT_LASER_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 2.0f;
	//	Table.TechCategory = 'Laser';
	//	Table.RangeTable = class'X2Item_LaserWeapons'.default.MEDIUM_LASER_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 3.0f;
	//	Table.TechCategory = 'Laser';
	//	Table.RangeTable = class'X2Item_LaserWeapons'.default.LONG_LASER_RANGE;
	//	RangeTables.AddItem(Table);
	//}
	//
	//if (class'X2Item_MercPlasmaWeapons' != none && class'TemplateHelper'.static.HasMercPlasmaWeapons())
	//{
	//	Table.RangeTier = 1.0f;
	//	Table.TechCategory = 'MercenaryPlasma';
	//	Table.RangeTable = class'X2Item_MercPlasmaWeapons'.default.PISTOL_MERCPLASMA_RANGE;
	//	RangeTables.AddItem(Table);
	//	`LOG("X2Item_MercPlasmaWeapons" @ Table.RangeTable.Length,, 'ExtendedUpgrades');
	//
	//	Table.RangeTier = 1.5f;
	//	Table.TechCategory = 'MercenaryPlasma';
	//	Table.RangeTable = class'X2Item_MercPlasmaWeapons'.default.SMG_MERCPLASMA_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 2.0f;
	//	Table.TechCategory = 'MercenaryPlasma';
	//	Table.RangeTable = class'X2Item_MercPlasmaWeapons'.default.ASSAULTRIFLE_MERCPLASMA_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 2.0f;
	//	Table.TechCategory = 'MercenaryPlasma';
	//	Table.RangeTable = class'X2Item_MercPlasmaWeapons'.default.CANNON_MERCPLASMA_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 2.0f;
	//	Table.TechCategory = 'MercenaryPlasma';
	//	Table.RangeTable = class'X2Item_MercPlasmaWeapons'.default.SPARKGUN_MERCPLASMA_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 3.0f;
	//	Table.TechCategory = 'MercenaryPlasma';
	//	Table.RangeTable = class'X2Item_MercPlasmaWeapons'.default.SNIPER_MERCPLASMA_RANGE;
	//	RangeTables.AddItem(Table);
	//}
	//
	//if (class'X2Item_Coilguns' != none && class'TemplateHelper'.static.HasCoilGuns())
	//{
	//	Table.RangeTier = 1.0f;
	//	Table.TechCategory = 'CoilGuns';
	//	Table.RangeTable = class'X2Item_Coilguns'.default.SHORT_COIL_RANGE;
	//	RangeTables.AddItem(Table);
	//	`LOG("X2Item_Coilguns" @ Table.RangeTable.Length,, 'ExtendedUpgrades');
	//
	//	Table.RangeTier = 1.5f;
	//	Table.TechCategory = 'CoilGuns';
	//	Table.RangeTable = class'X2Item_Coilguns'.default.MIDSHORT_COIL_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 2.0f;
	//	Table.TechCategory = 'CoilGuns';
	//	Table.RangeTable = class'X2Item_Coilguns'.default.MEDIUM_COIL_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 3.0f;
	//	Table.TechCategory = 'CoilGuns';
	//	Table.RangeTable = class'X2Item_Coilguns'.default.LONG_COIL_RANGE;
	//	RangeTables.AddItem(Table);
	//}
	//
	//if (class'X2Item_SMGWeapon' != none && class'TemplateHelper'.static.HasSMGWeapons())
	//{
	//	Table.RangeTier = 1.5f;
	//	Table.TechCategory = 'Conventional';
	//	Table.RangeTable = class'X2Item_SMGWeapon'.default.MIDSHORT_CONVENTIONAL_RANGE;
	//	RangeTables.AddItem(Table);
	//	`LOG("X2Item_SMGWeapon" @ Table.RangeTable.Length,, 'ExtendedUpgrades');
	//
	//	Table.RangeTier = 1.5f;
	//	Table.TechCategory = 'Magnetic';
	//	Table.RangeTable = class'X2Item_SMGWeapon'.default.MIDSHORT_MAGNETIC_RANGE;
	//	RangeTables.AddItem(Table);
	//
	//	Table.RangeTier = 1.5f;
	//	Table.TechCategory = 'Beam';
	//	Table.RangeTable = class'X2Item_SMGWeapon'.default.MIDSHORT_BEAM_RANGE;
	//	RangeTables.AddItem(Table);
	//}
	// New extrem range tables for sniper rifles with scopes
	Table.RangeTier = 4.0f;
	Table.TechCategory = 'Conventional';
	Table.RangeTable = default.EXTREM_ALL_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 4.0f;
	Table.TechCategory = 'Magnetic';
	Table.RangeTable = default.EXTREM_ALL_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 4.0f;
	Table.TechCategory = 'Beam';
	Table.RangeTable = default.EXTREM_ALL_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 4.0f;
	Table.TechCategory = 'Laser';
	Table.RangeTable = default.EXTREM_ALL_RANGE;
	RangeTables.AddItem(Table);

	Table.RangeTier = 4.0f;
	Table.TechCategory = 'MercenaryPlasma';
	Table.RangeTable = default.EXTREM_ALL_RANGE;
	RangeTables.AddItem(Table);

	return RangeTables;
}

function array<int> GetDiff(array<int> Array1, array<int> Array2)
{
	local array<int> Diff;
	local int Index;

	if (Array1.Length != Array2.Length)
		return Diff;

	for(Index = 0; Index < Array2.Length; Index++)
	{
		Diff[Index] = Array2[Index] - Array1[Index];
		//`LOG("Range table diff" @ Diff[Index],, 'ExtendedUpgrades');
	}

	return Diff;
}

function bool ArrayEqual(array<int> Array1, array<int> Array2)
{
	local int Index;

	if (Array1.Length != Array2.Length)
		return false;

	for(Index = 0; Index < Array2.Length; Index++)
	{
		if (Array1[Index] != Array2[Index])
			return false;
	}

	return true;
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="X2Effect_ScopeRange"
}