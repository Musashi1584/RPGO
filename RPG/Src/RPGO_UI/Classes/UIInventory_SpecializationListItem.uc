class UIInventory_SpecializationListItem extends UIInventory_CommodityListItem;

var int InitPosX;
var int InitPosY;
var int IconSize;
var UIAbilityIconRow AbilityIconRow;

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	local UIPanel Panel;
	
	Panel = super.InitPanel(InitName, InitLibID);

	RealizeSpecializationsIcons();

	return Panel;
}

simulated function RealizeSpecializationsIcons()
{
	local array<X2AbilityTemplate> Templates;
	
	Templates = GetSpecializationAbilities();

	ConfirmButton.SetY(InitPosY);

	AbilityIconRow = Spawn(class'UIAbilityIconRow', self);
	AbilityIconRow.PopulateIcons(Templates, IconSize);
	AbilityIconRow.SetPosition(InitPosX, InitPosY);
}

simulated function array<X2AbilityTemplate> GetSpecializationAbilities()
{
	local UIChooseSpecializations ParentScreen;
	local SoldierSpecialization Spec;
	local array<X2AbilityTemplate> EmptyList;

	List = UIList(GetParent(class'UIList'));
	ParentScreen = UIChooseSpecializations(self.List.ParentPanel);

	if (List != none && ParentScreen != none)
	{
		Spec = ParentScreen.SpecializationsPool[ParentScreen.GetItemIndex(ItemComodity)];

		return class'X2SoldierClassTemplatePlugin'.static.GetAbilityTemplatesForSpecializations(Spec);
	}

	EmptyList.Length = 0;
	return EmptyList;
}

defaultproperties
{
	InitPosX = -3
	InitPosY = 146
	IconSize = 38
	Height = 196
}
