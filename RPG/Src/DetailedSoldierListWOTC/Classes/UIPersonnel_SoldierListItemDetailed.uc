class UIPersonnel_SoldierListItemDetailed extends UIPersonnel_SoldierListItem config(Game);

var config int NUM_HOURS_TO_DAYS;
var config bool ROOKIE_SHOW_PSI_INSTEAD_CI;

var float IconXPos, IconYPos, IconXDelta, IconScale, IconToValueOffsetX, IconToValueOffsetY, IconXDeltaSmallValue;
var float DisabledAlpha;

var bool bIsFocussed;

var array<string> APColours;

//icons to be shown in the class area
var UIImage AimIcon, DefenseIcon;
var UIText AimValue, DefenseValue;

//icons to be shown in the name area
var UIImage HealthIcon, MobilityIcon, WillIcon, HackIcon, DodgeIcon, PsiIcon, PrimaryWeaponIcon, SecondaryWeaponIcon; 
var UIText HealthValue, MobilityValue, WillValue, HackValue, DodgeValue, PsiValue;

var UIIcon APIcon;

var array<UIIcon> BadTraitIcon;

var string strUnitName, strClassName;

simulated function UIButton SetDisabled(bool disabled, optional string TooltipText)
{
	super.SetDisabled(disabled, TooltipText);
	UpdateDisabled();
	UpdateItemsForFocus(false);
	return self;
}

static function GetTimeLabelValue(int Hours, out int TimeValue, out string TimeLabel)
{	
	if (Hours < 0 || Hours > 24 * 30 * 12) // Ignore year long missions
	{
		TimeValue = 0;
		TimeLabel = "";
		return;
	}
	if (Hours > default.NUM_HOURS_TO_DAYS)
	{
		Hours = FCeil(float(Hours) / 24.0f);
		TimeValue = Hours;
		TimeLabel = class'UIUtilities_Text'.static.GetDaysString(Hours);
	}
	else
	{
		TimeValue = Hours;
		TimeLabel = class'UIUtilities_Text'.static.GetHoursString(Hours);
	}
}

static function GetStatusStringsSeparate(XComGameState_Unit Unit, out string Status, out string TimeLabel, out int TimeValue)
{
	local bool bProjectExists;
	local int iHours;
	local UnitValue SeveredBodyPart;
	
	if( Unit.IsInjured() )
	{
		Status = Unit.GetWoundStatus(iHours);
		if (Status != "")
			bProjectExists = true;

		`LOG(GetFuncName() @ Unit.GetFullName() @ Unit.IsGravelyInjured(),,'Augmentations');
		if (Unit.IsGravelyInjured())
		{
			bProjectExists = false;
			if (Unit.GetUnitValue('SeveredBodyPart', SeveredBodyPart))
			{
				`LOG(GetFuncName() @ "SeveredBodyPart" @ GetEnum(Enum'ESeveredBodyPart', int(SeveredBodyPart.fValue)),,'Augmentations');
				switch (int(SeveredBodyPart.fValue))
				{
					case eHead:
						Status $= " (" $ class'X2AugmentationsGameRulesetDataStructures'.default.m_strServeredHead $ ")";
						break;
					case eTorso:
						Status $= " (" $ class'X2AugmentationsGameRulesetDataStructures'.default.m_strServeredTorso $ ")";
						break;
					case eArms:
						Status $= " (" $ class'X2AugmentationsGameRulesetDataStructures'.default.m_strServeredArms $ ")";
						break;
					case eLegs:
						Status $= " (" $ class'X2AugmentationsGameRulesetDataStructures'.default.m_strServeredLegs $ ")";
						break;
				}
			}
		}
	}
	else if (Unit.IsOnCovertAction())
	{
		Status = Unit.GetCovertActionStatus(iHours);
		if (Status != "")
			bProjectExists = true;
	}
	else if (Unit.IsTraining() || Unit.IsPsiTraining() || Unit.IsPsiAbilityTraining())
	{
		Status = Unit.GetTrainingStatus(iHours);
		if (Status != "")
			bProjectExists = true;
	}
	else if( Unit.IsDead() )
	{
		Status = "KIA";
	}
	else
	{
		Status = "";
	}
	
	if (bProjectExists)
	{
		GetTimeLabelValue(iHours, TimeValue, TimeLabel);
	}
}

static function GetPersonnelStatusSeparate(XComGameState_Unit Unit, out string Status, out string TimeLabel, out string TimeValue, optional int FontSizeZ = -1, optional bool bIncludeMentalState = false)
{
	local EUIState eState; 
	local int TimeNum;
	local bool bHideZeroDays;

	bHideZeroDays = true;

	if(Unit.IsMPCharacter())
	{
		Status = class'UIUtilities_Strategy'.default.m_strAvailableStatus;
		eState = eUIState_Good;
		TimeNum = 0;
		Status = class'UIUtilities_Text'.static.GetColoredText(Status, eState, FontSizeZ);
		return;
	}

	// template names are set in X2Character_DefaultCharacters.uc
	if (Unit.IsScientist() || Unit.IsEngineer())
	{
		Status = class'UIUtilities_Text'.static.GetSizedText(Unit.GetLocation(), FontSizeZ);
	}
	else if (Unit.IsSoldier())
	{
		// soldiers get put into the hangar to indicate they are getting ready to go on a mission
		if(`HQPRES != none &&  `HQPRES.ScreenStack.IsInStack(class'UISquadSelect') && `XCOMHQ.IsUnitInSquad(Unit.GetReference()) )
		{
			Status = class'UIUtilities_Strategy'.default.m_strOnMissionStatus;
			eState = eUIState_Highlight;
		}
		else if (Unit.bRecoveryBoosted)
		{
			Status = class'UIUtilities_Strategy'.default.m_strBoostedStatus;
			eState = eUIState_Warning;
		}
		else if( Unit.IsInjured() || Unit.IsDead() )
		{
			GetStatusStringsSeparate(Unit, Status, TimeLabel, TimeNum);
			eState = eUIState_Bad;
		}
		else if(Unit.GetMentalState() == eMentalState_Shaken)
		{
			GetUnitMentalState(Unit, Status, TimeLabel, TimeNum);
			eState = Unit.GetMentalStateUIState();
		}
		else if( Unit.IsPsiTraining() || Unit.IsPsiAbilityTraining() )
		{
			GetStatusStringsSeparate(Unit, Status, TimeLabel, TimeNum);
			eState = eUIState_Psyonic;
		}
		else if( Unit.IsTraining() )
		{
			GetStatusStringsSeparate(Unit, Status, TimeLabel, TimeNum);
			eState = eUIState_Warning;
		}
		else if(  Unit.IsOnCovertAction() )
		{
			GetStatusStringsSeparate(Unit, Status, TimeLabel, TimeNum);
			eState = eUIState_Warning;
			bHideZeroDays = false;
		}
		else if(bIncludeMentalState && Unit.BelowReadyWillState())
		{
			GetUnitMentalState(Unit, Status, TimeLabel, TimeNum);
			eState = Unit.GetMentalStateUIState();
		}
		else
		{
			Status = class'UIUtilities_Strategy'.default.m_strAvailableStatus;
			eState = eUIState_Good;
			TimeNum = 0;
		}
	}

	Status = class'UIUtilities_Text'.static.GetColoredText(Status, eState, FontSizeZ);
	TimeLabel = class'UIUtilities_Text'.static.GetColoredText(TimeLabel, eState, FontSizeZ);
	if( TimeNum == 0 && bHideZeroDays )
		TimeValue = "";
	else
		TimeValue = class'UIUtilities_Text'.static.GetColoredText(string(TimeNum), eState, FontSizeZ);
}

static function GetUnitMentalState(XComGameState_Unit UnitState, out string Status, out string TimeLabel, out int TimeValue)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	local int iHours;

	History = `XCOMHISTORY;
	Status = UnitState.GetMentalStateLabel();
	TimeLabel = "";
	TimeValue = 0;

	if(UnitState.BelowReadyWillState())
	{
		foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
		{
			if(WillProject.ProjectFocus.ObjectID == UnitState.ObjectID)
			{
				iHours = WillProject.GetCurrentNumHoursRemaining();
				GetTimeLabelValue(iHours, TimeValue, TimeLabel);
				break;
			}
		}
	}
}

simulated function bool ShouldShowPsi(XComGameState_Unit Unit)
{
	local LWTuple EventTup;

	EventTup = new class'LWTuple';
	EventTup.Id = 'ShouldShowPsi';
	EventTup.Data.Add(1);
	EventTup.Data[0].kind = LWTVBool;
	EventTup.Data[0].b = false;

	if (Unit.IsPsiOperative() || (default.ROOKIE_SHOW_PSI_INSTEAD_CI && Unit.GetRank() == 0 && !Unit.CanRankUpSoldier() && `XCOMHQ.IsTechResearched('Psionics')))
	{
		EventTup.Data[0].b = true;
	}

	`XEVENTMGR.TriggerEvent('DSLShouldShowPsi', EventTup, Unit);

	return EventTup.Data[0].b;
}

simulated function UpdateData()
{
	local XComGameState_Unit Unit;
	local string UnitLoc, status, statusTimeLabel, statusTimeValue, classIcon, rankIcon, flagIcon, mentalStatus;
	local int iRank, iTimeNum;
	local X2SoldierClassTemplate SoldierClass;
	local XComGameState_ResistanceFaction FactionState;
	local SoldierBond BondData;
	local StateObjectReference BondmateRef;
	local XComGameState_Unit Bondmate;
	local int BondLevel;
	local string traitsTooltip, tooltipText;
	
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));

	iRank = Unit.GetRank();

	SoldierClass = Unit.GetSoldierClassTemplate();
	FactionState = Unit.GetResistanceFaction();

	GetPersonnelStatusSeparate(Unit, status, statusTimeLabel, statusTimeValue);
	mentalStatus = "";

	if(Unit.IsActive())
	{
		GetUnitMentalState(Unit, mentalStatus, statusTimeLabel, iTimeNum);
		statusTimeLabel = class'UIUtilities_Text'.static.GetColoredText(statusTimeLabel, Unit.GetMentalStateUIState());

		if(iTimeNum == 0)
		{
			statusTimeValue = "";
		}
		else
		{
			statusTimeValue = class'UIUtilities_Text'.static.GetColoredText(string(iTimeNum), Unit.GetMentalStateUIState());
		}
	}

	if( statusTimeValue == "" )
		statusTimeValue = "---";

	flagIcon = Unit.GetCountryTemplate().FlagImage;
	//rankIcon = class'UIUtilities_Image'.static.GetRankIcon(iRank, SoldierClass.DataName);
	rankIcon = class'UIUtilities_Image'.static.GetRankIcon(iRank, SoldierClass.DataName);
	classIcon = Unit.GetSoldierClassIcon();

	// if personnel is not staffed, don't show location
	if( class'UIUtilities_Strategy'.static.DisplayLocation(Unit) )
		UnitLoc = class'UIUtilities_Strategy'.static.GetPersonnelLocation(Unit);
	else
		UnitLoc = "";

	if( BondIcon == none )
	{
		BondIcon = Spawn(class'UIBondIcon', self);
		if( `ISCONTROLLERACTIVE ) 
			BondIcon.bIsNavigable = false; 
	}

	if( Unit.HasSoldierBond(BondmateRef, BondData) )
	{
		Bondmate = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(BondmateRef.ObjectID));
		BondLevel = BondData.BondLevel;
		if( !BondIcon.bIsInited )
		{
			BondIcon.InitBondIcon('UnitBondIcon', BondData.BondLevel, , BondData.Bondmate);
		}
		BondIcon.Show();
		tooltipText = Repl(BondmateTooltip, "%SOLDIERNAME", Caps(Bondmate.GetName(eNameType_RankFull)));
	}
	else if( Unit.ShowBondAvailableIcon(BondmateRef, BondData) )
	{
		BondLevel = BondData.BondLevel;
		if( !BondIcon.bIsInited )
		{
			BondIcon.InitBondIcon('UnitBondIcon', BondData.BondLevel, , BondmateRef);
		}
		BondIcon.Show();
		BondIcon.AnimateCohesion(true);
		tooltipText = class'XComHQPresentationLayer'.default.m_strBannerBondAvailable;
	}
	else
	{
		if( !BondIcon.bIsInited )
		{
			BondIcon.InitBondIcon('UnitBondIcon', BondData.BondLevel, , BondData.Bondmate);
		}
		BondIcon.Hide();
		BondLevel = -1; 
		tooltipText = "";
	}

	AS_UpdateDataSoldier(Caps(Unit.GetName(eNameType_Full)),
					Caps(Unit.GetName(eNameType_Nick)),
					Caps(`GET_RANK_ABBRV(Unit.GetRank(), SoldierClass.DataName)),
					rankIcon,
					Caps(SoldierClass != None ? Unit.GetSoldierClassDisplayName() : ""),
					classIcon,
					status,
					statusTimeValue $"\n" $ Class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(Class'UIUtilities_Text'.static.GetSizedText( statusTimeLabel, 12)),
					UnitLoc,
					flagIcon,
					false, //todo: is disabled 
					Unit.ShowPromoteIcon(),
					false, // psi soldiers can't rank up via missions
					mentalStatus,
					BondLevel);

	AS_SetFactionIcon(FactionState.GetFactionIcon());
	traitsTooltip = "";
	AddAdditionalItems(self, traitsTooltip);

	if (traitsTooltip != "")
	{
		if (tooltipText != "")
		{
			tooltipText = tooltipText $ "\n" $ traitsTooltip;
		}
		else
		{
			tooltipText = traitsTooltip;
		}
	}
	if (tooltipText != "")
	{
		SetTooltipText(tooltipText);
		Movie.Pres.m_kTooltipMgr.TextTooltip.SetUsePartialPath(CachedTooltipID, true);
	}
}

function AddAdditionalItems(UIPersonnel_SoldierListItem ListItem, out string traitToolTip)
{
	local XComGameState_Unit Unit;
	
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.UnitRef.ObjectID));

	if(GetLanguage() == "JPN")
	{
		IconToValueOffsetY = -3.0;
	}

	AddClassColumnIcons(Unit);
	AddNameColumnIcons(Unit, traitToolTip);

	if(Unit.GetName(eNameType_Nick) == " ")
		strUnitName = CAPS(Unit.GetName(eNameType_First) @ Unit.GetName(eNameType_Last));
	else
		strUnitName = CAPS(Unit.GetName(eNameType_First) @ Unit.GetName(eNameType_Nick) @ Unit.GetName(eNameType_Last));

	ListItem.MC.ChildSetString("NameFieldContainer.NameField", "htmlText", class'UIUtilities_Text'.static.GetColoredText(strUnitName, eUIState_Normal));
	ListItem.MC.ChildSetNum("NameFieldContainer.NameField", "_y", (GetLanguage() == "JPN" ? -25 :-22));

	ListItem.MC.ChildSetString("NicknameFieldContainer.NicknameField", "htmlText", " ");
	ListItem.MC.ChildSetBool("NicknameFieldContainer.NicknameField", "_visible", false);

	ListItem.MC.ChildSetNum("ClassFieldContainer", "_y", (GetLanguage() == "JPN" ? -3 : 0));

	UpdateDisabled();
}

function AddNameColumnIcons(XComGameState_Unit Unit, out string traitToolTip)
{
	local string PrimaryLoadoutImage, SecondaryLoadoutImage;
	local string psioffensestr;
	local X2EventListenerTemplateManager EventTemplateManager;
	local X2TraitTemplate TraitTemplate;
	local int i;

	IconXPos = 174;

	if(HealthIcon == none)
	{
		HealthIcon = Spawn(class'UIImage', self);
		HealthIcon.bAnimateOnInit = false;
		HealthIcon.InitImage('HealthIcon_ListItem_LW', "UILibrary_LWToolbox.StatIcons.Image_Health").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	}
	if(HealthValue == none)
	{
		HealthValue = Spawn(class'UIText', self);
		HealthValue.bAnimateOnInit = false;
		HealthValue.InitText('HealthValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	
	}
	HealthValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_HP))), eUIState_Normal));

	IconXPos += IconXDeltaSmallValue;

	if(MobilityIcon == none)
	{
		MobilityIcon = Spawn(class'UIImage', self);
		MobilityIcon.bAnimateOnInit = false;
		MobilityIcon.InitImage('MobilityIcon_ListItem_LW', "UILibrary_LWToolbox.StatIcons.Image_Mobility").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	}
	if(MobilityValue == none)
	{
		MobilityValue = Spawn(class'UIText', self);
		MobilityValue.bAnimateOnInit = false;
		MobilityValue.InitText('MobilityValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	}
	MobilityValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Mobility))), eUIState_Normal));

	IconXPos += IconXDeltaSmallValue;
//
	//if(WillIcon == none)
	//{
		//WillIcon = Spawn(class'UIImage', self);
		//WillIcon.bAnimateOnInit = false;
		//WillIcon.InitImage('WillIcon_ListItem_LW', "UILibrary_LWToolbox.StatIcons.Image_Will").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	//}
	//if(WillValue == none)
	//{
		//WillValue = Spawn(class'UIText', self);
		//WillValue.bAnimateOnInit = false;
		//WillValue.InitText('WillValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	//}
	//WillValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Will))), eUIState_Normal));
//
	//IconXPos += IconXDelta * 1.5;

	if(HackIcon == none)
	{
		HackIcon = Spawn(class'UIImage', self);
		HackIcon.bAnimateOnInit = false;
		HackIcon.InitImage('HackIcon_ListItem_LW', "UILibrary_LWToolbox.StatIcons.Image_Hacking").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	}
	if(HackValue == none)
	{
		HackValue = Spawn(class'UIText', self);
		HackValue.bAnimateOnInit = false;
		HackValue.InitText('HackValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	}
	HackValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Hacking))), eUIState_Normal));

	IconXPos += IconXDelta;

	if(DodgeIcon == none)
	{
		DodgeIcon = Spawn(class'UIImage', self);
		DodgeIcon.bAnimateOnInit = false;
		DodgeIcon.InitImage('DodgeIcon_ListItem_LW', "UILibrary_LWToolbox.StatIcons.Image_Dodge").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	}
	if(DodgeValue == none)
	{
		DodgeValue = Spawn(class'UIText', self);
		DodgeValue.bAnimateOnInit = false;
		DodgeValue.InitText('DodgeValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	}
	DodgeValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Dodge))), eUIState_Normal));

	IconXPos += IconXDeltaSmallValue;

	if(PsiIcon == none)
	{
		PsiIcon = Spawn(class'UIImage', self);
		PsiIcon.bAnimateOnInit = false;
		PsiIcon.InitImage('PsiIcon_ListItem_LW', "gfxXComIcons.promote_psi").SetScale(IconScale).SetPosition(IconXPos, IconYPos+1);
	}
	if(PsiValue == none)
	{
		PsiValue = Spawn(class'UIText', self);
		PsiValue.bAnimateOnInit = false;
		PsiValue.InitText('PsiValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	}

	if (ShouldShowPsi(Unit))
	{
		PsiOffenseStr = string(int(Unit.GetCurrentStat(eStat_PsiOffense)));

		PsiIcon.LoadImage("gfxXComIcons.promote_psi");
		PsiIcon.Show();
		PsiValue.Show();
		PsiValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(PsiOffenseStr, eUIState_Normal));
	}
	else
	{
		if ((Unit.GetSoldierClassTemplate() != none && Unit.GetSoldierClassTemplate().bAllowAWCAbilities) || Unit.IsResistanceHero() || Unit.GetRank() == 0)
		{
			PsiIcon.Hide();
			if (APIcon == none)
			{
				APIcon = Spawn(class'UIIcon', self);
				APIcon.bAnimateOnInit = false;
				APIcon.bDisableSelectionBrackets = true;
				APIcon.InitIcon('APIcon_ListItem_LW', "gfxStrategyComponents.combatIntIcon", false, false);
			}
			APIcon.SetScale(IconScale * 0.6);
			APIcon.SetPosition(IconXPos - (IconToValueOffsetX * 0.1), IconYPos);
			APIcon.Show();
			PsiValue.Show();
		}
		else
		{
			PsiIcon.Hide();
			PsiValue.Hide();
		}
	}

	PrimaryLoadoutImage = "img:///UILibrary_RPG.loadout_icon_"  $ string(X2WeaponTemplate(Unit.GetPrimaryWeapon().GetMyTemplate()).WeaponCat);
	SecondaryLoadoutImage = "img:///UILibrary_RPG.loadout_icon_"  $ string(X2WeaponTemplate(Unit.GetSecondaryWeapon().GetMyTemplate()).WeaponCat);
	
	if (PrimaryWeaponIcon == none)
	{
		PrimaryWeaponIcon = Spawn(class'UIImage', self);
		PrimaryWeaponIcon.bAnimateOnInit = false;
		PrimaryWeaponIcon.InitImage('PrimaryLoadoutImage_ListItem', PrimaryLoadoutImage).SetScale(IconScale).SetPosition(IconXPos += 35, -9.0f);
	}

	if (SecondaryWeaponIcon == none && Unit.GetSecondaryWeapon() != none)
	{
		SecondaryWeaponIcon = Spawn(class'UIImage', self);
		SecondaryWeaponIcon.bAnimateOnInit = false;
		SecondaryWeaponIcon.InitImage('SecondaryWeaponIcon_ListItem', SecondaryLoadoutImage).SetScale(IconScale).SetPosition(IconXPos + 40.0f, -9.0f);
	}


	IconXPos += IconXDelta;

	EventTemplateManager = class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager();

	for (i = 0; i < Unit.AcquiredTraits.Length; i++)
	{
		TraitTemplate = X2TraitTemplate(EventTemplateManager.FindEventListenerTemplate(Unit.AcquiredTraits[i]));
		if (TraitTemplate != none)
		{
			BadTraitIcon.InsertItem(i, Spawn(class'UIIcon', self));
			BadTraitIcon[i].bAnimateOnInit = false;
			BadTraitIcon[i].bDisableSelectionBrackets = true;
			BadTraitIcon[i].InitIcon(name("TraitIcon_ListItem_LW_" $ i), TraitTemplate.IconImage, false, false).SetScale(IconScale).SetPosition(IconXPos, IconYPos+1);
			BadTraitIcon[i].SetForegroundColor("9acbcb");
			traitToolTip $= "\n" $ TraitTemplate.TraitFriendlyName @ "-" @ TraitTemplate.TraitDescription;
		}
	}

}

function AddClassColumnIcons(XComGameState_Unit Unit)
{
	IconXPos = 600;

	if(AimIcon == none)
	{
		AimIcon = Spawn(class'UIImage', self);
		AimIcon.bAnimateOnInit = false;
		AimIcon.InitImage(, "UILibrary_LWToolbox.StatIcons.Image_Aim").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	}
	if(AimValue == none)
	{
		AimValue = Spawn(class'UIText', self);
		AimValue.bAnimateOnInit = false;
		AimValue.InitText().SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	}
	AimValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Offense))), eUIState_Normal));

	IconXPos += IconXDelta;

	if(WillIcon == none)
	{
		WillIcon = Spawn(class'UIImage', self);
		WillIcon.bAnimateOnInit = false;
		WillIcon.InitImage('WillIcon_ListItem_LW', "UILibrary_LWToolbox.StatIcons.Image_Will").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	}
	if(WillValue == none)
	{
		WillValue = Spawn(class'UIText', self);
		WillValue.bAnimateOnInit = false;
		WillValue.InitText('WillValue_ListItem_LW').SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	}
	WillValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Will))), eUIState_Normal));

	//if(DefenseIcon == none)
	//{
		//DefenseIcon = Spawn(class'UIImage', self);
		//DefenseIcon.bAnimateOnInit = false;
		//DefenseIcon.InitImage(, "UILibrary_LWToolbox.StatIcons.Image_Defense").SetScale(IconScale).SetPosition(IconXPos, IconYPos);
	//}
	//if(DefenseValue == none)
	//{
		//DefenseValue = Spawn(class'UIText', self);
		//DefenseValue.bAnimateOnInit = false;
		//DefenseValue.InitText().SetPosition(IconXPos + IconToValueOffsetX, IconYPos + IconToValueOffsetY);
	//}
	//DefenseValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(int(Unit.GetCurrentStat(eStat_Defense))), eUIState_Normal));
}

simulated function UpdateItemsForFocus(bool Focussed)
{
	local int iUIState;
	local XComGameState_Unit Unit;
	local bool bReverse;
	local string Aim, Health, Mobility, Will, Hack, Dodge, Psi; // Defense
	local UIIcon traitIcon;

	iUIState = (IsDisabled ? eUIState_Disabled : eUIState_Normal);

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	bIsFocussed = Focussed;
	bReverse = bIsFocussed && !IsDisabled;

	// Get Unit base stats and any stat modifications from abilities
	Will = string(int(Unit.GetCurrentStat(eStat_Will)) + Unit.GetUIStatFromAbilities(eStat_Will)) $ "/" $
		string(int(Unit.GetMaxStat(eStat_Will)));
	Aim = string(int(Unit.GetCurrentStat(eStat_Offense)) + Unit.GetUIStatFromAbilities(eStat_Offense));
	Health = string(int(Unit.GetCurrentStat(eStat_HP)) + Unit.GetUIStatFromAbilities(eStat_HP));
	Mobility = string(int(Unit.GetCurrentStat(eStat_Mobility)) + Unit.GetUIStatFromAbilities(eStat_Mobility));
	Hack = string(int(Unit.GetCurrentStat(eStat_Hacking)) + Unit.GetUIStatFromAbilities(eStat_Hacking));
	Dodge = string(int(Unit.GetCurrentStat(eStat_Dodge)) + Unit.GetUIStatFromAbilities(eStat_Dodge));
	Psi = string(int(Unit.GetCurrentStat(eStat_PsiOffense)) + Unit.GetUIStatFromAbilities(eStat_PsiOffense));
	//Defense = string(int(Unit.GetCurrentStat(eStat_Defense)) + Unit.GetUIStatFromAbilities(eStat_Defense));
	
	AimValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Aim, (bReverse ? -1 : iUIState)));
	//DefenseValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Defense, (bReverse ? -1 : iUIState)));
	HealthValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Health, (bReverse ? -1 : iUIState)));
	MobilityValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Mobility, (bReverse ? -1 : iUIState)));
	WillValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Will, Unit.GetMentalStateUIState()));
	HackValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Hack, (bReverse ? -1 : iUIState)));
	DodgeValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Dodge, (bReverse ? -1 : iUIState)));
	if (ShouldShowPsi(Unit))
	{
		PsiValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Psi, (bReverse ? -1 : iUIState)));
	}
	else
	{
		if ((Unit.GetSoldierClassTemplate() != none && Unit.GetSoldierClassTemplate().bAllowAWCAbilities) || Unit.IsResistanceHero() || Unit.GetRank() == 0)
		{
			PsiValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(string(Unit.AbilityPoints), (bReverse ? -1 : iUIState)));

			if (APIcon != none)
			{
				APIcon.SetForegroundColor(APColours[int(Unit.ComInt)]);
			}
		}
	}

	foreach BadTraitIcon(traitIcon)
	{
		traitIcon.SetForegroundColor(bReverse ? "000000" : "9acbcb");
	}

}

simulated function UpdateDisabled()
{
	local float UpdateAlpha;

	UpdateAlpha = (IsDisabled ? DisabledAlpha : 1.0f);

	if(AimIcon == none)
		return;

	AimIcon.SetAlpha(UpdateAlpha);
	DefenseIcon.SetAlpha(UpdateAlpha);
	HealthIcon.SetAlpha(UpdateAlpha);
	MobilityIcon.SetAlpha(UpdateAlpha);
	WillIcon.SetAlpha(UpdateAlpha);
	HackIcon.SetAlpha(UpdateAlpha);
	DodgeIcon.SetAlpha(UpdateAlpha);
	if (PsiIcon != none)
		PsiIcon.SetAlpha(UpdateAlpha);

}

simulated function FocusBondEntry(bool IsFocus)
{
	local XComGameState_Unit Unit;
	local UIPersonnel_SoldierListItemDetailed OtherListItem;
	local array<UIPanel> AllOtherListItem;
	local UIPanel OtherItem;
	local StateObjectReference BondmateRef;
	local SoldierBond BondData;
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));

	if( Unit.HasSoldierBond(BondmateRef, BondData) )
	{
		ParentPanel.GetChildrenOfType(class'UIPersonnel_SoldierListItemDetailed', AllOtherListItem);
		foreach AllOtherListitem(OtherItem)
		{
			OtherListItem = UIPersonnel_SoldierListItemDetailed(OtherItem);
			if (OtherListItem != none && OtherListItem.UnitRef.ObjectID == BondmateRef.ObjectID)
			{
				if (IsFocus)
				{
					OtherListItem.BondIcon.OnReceiveFocus();
				}
				else
				{
					OtherListItem.BondIcon.OnLoseFocus();
				}
			}
		}
	}
}

simulated function OnMouseEvent(int Cmd, array<string> Args)
{
	switch(Cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OVER:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DRAG_OVER:
		UpdateItemsForFocus(true);
		FocusBondEntry(true);
		break;
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DRAG_OUT:
		UpdateItemsForFocus(false);
		FocusBondEntry(false);
		break;

	}

	Super(UIPanel).OnMouseEvent(Cmd, Args);
}

simulated function RefreshTooltipText()
{
	local XComGameState_Unit Unit;
	local SoldierBond BondData;
	local StateObjectReference BondmateRef;
	local XComGameState_Unit Bondmate;
	local string textTooltip, traitTooltip;
	local X2EventListenerTemplateManager EventTemplateManager;
	local X2TraitTemplate TraitTemplate;
	local int i;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));

	EventTemplateManager = class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager();

	textTooltip = "";
	traitTooltip = "";

	for (i = 0; i < Unit.AcquiredTraits.Length; i++)
	{
		TraitTemplate = X2TraitTemplate(EventTemplateManager.FindEventListenerTemplate(Unit.AcquiredTraits[i]));
		if (TraitTemplate != none)
		{
			if (traitTooltip != "")
			{
				traitTooltip $= "\n";
			}
			traitTooltip $= TraitTemplate.TraitFriendlyName @ "-" @ TraitTemplate.TraitDescription;
		}
	}

	if( Unit.HasSoldierBond(BondmateRef, BondData) )
	{
		Bondmate = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(BondmateRef.ObjectID));
		textTooltip = Repl(BondmateTooltip, "%SOLDIERNAME", Caps(Bondmate.GetName(eNameType_RankFull)));
	}
	else if( Unit.ShowBondAvailableIcon(BondmateRef, BondData) )
	{
		textTooltip = class'XComHQPresentationLayer'.default.m_strBannerBondAvailable;
	}

	if (textTooltip != "")
	{
		textTooltip $= "\n\n" $ traitTooltip;
	}
	else
	{
		textTooltip = traitTooltip;
	}
	
	if (textTooltip != "")
	{
		SetTooltipText(textTooltip);
		Movie.Pres.m_kTooltipMgr.TextTooltip.SetUsePartialPath(CachedTooltipID, true);
	}
	else
	{
		SetTooltipText("");
	}
}

defaultproperties
{
	IconToValueOffsetX = 23.0f; // 26
	IconScale = 0.65f;
	IconYPos = 23.0f;
	IconXDelta = 60.0f; // 64
	IconXDeltaSmallValue = 48.0f;
	LibID = "SoldierListItem";
	DisabledAlpha = 0.5f;

	bAnimateOnInit = false;

	APColours(0)="bf1e2e"
	APColours(1)="e69831"
	APColours(2)="fdce2b"
	APColours(3)="53b45e"
	APColours(4)="27aae1"
}