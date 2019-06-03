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
	AbilityIconRow.InitAbilityIconRowPanel('SpecIconRow',, IconSize, Templates);
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


simulated function PopulateData(optional bool bRealizeDisabled)
{
	MC.BeginFunctionOp("populateData");
	MC.QueueString(ItemComodity.Image);
	MC.QueueString(GetColoredText(ItemComodity.Title));
	if (ItemComodity.OrderHours > -1)
	{
		MC.QueueString(class'UIUtilities_text'.static.GetTimeRemainingString(ItemComodity.OrderHours));
	}
	else
	{
		MC.QueueString("");
	}
	MC.QueueString(GetColoredText(ItemComodity.Desc));
	MC.EndOp();

	if(bRealizeDisabled)
		RealizeDisabledState();

	AS_SetComplemetaryItemColor();
}

simulated function AS_SetComplemetaryItemColor()
{
	local string ComplemetaryItemColor;

	ComplemetaryItemColor = GetColor();

	if (ComplemetaryItemColor != "")
	{
		AS_SetMCColor(MCPath $ ".titleMC", ComplemetaryItemColor);
		AS_SetMCColor(MCPath $ ".descriptionMC", ComplemetaryItemColor);
	}
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	
	// use timer to trigger after flashs onLoseFocus()
	Screen.SetTimer(0.01f, false, nameof(AS_SetComplemetaryItemColor), self);
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	// use timer to trigger after flashs onReceiveFocus()
	Screen.SetTimer(0.01f, false, nameof(AS_SetComplemetaryItemColor), self);
}

simulated function string GetColoredText(string Txt, optional int FontSize = -1)
{
	local UIChooseSpecializations ParentScreen;
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo Template;

	List = UIList(GetParent(class'UIList'));
	ParentScreen = UIChooseSpecializations(self.List.ParentPanel);

	if (List != none && ParentScreen != none)
	{
		Spec = ParentScreen.SpecializationsPool[ParentScreen.GetItemIndex(ItemComodity)];
		Template = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplate(Spec);
		if (Template.ForceComplementarySpecializations.Length > 0)
		{
			if (FontSize != INDEX_NONE)
			{
				return class'UIUtilities_Text'.static.GetSizedText(GetColoredComplementarySpec(Txt, Template), FontSize);
			}
			else
			{
				return GetColoredComplementarySpec(Txt, Template);
			}
		}
	}

	return super.GetColoredText(Txt, FontSize);
}

simulated function string GetColor()
{
	local UIChooseSpecializations ParentScreen;
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo Template;

	List = UIList(GetParent(class'UIList'));
	ParentScreen = UIChooseSpecializations(self.List.ParentPanel);

	if (List != none && ParentScreen != none)
	{
		Spec = ParentScreen.SpecializationsPool[ParentScreen.GetItemIndex(ItemComodity)];
		Template = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplate(Spec);
		if (Template.ForceComplementarySpecializations.Length > 0)
		{
			return GetComplementarySpecHexColor(Template);
		}
	}

	return "";
}

function string GetColoredComplementarySpec(string Txt, X2UniversalSoldierClassInfo Template)
{
	return "<font color='#" $ GetComplementarySpecHexColor(Template) $ "'>" $ Txt $ "</font>";

}

function string GetComplementarySpecHexColor(X2UniversalSoldierClassInfo Template)
{
	local int CheckSum;
	local array<string> ColorPool;
	local string SpecColor;

	CheckSum = Template.GetComplementarySpecializationCheckSum();

	ColorPool.AddItem("FFA500");
	ColorPool.AddItem("FF8C00");
	ColorPool.AddItem("FF7F50");
	ColorPool.AddItem("FF6347");
	ColorPool.AddItem("FF4500");

	SpecColor = ColorPool[Checksum % ColorPool.Length];
	
	return SpecColor;
}

defaultproperties
{
	InitPosX = 0
	InitPosY = 146
	IconSize = 38
	Height = 196
}
