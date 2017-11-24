class UISL_UITacticalQuickLaunch_SquadLoadout extends UIScreenListener;


event OnInit(UIScreen Screen)
{
	local UIPanel Panel;

	if (UITacticalQuickLaunch_SquadLoadout(Screen) == none)
	{
		return;
	}

	//foreach UITacticalQuickLaunch_SquadLoadout(Screen).m_kSoldierList.ChildPanels(Panel)
	//{
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_CharacterTypeDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_SoldierRankDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_CharacterPoolDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_SoldierClassDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_SecondaryWeaponDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_HeavyWeaponDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_PrimaryWeaponDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_ArmorDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_GrenadeSlotDropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_UtilityItem1Dropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//	UITacticalQuickLaunch_UnitSlot(Panel).m_UtilityItem2Dropdown.MC.ChildSetNum("theListbox", "_height", 600);
	//}

	
}