class X2Effect_EquipmentStatCaps extends X2Effect_CapStat dependson(RPGO_DataStructures) config (RPG);

// If true only the highest cap will be used
var bool bUseMaxCap;
var array<EquipmentStatCap> EquipmentStatCaps;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local array<XComGameState_Item> Items;
	local XComGameState_Item Item;
	local EquipmentStatCap EquipmentCap;
	local X2WeaponTemplate WeaponTemplate;
	local X2ArmorTemplate ArmorTemplate;
	local XComGameState_Effect_CapStats EffectState;

	UnitState = XComGameState_Unit(kNewTargetState);
	Items = UnitState.GetAllInventoryItems();

	EffectState = XComGameState_Effect_CapStats(NewEffectState);

	foreach EquipmentStatCaps(EquipmentCap)
	{
		foreach Items(Item)
		{
			WeaponTemplate = X2WeaponTemplate(Item.GetMyTemplate());
			ArmorTemplate = X2ArmorTemplate(Item.GetMyTemplate());

			if (Item.GetMyTemplateName() == EquipmentCap.TemplateName  ||
				(WeaponTemplate != none && WeaponTemplate.WeaponCat == EquipmentCap.WeaponCategoryName) ||
				(Item.GetMyTemplate().ItemCat == EquipmentCap.ItemCategoryName) ||
				(ArmorTemplate != none && ArmorTemplate.ArmorClass == EquipmentCap.ArmorClass)
			)
			{
				EffectState.AddCap(EquipmentCap.Cap, bUseMaxCap);
			}
		}
	}
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}
