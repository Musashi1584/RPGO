class NPSBDP_UIArmory_PromotionHero extends UIArmory_PromotionHero config(PromotionUIMod);

var UIScrollbar	Scrollbar;

struct CustomClassAbilitiesPerRank
{
	var name ClassName;
	var int AbilitiesPerRank;
};

struct CustomClassAbilityCost
{
	var name ClassName;
	var name AbilityName;
	var int AbilityCost;
};

var config bool APRequiresTrainingCenter;
var config bool RevealAllAbilities;

var config array<CustomClassAbilitiesPerRank> ClassAbilitiesPerRank;
var config array<CustomClassAbilityCost> ClassCustomAbilityCost;

var int Position, MaxPosition, AdjustXOffset;

simulated function OnInit()
{
	local UIArmory_PromotionHeroColumn Column;
	local int ColumnXDiff;

	super.OnInit();

	Width = int(MC.GetNum("_width"));
	// Fix width and position of elements to make space for the 8th column
	//
	ColumnXDiff = MC.GetNum("rankColumn6._x") - MC.GetNum("rankColumn5._x"); // 152
	AdjustXOffset = ColumnXDiff;
	SetWidth(Width + AdjustXOffset);
	`LOG("ColumnXDiff" @ ColumnXDiff @ "AdjustXOffset" @ AdjustXOffset,, 'PromotionScreen');

	//foreach Columns(Column)
	//{
	//	Column.SetWidth(ColumnXDiff);
	//}
	
	MC.ChildSetNum("bg",				"_width", MC.GetNum("bg._width") + AdjustXOffset);
	MC.ChildSetNum("topDivider",		"_width", MC.GetNum("topDivider._width") + AdjustXOffset);
	MC.ChildSetNum("bottomDivider",		"_width", MC.GetNum("bottomDivider._width") + AdjustXOffset);
	MC.ChildSetNum("headerLines",		"_width", MC.GetNum("headerLines._width") + AdjustXOffset);
	MC.ChildSetNum("columnGradients",	"_width", MC.GetNum("columnGradients._width") + AdjustXOffset);

	
	//MC.ChildSetNum("bg", "_x", X - AdjustXOffset);
	MC.SetNum("_x", MC.GetNum("_x") + 50);
	MC.ChildSetNum("topDivider",		"_x", MC.GetNum("topDivider._x") - AdjustXOffset);
	MC.ChildSetNum("bottomDivider",		"_x", MC.GetNum("bottomDivider._x") - AdjustXOffset);
	MC.ChildSetNum("headerLines",		"_x", MC.GetNum("headerLines._x") - AdjustXOffset);
	MC.ChildSetNum("columnGradients",	"_x", MC.GetNum("columnGradients._x") - AdjustXOffset);
	MC.ChildSetNum("factionLogoLarge",	"_x", MC.GetNum("factionLogoLarge._x") - AdjustXOffset);
	MC.ChildSetNum("factionLogo",		"_x", MC.GetNum("factionLogo._x") - AdjustXOffset);
	MC.ChildSetNum("classIcon",			"_x", MC.GetNum("classIcon._x") - AdjustXOffset);
	MC.ChildSetNum("rankIcon",			"_x", MC.GetNum("rankIcon._x") - AdjustXOffset);
	MC.ChildSetNum("factionName",		"_x", MC.GetNum("factionName._x") - AdjustXOffset);
	MC.ChildSetNum("abilityLabel",		"_x", MC.GetNum("abilityLabel._x") - AdjustXOffset);
	MC.ChildSetNum("soldierAPLabel",	"_x", MC.GetNum("soldierAPLabel._x") - AdjustXOffset);
	MC.ChildSetNum("soldierAPValue",	"_x", MC.GetNum("soldierAPValue._x") - AdjustXOffset);
	MC.ChildSetNum("teamAPLabel",		"_x", MC.GetNum("teamAPLabel._x") - AdjustXOffset);
	MC.ChildSetNum("teamAPValue",		"_x", MC.GetNum("teamAPValue._x") - AdjustXOffset);
	MC.ChildSetNum("combatIntelLabel",	"_x", MC.GetNum("combatIntelLabel._x") - AdjustXOffset);
	MC.ChildSetNum("combatIntelValue",	"_x", MC.GetNum("combatIntelValue._x") - AdjustXOffset);
	MC.ChildSetNum("unitName",			"_x", MC.GetNum("unitName._x") - AdjustXOffset);
	MC.ChildSetNum("descriptionTitle",	"_x", MC.GetNum("descriptionTitle._x") - AdjustXOffset);
	MC.ChildSetNum("descriptionBody",	"_x", MC.GetNum("descriptionBody._x") - AdjustXOffset);
	MC.ChildSetNum("descriptionDetail",	"_x", MC.GetNum("descriptionDetail._x") - AdjustXOffset);
	MC.ChildSetNum("descriptionIcon",	"_x", MC.GetNum("descriptionIcon._x") - AdjustXOffset);
	MC.ChildSetNum("costLabel",			"_x", MC.GetNum("costLabel._x") - AdjustXOffset);
	MC.ChildSetNum("costValue",			"_x", MC.GetNum("costValue._x") - AdjustXOffset);
	MC.ChildSetNum("apLabel",			"_x", MC.GetNum("apLabel._x") - AdjustXOffset);
	MC.ChildSetNum("abilityPathHeader",	"_x", MC.GetNum("abilityPathHeader._x") - AdjustXOffset);
	MC.ChildSetNum("pathLabel0",		"_x", MC.GetNum("pathLabel0._x") - AdjustXOffset);
	MC.ChildSetNum("pathLabel1",		"_x", MC.GetNum("pathLabel1._x") - AdjustXOffset);
	MC.ChildSetNum("pathLabel2",		"_x", MC.GetNum("pathLabel2._x") - AdjustXOffset);
	MC.ChildSetNum("pathLabel3",		"_x", MC.GetNum("pathLabel3._x") - AdjustXOffset);
	//MC.ChildSetNum("abilityPathHeader.theLabel","_x", MC.GetNum("abilityPathHeader.theLabel._x") - AdjustXOffset);
	//MC.ChildSetNum("pathLabel0.theLabel",		"_x", MC.GetNum("pathLabel0.theLabel._x") - AdjustXOffset);
	//MC.ChildSetNum("pathLabel1.theLabel",		"_x", MC.GetNum("pathLabel1.theLabel._x") - AdjustXOffset);
	//MC.ChildSetNum("pathLabel2.theLabel",		"_x", MC.GetNum("pathLabel2.theLabel._x") - AdjustXOffset);
	//MC.ChildSetNum("pathLabel3.theLabel",		"_x", MC.GetNum("pathLabel3.theLabel._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn0",		"_x", MC.GetNum("rankColumn0._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn1",		"_x", MC.GetNum("rankColumn1._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn2",		"_x", MC.GetNum("rankColumn2._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn3",		"_x", MC.GetNum("rankColumn3._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn4",		"_x", MC.GetNum("rankColumn4._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn5",		"_x", MC.GetNum("rankColumn5._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn6",		"_x", MC.GetNum("rankColumn6._x") - AdjustXOffset);
	MC.ChildSetNum("rankColumn7",		"_x", MC.GetNum("rankColumn6._x"));
	MC.ChildSetNum("rankColumn7",		"_y", MC.GetNum("rankColumn6._y"));

	// -465, 310
	Scrollbar.SetPosition(-465, 310);
	//Scrollbar.SetPosition(MC.GetNum("rankColumn6._x") + ColumnXDiff, MC.GetNum("rankColumn6._y"));

	`LOG(self.Class.name @ GetFuncName() @ "_width" @ MC.GetNum("_width"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "bg._width" @ MC.GetNum("bg._width"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "bottomDivider._width" @ MC.GetNum("bottomDivider._width"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "headerLines._width" @ MC.GetNum("headerLines._width"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn0._width" @ MC.GetNum("rankColumn0._width") @ "x" @ MC.GetNum("rankColumn0._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn1._width" @ MC.GetNum("rankColumn1._width") @ "x" @ MC.GetNum("rankColumn1._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn2._width" @ MC.GetNum("rankColumn2._width") @ "x" @ MC.GetNum("rankColumn2._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn3._width" @ MC.GetNum("rankColumn3._width") @ "x" @ MC.GetNum("rankColumn3._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn4._width" @ MC.GetNum("rankColumn4._width") @ "x" @ MC.GetNum("rankColumn4._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn5._width" @ MC.GetNum("rankColumn5._width") @ "x" @ MC.GetNum("rankColumn5._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn6._width" @ MC.GetNum("rankColumn6._width") @ "x" @ MC.GetNum("rankColumn6._x"),, 'PromotionScreen');
	`LOG(self.Class.name @ GetFuncName() @ "rankColumn7._width" @ MC.GetNum("rankColumn7._width") @ "x" @ MC.GetNum("rankColumn7._x"),, 'PromotionScreen');
	
	Show();
}

//Override functions
simulated function InitPromotion(StateObjectReference UnitRef, optional bool bInstantTransition)
{
	local XComGameState_Unit Unit; // bsg-nlong (1.25.17): Used to determine which column we should start highlighting

	Position = 0;

	Hide();

	// If the AfterAction screen is running, let it position the camera
	AfterActionScreen = UIAfterAction(Movie.Stack.GetScreen(class'UIAfterAction'));
	if (AfterActionScreen != none)
	{
		bAfterActionPromotion = true;
		PawnLocationTag = AfterActionScreen.GetPawnLocationTag(UnitRef, "Blueprint_AfterAction_HeroPromote");
		CameraTag = GetPromotionBlueprintTag(UnitRef);
		DisplayTag = name(GetPromotionBlueprintTag(UnitRef));
	}
	else
	{
		CameraTag = string(default.DisplayTag);
		DisplayTag = default.DisplayTag;
	}

	

	// Don't show nav help during tutorial, or during the After Action sequence.
	bUseNavHelp = class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory') || Movie.Pres.ScreenStack.IsInStack(class'UIAfterAction');

	super.InitArmory(UnitRef, , , , , , bInstantTransition);
	
	InitColumns();

	PopulateData();

	RealizeScrollbar();

	DisableNavigation(); // bsg-nlong (1.25.17): This and the column panel will have to use manual naviation, so we'll disable the navigation here

	//MC.FunctionVoid("AnimateIn");

	// bsg-nlong (1.25.17): Focus a column so the screen loads with an ability highlighted
	if( `ISCONTROLLERACTIVE )
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
		if( Unit != none )
		{
			m_iCurrentlySelectedColumn = m_iCurrentlySelectedColumn;
		}
		else
		{
			m_iCurrentlySelectedColumn = 0;
		}

		Columns[m_iCurrentlySelectedColumn].OnReceiveFocus();
	}
	// bsg-nlong (1.25.17): end
}


simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	switch(Cmd)
	{
		case class'UIUtilities_Input'.const.FXS_ARROW_UP:
		case class'UIUtilities_Input'.const.FXS_DPAD_UP:
		//case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_UP:
		//	if (Page > 1)
		//	{
		//		Page -= 1;
		//		PopulateData();
		//	}
		//	break;
		//case class'UIUtilities_Input'.const.FXS_ARROW_DOWN:
		//case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
		//case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_DOWN:
		//	if (Page < MaxPages)
		//	{
		//		Page += 1;
		//		PopulateData();
		//	}
		//	break;
		case class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_DOWN:
			if( Scrollbar != none )
				Scrollbar.OnMouseScrollEvent(-1);
			break;
		case class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_UP:
			if( Scrollbar != none )
				Scrollbar.OnMouseScrollEvent(1);
			break;
	}

	super.OnUnrealCommand(cmd, arg);
}

simulated function PopulateData()
{
	local XComGameState_Unit Unit;
	local X2SoldierClassTemplate ClassTemplate;
	local NPSBDP_UIArmory_PromotionHeroColumn Column;
	local string HeaderString, rankIcon, classIcon;
	local int iRank, maxRank;
	local bool bHasColumnAbility, bHighlightColumn;
	local Vector ZeroVec;
	local Rotator UseRot;
	local XComUnitPawn UnitPawn;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState NewGameState;

	Unit = GetUnit();
	ClassTemplate = Unit.GetSoldierClassTemplate();

	FactionState = Unit.GetResistanceFaction();
	
	rankIcon = class'UIUtilities_Image'.static.GetRankIcon(Unit.GetRank(), ClassTemplate.DataName);
	classIcon = ClassTemplate.IconImage;

	HeaderString = m_strAbilityHeader;
	if (Unit.GetRank() != 1 && Unit.HasAvailablePerksToAssign())
	{
		HeaderString = m_strSelectAbility;
	}

	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	if (Unit.IsResistanceHero() && !XComHQ.bHasSeenHeroPromotionScreen)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Trigger Opened Hero Promotion Screen");
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.bHasSeenHeroPromotionScreen = true;
		`XEVENTMGR.TriggerEvent('OnHeroPromotionScreen', , , NewGameState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else if (Unit.GetRank() >= 2 && Unit.ComInt >= eComInt_Gifted)
	{
		// Check to see if Unit has high combat intelligence, display tutorial popup if so
		`HQPRES.UICombatIntelligenceIntro(Unit.GetReference());
	}

	if (ActorPawn == none || (Unit.GetRank() == 1 && bAfterActionPromotion)) //This condition is TRUE when in the after action report, and we need to rank someone up to squaddie
	{
		//Get the current pawn so we can extract its rotation
		UnitPawn = Movie.Pres.GetUIPawnMgr().RequestPawnByID(AfterActionScreen, UnitReference.ObjectID, ZeroVec, UseRot);
		UseRot = UnitPawn.Rotation;

		//Free the existing pawn, and then create the ranked up pawn. This may not be strictly necessary since most of the differences between the classes are in their equipment. However, it is easy to foresee
		//having class specific soldier content and this covers that possibility
		Movie.Pres.GetUIPawnMgr().ReleasePawn(AfterActionScreen, UnitReference.ObjectID);
		CreateSoldierPawn(UseRot);

		if (bAfterActionPromotion && !Unit.bCaptured)
		{
			//Let the pawn manager know that the after action report is referencing this pawn too			
			UnitPawn = Movie.Pres.GetUIPawnMgr().RequestPawnByID(AfterActionScreen, UnitReference.ObjectID, ZeroVec, UseRot);
			AfterActionScreen.SetPawn(UnitReference, UnitPawn);
		}
	}

	AS_SetRank(rankIcon);
	AS_SetClass(classIcon);
	AS_SetFaction(FactionState.GetFactionIcon());

	AS_SetHeaderData(Caps(FactionState.GetFactionTitle()), Caps(Unit.GetName(eNameType_FullNick)), HeaderString, m_strSharedAPLabel, m_strSoldierAPLabel);
	AS_SetAPData(GetSharedAbilityPoints(), Unit.AbilityPoints);
	AS_SetCombatIntelData(Unit.GetCombatIntelligenceLabel());
	
	AS_SetPathLabels(
		m_strBranchesLabel,
		ClassTemplate.AbilityTreeTitles[0 + Position],
		ClassTemplate.AbilityTreeTitles[1 + Position],
		ClassTemplate.AbilityTreeTitles[2 + Position],
		ClassTemplate.AbilityTreeTitles[3 + Position]
	);

	maxRank = class'X2ExperienceConfig'.static.GetMaxRank();

	for (iRank = 0; iRank < (maxRank - 1); ++iRank)
	{
		Column = NPSBDP_UIArmory_PromotionHeroColumn(Columns[iRank]);
		Column.Offset = Position;
		bHasColumnAbility = UpdateAbilityIcons_Override(Column);
		bHighlightColumn = (!bHasColumnAbility && (iRank+1) == Unit.GetRank());

		Column.AS_SetData(bHighlightColumn, m_strNewRank, class'UIUtilities_Image'.static.GetRankIcon(iRank+1, ClassTemplate.DataName), Caps(class'X2ExperienceConfig'.static.GetRankName(iRank+1, ClassTemplate.DataName)));
	}

	HidePreview();
}

function bool UpdateAbilityIcons_Override(out NPSBDP_UIArmory_PromotionHeroColumn Column)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate, NextAbilityTemplate;
	local array<SoldierClassAbilityType> AbilityTree, NextRankTree;
	local XComGameState_Unit Unit;
	local UIPromotionButtonState ButtonState;
	local int iAbility;
	local bool bHasColumnAbility, bConnectToNextAbility;
	local string AbilityName, AbilityIcon, BGColor, FGColor;
	local int NewMaxPosition;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Unit = GetUnit();
	AbilityTree = Unit.GetRankAbilities(Column.Rank);

	NewMaxPosition = Max(AbilityTree.Length - NUM_ABILITIES_PER_COLUMN, NUM_ABILITIES_PER_COLUMN);
	if (NewMaxPosition > MaxPosition)
		MaxPosition = NewMaxPosition;

	//`LOG("MaxPosition" @ MaxPosition,, 'PromotionScreen');
	Column.AbilityNames.Length = 0;
	
	for (iAbility = 0; iAbility < AbilityTree.Length; iAbility++)
	{
		//`LOG("Create Column" @ Column.Rank @ AbilityTree[iAbility].AbilityName,, 'PromotionScreen');
	}


	for (iAbility = Position; iAbility < Position + NUM_ABILITIES_PER_COLUMN; iAbility++)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityTree[iAbility].AbilityName);
		
		if (AbilityTemplate != none)
		{
			if (Column.AbilityNames.Find(AbilityTemplate.DataName) == INDEX_NONE)
			{
				Column.AbilityNames.AddItem(AbilityTemplate.DataName);
				//`LOG(iAbility @ "Column.AbilityNames Add" @ AbilityTemplate.DataName @ Column.AbilityNames.Length,, 'PromotionScreen');
			}

			// The unit is not yet at the rank needed for this column
			if (!RevealAllAbilities && Column.Rank >= Unit.GetRank())
			{
				AbilityName = class'UIUtilities_Text'.static.GetColoredText(m_strAbilityLockedTitle, eUIState_Disabled);
				AbilityIcon = class'UIUtilities_Image'.const.UnknownAbilityIcon;
				ButtonState = eUIPromotionState_Locked;
				FGColor = class'UIUtilities_Colors'.const.BLACK_HTML_COLOR;
				BGColor = class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR;
				bConnectToNextAbility = false; // Do not display prereqs for abilities which aren't available yet
			}
			else // The ability could be purchased
			{
				AbilityName = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(AbilityTemplate.LocFriendlyName);
				AbilityIcon = AbilityTemplate.IconImage;

				if (Unit.HasSoldierAbility(AbilityTemplate.DataName))
				{
					// The ability has been purchased
					ButtonState = eUIPromotionState_Equipped;
					FGColor = class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR;
					BGColor = class'UIUtilities_Colors'.const.BLACK_HTML_COLOR;
					bHasColumnAbility = true;
				}
				else if(CanPurchaseAbility(Column.Rank, iAbility, AbilityTemplate.DataName))
				{
					// The ability is unlocked and unpurchased, and can be afforded
					ButtonState = eUIPromotionState_Normal;
					FGColor = class'UIUtilities_Colors'.const.PERK_HTML_COLOR;
					BGColor = class'UIUtilities_Colors'.const.BLACK_HTML_COLOR;
				}
				else
				{
					// The ability is unlocked and unpurchased, but cannot be afforded
					ButtonState = eUIPromotionState_Normal;
					FGColor = class'UIUtilities_Colors'.const.BLACK_HTML_COLOR;
					BGColor = class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR;
				}
				
				// Look ahead to the next rank and check to see if the current ability is a prereq for the next one
				// If so, turn on the connection arrow between them
				if (Column.Rank < (class'X2ExperienceConfig'.static.GetMaxRank() - 2) && Unit.GetRank() > (Column.Rank + 1))
				{
					bConnectToNextAbility = false;
					NextRankTree = Unit.GetRankAbilities(Column.Rank + 1);
					NextAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(NextRankTree[iAbility].AbilityName);
					if (NextAbilityTemplate.PrerequisiteAbilities.Length > 0 && NextAbilityTemplate.PrerequisiteAbilities.Find(AbilityTemplate.DataName) != INDEX_NONE)
					{
						bConnectToNextAbility = true;
					}
				}

				Column.SetAvailable(true);
			}

			Column.AS_SetIconState(iAbility - Position, false, AbilityIcon, AbilityName, ButtonState, FGColor, BGColor, bConnectToNextAbility);
		}
		else
		{
			Column.AbilityNames.AddItem(''); // Make sure we add empty spots to the name array for getting ability info
			Column.AbilityIcons[iAbility - Position].Hide();
			Column.InfoButtons[iAbility - Position].Hide();
		}
	}

	// bsg-nlong (1.25.17): Select the first available/visible ability in the column
	while(`ISCONTROLLERACTIVE && !Column.AbilityIcons[Column.m_iPanelIndex].bIsVisible)
	{
		Column.m_iPanelIndex +=1;
		if( Column.m_iPanelIndex >= Column.AbilityIcons.Length )
		{
			Column.m_iPanelIndex = 0;
		}
	}
	// bsg-nlong (1.25.17): end

	return bHasColumnAbility;
}

simulated function RealizeScrollbar()
{
	if(MaxPosition > NUM_ABILITIES_PER_COLUMN)
	{
		if(Scrollbar == none)
			Scrollbar = Spawn(class'UIScrollbar', self).InitScrollbar();
		Scrollbar.SetAnchor(class'UIUtilities'.const.ANCHOR_TOP_RIGHT);
		Scrollbar.SetHeight(450);
		//Scrollbar.SetPosition(-555, 310);
		
		
		Scrollbar.NotifyValueChange(OnScrollBarChange, 0.0, float(MaxPosition) + 0.5);
	}
}

function OnScrollBarChange(float newValue)
{
	local int OldPosition;
	
	OldPosition = Position;

	Position = int(newValue);

	if (OldPosition != Position)
		PopulateData();
}

function InitColumns()
{
	local NPSBDP_UIArmory_PromotionHeroColumn Column;
	Columns.Length = 0;

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn0';
	Column.InitPromotionHeroColumn(0);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn1';
	Column.InitPromotionHeroColumn(1);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn2';
	Column.InitPromotionHeroColumn(2);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn3';
	Column.InitPromotionHeroColumn(3);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn4';
	Column.InitPromotionHeroColumn(4);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn5';
	Column.InitPromotionHeroColumn(5);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn6';
	Column.InitPromotionHeroColumn(6);
	Columns.AddItem(Column);

	Column = Spawn(class'NPSBDP_UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn7';
	Column.InitPromotionHeroColumn(7);
	//Column.SetPosition(1347 - AdjustXOffset, 200);
	//Column.SetPosition(1360 - AdjustXOffset, 200);
	Columns.AddItem(Column);
}

function bool CanPurchaseAbility(int Rank, int Branch, name AbilityName)
{
	local XComGameState_Unit UnitState;
	local int AbilityRanks; //Rank is 0 indexed but AbilityRanks is not. This means a >= comparison requies no further adjustments
	
	UnitState = GetUnit();
	AbilityRanks = GetAbilitiesPerRank(UnitState);

	//Emulate Resistance Hero behaviour
	if(AbilityRanks == 0)
	{		
		return (Rank < UnitState.GetRank() && CanAffordAbility(Rank, Branch) && UnitState.MeetsAbilityPrerequisites(AbilityName));
	}

	//Don't allow non hero units to purchase abilities with AP without a training center
	if(UnitState.HasPurchasedPerkAtRank(Rank) && !UnitState.IsResistanceHero() && !CanSpendAP())
	{
		return false;
	}
		
	//Don't allow non hero units to purchase abilities on the xcom perk row before getting a rankup perk
	if(!UnitState.HasPurchasedPerkAtRank(Rank) && !UnitState.IsResistanceHero() && Branch >= AbilityRanks )
	{
		return false;
	}

	//Normal behaviour
	return (Rank < UnitState.GetRank() && CanAffordAbility(Rank, Branch) && UnitState.MeetsAbilityPrerequisites(AbilityName));
}

function int GetAbilityPointCost(int Rank, int Branch)
{
	local XComGameState_Unit UnitState;
	local array<SoldierClassAbilityType> AbilityTree;
	local bool bPowerfulAbility;
	local int AbilityRanks; //Rank is 0 indexed but AbilityRanks is not. This means a >= comparison requies no further adjustments
	local Name ClassName;
	local int AbilityCost;

	UnitState = GetUnit();
	AbilityTree = UnitState.GetRankAbilities(Rank);	
	bPowerfulAbility = (class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilities.Find(AbilityTree[Branch].AbilityName) != INDEX_NONE);
	AbilityRanks = 2;
	ClassName = UnitState.GetSoldierClassTemplateName();	
	AbilityRanks = GetAbilitiesPerRank(UnitState);


	//Default ability cost
	AbilityCost = class'X2StrategyGameRulesetDataStructures'.default.AbilityPointCosts[Rank];

	//Powerfull ability override ( 25 AP )
	if(bPowerfulAbility && Branch >= AbilityRanks)
	{
		AbilityCost = class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}

	//Custom Class Ability Cost Override
	if( HasCustomAbilityCost(ClassName, AbilityTree[Branch].AbilityName) )
	{
		AbilityCost = GetCustomAbilityCost(ClassName, AbilityTree[Branch].AbilityName);
	}

	if (!UnitState.IsResistanceHero() && AbilityRanks != 0)
	{
		if (!UnitState.HasPurchasedPerkAtRank(Rank) && Branch < AbilityRanks)
		{
			// If this is a base game soldier with a promotion available, ability costs nothing since it would be their
			// free promotion ability if they "bought" it through the Armory
			return 0;
		}
		/*else if (bPowerfulAbility && Branch >= AbilityRanks)
		{
			// All powerful shared AWC abilities for base game soldiers have an increased cost, 
			// excluding any abilities they have in their normal progression tree
			return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
		}*/
	}

	// All Colonel level abilities for emulated Faction Heroes and any powerful XCOM abilities have increased cost for Faction Heroes
	if (AbilityRanks == 0 && (bPowerfulAbility || (Rank >= 6 && Branch < 3)))
	{
		return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}

	// All Colonel level abilities for Faction Heroes and any powerful XCOM abilities have increased cost for Faction Heroes
	if (UnitState.IsResistanceHero() && (bPowerfulAbility || (Rank >= 6 && Branch < 3)))
	{
		return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}
	
	return AbilityCost;
}

function PreviewAbility(int Rank, int Branch)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate, PreviousAbilityTemplate;
	local XComGameState_Unit Unit;
	local array<SoldierClassAbilityType> AbilityTree;
	local string AbilityIcon, AbilityName, AbilityDesc, AbilityHint, AbilityCost, CostLabel, APLabel, PrereqAbilityNames;
	local name PrereqAbilityName;

	// NPSBDP Patch
	Branch += Position;

	Unit = GetUnit();
	
	// Ability cost is always displayed, even if the rank hasn't been unlocked yet
	CostLabel = m_strCostLabel;
	APLabel = m_strAPLabel;
	AbilityCost = string(GetAbilityPointCost(Rank, Branch));
	if (!CanAffordAbility(Rank, Branch))
	{
		AbilityCost = class'UIUtilities_Text'.static.GetColoredText(AbilityCost, eUIState_Bad);
	}
		
	if (!RevealAllAbilities && Rank >= Unit.GetRank())
	{
		AbilityIcon = class'UIUtilities_Image'.const.LockedAbilityIcon;
		AbilityName = class'UIUtilities_Text'.static.GetColoredText(m_strAbilityLockedTitle, eUIState_Disabled);
		AbilityDesc = class'UIUtilities_Text'.static.GetColoredText(m_strAbilityLockedDescription, eUIState_Disabled);

		// Don't display cost information for abilities which have not been unlocked yet
		CostLabel = "";
		AbilityCost = "";
		APLabel = "";
	}
	else
	{		
		AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
		AbilityTree = Unit.GetRankAbilities(Rank);
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityTree[Branch].AbilityName);

		if (AbilityTemplate != none)
		{
			AbilityIcon = AbilityTemplate.IconImage;
			AbilityName = AbilityTemplate.LocFriendlyName != "" ? AbilityTemplate.LocFriendlyName : ("Missing 'LocFriendlyName' for " $ AbilityTemplate.DataName);
			AbilityDesc = AbilityTemplate.HasLongDescription() ? AbilityTemplate.GetMyLongDescription(, Unit) : ("Missing 'LocLongDescription' for " $ AbilityTemplate.DataName);
			AbilityHint = "";

			// Don't display cost information if the ability has already been purchased
			if (Unit.HasSoldierAbility(AbilityTemplate.DataName))
			{
				CostLabel = "";
				AbilityCost = "";
				APLabel = "";
			}
			else if (AbilityTemplate.PrerequisiteAbilities.Length > 0)
			{
				// Look back to the previous rank and check to see if that ability is a prereq for this one
				// If so, display a message warning the player that there is a prereq
				foreach AbilityTemplate.PrerequisiteAbilities(PrereqAbilityName)
				{
					PreviousAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(PrereqAbilityName);
					if (PreviousAbilityTemplate != none && !Unit.HasSoldierAbility(PrereqAbilityName))
					{
						if (PrereqAbilityNames != "")
						{
							PrereqAbilityNames $= ", ";
						}
						PrereqAbilityNames $= PreviousAbilityTemplate.LocFriendlyName;
					}
				}
				PrereqAbilityNames = class'UIUtilities_Text'.static.FormatCommaSeparatedNouns(PrereqAbilityNames);

				if (PrereqAbilityNames != "")
				{
					AbilityDesc = class'UIUtilities_Text'.static.GetColoredText(m_strPrereqAbility @ PrereqAbilityNames, eUIState_Warning) $ "\n" $ AbilityDesc;
				}
			}
		}
		else
		{
			AbilityIcon = "";
			AbilityName = string(AbilityTree[Branch].AbilityName);
			AbilityDesc = "Missing template for ability '" $ AbilityTree[Branch].AbilityName $ "'";
			AbilityHint = "";
		}		
	}	
	AS_SetDescriptionData(AbilityIcon, AbilityName, AbilityDesc, AbilityHint, CostLabel, AbilityCost, APLabel);
}

simulated function ConfirmAbilitySelection(int Rank, int Branch)
{
	local XGParamTag LocTag;
	local TDialogueBoxData DialogData;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<SoldierClassAbilityType> AbilityTree;
	local string ConfirmAbilityText;
	local int AbilityPointCost;

	// NPSBDP Patch
	Branch += Position;

	PendingRank = Rank;
	PendingBranch = Branch;

	Movie.Pres.PlayUISound(eSUISound_MenuSelect);

	DialogData.eType = eDialog_Alert;
	DialogData.bMuteAcceptSound = true;
	DialogData.strTitle = m_strConfirmAbilityTitle;
	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNO;
	DialogData.fnCallback = ComfirmAbilityCallback;

	AbilityTree = GetUnit().GetRankAbilities(Rank);
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityTree[Branch].AbilityName);
	AbilityPointCost = GetAbilityPointCost(Rank, Branch);
	
	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	LocTag.StrValue0 = AbilityTemplate.LocFriendlyName;
	LocTag.IntValue0 = AbilityPointCost;
	ConfirmAbilityText = `XEXPAND.ExpandString(m_strConfirmAbilityText);

	// If the unit cannot afford the ability on their own, display a warning about spending Shared AP
	if (AbilityPointCost > GetUnit().AbilityPoints)
	{
		LocTag.IntValue0 = AbilityPointCost - GetUnit().AbilityPoints;

		if((AbilityPointCost - GetUnit().AbilityPoints) == 1)
			ConfirmAbilityText $= "\n\n" $ `XEXPAND.ExpandString(m_strSharedAPWarningSingular);
		else
			ConfirmAbilityText $= "\n\n" $ `XEXPAND.ExpandString(m_strSharedAPWarning);

	}

	DialogData.strText = ConfirmAbilityText;
	Movie.Pres.UIRaiseDialog(DialogData);
}

//New functions
simulated function string GetPromotionBlueprintTag(StateObjectReference UnitRef)
{
	local int i;
	local XComGameState_Unit UnitState;

	for(i = 0; i < AfterActionScreen.XComHQ.Squad.Length; ++i)
	{
		if(AfterActionScreen.XComHQ.Squad[i].ObjectID == UnitRef.ObjectID)
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AfterActionScreen.XComHQ.Squad[i].ObjectID));
			
			if (UnitState.IsGravelyInjured())
			{
				return AfterActionScreen.UIBlueprint_PrefixHero_Wounded $ i;
			}
			else
		
			{
				return AfterActionScreen.UIBlueprint_PrefixHero $ i;
			}						
		}
	}

	return "";
}

function bool CanSpendAP()
{
	if(APRequiresTrainingCenter == false)
		return true;
	
	return `XCOMHQ.HasFacilityByName('RecoveryCenter');
}

function int GetAbilitiesPerRank(XComGameState_Unit UnitState)
{
	local Name ClassName;
    local int AbilitiesPerRank, RankIndex;
	local bool bAWC;
	local X2SoldierClassTemplate ClassTemplate;

	ClassName = UnitState.GetSoldierClassTemplateName();	

	if( HasCustomAbilitiesPerRank(ClassName) )
	{
		return GetCustomAbilitiesPerRank(ClassName);
	}

	ClassTemplate = UnitState.GetSoldierClassTemplate();
	bAWC = ClassTemplate.bAllowAWCAbilities;

	for(RankIndex = 1; RankIndex < ClassTemplate.GetMaxConfiguredRank(); RankIndex++)
	{
		if(ClassTemplate.GetAbilitySlots(RankIndex).Length > AbilitiesPerRank)
		{
			AbilitiesPerRank = ClassTemplate.GetAbilitySlots(RankIndex).Length;
		}
	}
	
	if(bAWC && AbilitiesPerRank == 4)
	{
		return 3;
	}

	return AbilitiesPerRank;
}

function bool HasCustomAbilitiesPerRank(name ClassName)
{
	local int i;

	for(i = 0; i < ClassAbilitiesPerRank.Length; ++i)
	{				
		if(ClassAbilitiesPerRank[i].ClassName == ClassName)
		{
			return true;
		}
	}

	return false;
}

function int GetCustomAbilitiesPerRank(name ClassName)
{
	local int i;

	for(i = 0; i < ClassAbilitiesPerRank.Length; ++i)
	{
		if(ClassAbilitiesPerRank[i].ClassName == ClassName)
		{
			return ClassAbilitiesPerRank[i].AbilitiesPerRank;
		}
	
	}
	return 2;
}

function bool HasCustomAbilityCost(name ClassName, name AbilityName)
{
	local int i;

	for(i = 0; i < ClassCustomAbilityCost.Length; ++i)
	{				
		if(ClassCustomAbilityCost[i].ClassName == ClassName && ClassCustomAbilityCost[i].AbilityName == AbilityName)
		{
			return true;
		}
	}

	return false;
}

function int GetCustomAbilityCost(name ClassName, name AbilityName)
{
	local int i;

	for(i = 0; i < ClassCustomAbilityCost.Length; ++i)
	{
		if(ClassCustomAbilityCost[i].ClassName == ClassName && ClassCustomAbilityCost[i].AbilityName == AbilityName)
		{
			return ClassCustomAbilityCost[i].AbilityCost;
		}
	
	}
	return 10;
}

defaultproperties
{
	AdjustXOffset = 130
}