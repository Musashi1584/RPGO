class X2Effect_EquipmentStatCaps extends X2Effect_CapStat config (RPG);

var array<EquipmentStatCap> EquipmentStatCaps;
// If true only the highest cap will be used
var bool bUseMaxCap;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local array<XComGameState_Item> Items;
	local XComGameState_Item Item;
	local int EquipmentStatCapIndex;

	UnitState = XComGameState_Unit(kNewTargetState);

	Items = UnitState.GetAllInventoryItems();

	foreach Items(Item)
	{
		EquipmentStatCapIndex = EquipmentStatCaps.Find('TemplateName', Item.GetMyTemplateName());
		if (EquipmentStatCapIndex != INDEX_NONE)
		{
			AddCap(EquipmentStatCaps[EquipmentStatCapIndex].Cap);
			continue;
		}

		EquipmentStatCapIndex = EquipmentStatCaps.Find('WeaponCategoryName', X2WeaponTemplate(Item.GetMyTemplate()).WeaponCat);
		if (EquipmentStatCapIndex != INDEX_NONE)
		{
			AddCap(EquipmentStatCaps[EquipmentStatCapIndex].Cap);
			continue;
		}

		EquipmentStatCapIndex = EquipmentStatCaps.Find('ItemCategoryName', Item.GetMyTemplate().ItemCat);
		if (EquipmentStatCapIndex != INDEX_NONE)
		{
			AddCap(EquipmentStatCaps[EquipmentStatCapIndex].Cap);
			continue;
		}

		EquipmentStatCapIndex = EquipmentStatCaps.Find('ArmorClass', X2ArmorTemplate(Item.GetMyTemplate()).ArmorClass);
		if (EquipmentStatCapIndex != INDEX_NONE)
		{
			AddCap(EquipmentStatCaps[EquipmentStatCapIndex].Cap);
			continue;
		}
	}
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}


public function AddCap(StatCap Cap)
{
	local int Index;

	Index = m_aStatCaps.Find('StatType', Cap.StatType);

	if (Index != INDEX_NONE)
	{
		m_aStatCaps[Index].StatCapValue = Max(m_aStatCaps[Index].StatCapValue, Cap.StatCapValue);
		//`LOG(default.class @ GetFuncName() @ Cap.StatType @ Cap.StatCapValue @ m_aStatCaps[Index].StatCapValue);
	}
	else
	{
		m_aStatCaps.AddItem(Cap);
	}
}
