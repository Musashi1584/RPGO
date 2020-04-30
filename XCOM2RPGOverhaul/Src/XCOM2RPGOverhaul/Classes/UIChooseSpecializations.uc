class UIChooseSpecializations extends UIChooseCommodity dependson(X2SoldierClassTemplatePlugin);

var UIStartingAbilitiesIconList StartingAbilities;
var array<SoldierSpecialization> SpecializationsPool;
var array<SoldierSpecialization> SpecializationsChosen;
var array<int> SelectedItems;

var localized string m_strComplementarySpecializationInfo;

simulated function InitChooseSpecialization(
	StateObjectReference UnitRef,
	int MaxSpecs,
	array<SoldierSpecialization> AvailableSpecs,
	array<SoldierSpecialization> OwnedSpecs,
	optional delegate<AcceptAbilities> OnAccept
)
{
	super.InitChooseCommoditiesScreen(
		UnitRef,
		MaxSpecs,
		ConvertToCommodities(OwnedSpecs),
		OnAccept
	);

	SpecializationsPool.Length = 0;
	SpecializationsPool = AvailableSpecs;
	CommodityPool = ConvertToCommodities(SpecializationsPool);

	SpecializationsChosen.Length = 0;
	SpecializationsChosen = OwnedSpecs;
	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);

	PopulateData();

	StartingAbilities = Spawn(class'UIStartingAbilitiesIconList', `HQPRES.m_kAvengerHUD);
	StartingAbilities.InitStartingAbilitiesIconList('SoldierStartingAbilities',, GetUnit());
	StartingAbilities.SetX((Movie.UI_RES_X - StartingAbilities.StartingAbiltiesBG.Width) / 2);
	StartingAbilities.SetY(Movie.UI_RES_Y - 225);
	StartingAbilities.CenterIcons();
	Navigator.AddControl(StartingAbilities);
}

simulated function CloseScreen()
{
	StartingAbilities.Remove();
	super.CloseScreen();
}

simulated Function Hide()
{
	Super.Hide();
	StartingAbilities.Hide();
}

simulated function Show()
{
	super.Show();
	StartingAbilities.Show();
}

simulated function OnContinueButtonClick()
{
	local UIArmory_PromotionHero HeroScreen;

	if (CommoditiesChosen.Length - OwnedItems.Length >= MaxChooseItem)
	{
		OnAllSpecSelected();
		
		CloseScreen();
		HeroScreen = UIArmory_PromotionHero(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_PromotionHero'));
		if (HeroScreen != none)
		{
			HeroScreen.CycleToSoldier(UnitReference);
		}
	}
	else
	{
		PlayNegativeSound();
	}
}

function bool OnAllSpecSelected()
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local array<int> SpecIndices;
	local int SpecIndex;
	local SoldierSpecialization Spec;
	
	UnitState = GetUnit();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Ranking up Unit in chosen specs");

	foreach SpecializationsChosen(Spec)
	{
		SpecIndex = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationIndex(UnitState, Spec.TemplateName);
		SpecIndices.AddItem(SpecIndex);
	}

	class'X2SecondWaveConfigOptions'.static.BuildSpecAbilityTree(
		UnitState, SpecIndices,
		true,
		`SecondWaveEnabled('RPGOTrainingRoulette')
	);
	
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
	UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceSpecChosen', 1, eCleanup_Never);

	//	If weapon restrictions are enabled, equip the soldier with new weapons, according to newly-acquired specializations.
	if (`SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		`LOG("Weapon Restrictions: equipping new weapons on soldier:" @ UnitState.GetFullname() @ getfuncname(),, 'RPG');
		class'X2EventListener_RPG_StrategyListener'.static.WeaponRestrictions_EquipNewWeaponsOnSoldier(UnitState.ObjectID, NewGameState);
	}
	
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);

	if (AcceptAbilities != none)
	{
		AcceptAbilities(self);
	}

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("StrategyUI_Recruit_Soldier");
	
	return true;
}

simulated function array<Commodity> ConvertToCommodities(array<SoldierSpecialization> Specializations)
{
	local SoldierSpecialization Spec;
	local int i;
	local array<Commodity> Commodities;
	local Commodity Comm;
	local X2UniversalSoldierClassInfo Template;

	for (i = 0; i < Specializations.Length; i++)
	{
		Spec = Specializations[i];
		
		Template = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplate(Spec);
		
		Comm.Title = Template.GetClassSpecializationTitleWithMetaData();
		Comm.Image = Template.ClassSpecializationIcon;
		Comm.Desc = GetComplementarySpecializationInfo(Template) $ "\n" $
			Template.ClassSpecializationSummary;
		Comm.OrderHours = -1;
		
		//Comm.OrderHours = class'SpecialTrainingUtilities'.static.GetSpecialTrainingDays() * 24;

		Commodities.AddItem(Comm);
	}

	return Commodities;
}

simulated function string GetComplementarySpecializationInfo(X2UniversalSoldierClassInfo Template)
{
	local string Info;
	Info = Template.GetComplementarySpecializationInfo();

	if (Info != "")
	{
		Info = m_strComplementarySpecializationInfo $ "\n" $ Info;
	}

	return Info;
}

simulated function PopulateChosen()
{
	super.PopulateChosen();
	UIInventory_SpecializationListItem(ChosenList.GetSelectedItem()).iUpdateColor = 6;
}

simulated function AddToChosenList(int Index)
{
	local array<SoldierSpecialization> ComplementarySpecializations;
	local SoldierSpecialization ComplementarySpecialization;
	local XComGameState_Unit UnitState;
	
	UnitState = GetUnit();
	
	SelectedItems.AddItem(Index);
	SpecializationsChosen.AddItem(SpecializationsPool[Index]);
	
	ComplementarySpecializations = class'X2SoldierClassTemplatePlugin'.static.GetComplementarySpecializations(
		UnitState,
		SpecializationsPool[Index]
	);

	if (ComplementarySpecializations.Length > 0)
	{
		foreach ComplementarySpecializations(ComplementarySpecialization)
		{
			SelectedItems.AddItem(GetSpecIndex(ComplementarySpecialization));
			SpecializationsChosen.AddItem(ComplementarySpecialization);
		}
	}

	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);
}

simulated function RemoveFromChosenList(int ChosenIndex, int PoolIndex)
{
	local array<SoldierSpecialization> ComplementarySpecializations;
	local SoldierSpecialization ComplementarySpecialization;
	local XComGameState_Unit UnitState;
	
	UnitState = GetUnit();

	SelectedItems.RemoveItem(PoolIndex);
	SpecializationsChosen.RemoveItem(SpecializationsChosen[ChosenIndex]);

	ComplementarySpecializations = class'X2SoldierClassTemplatePlugin'.static.GetComplementarySpecializations(
		UnitState,
		SpecializationsPool[PoolIndex]
	);

	if (ComplementarySpecializations.Length > 0)
	{
		foreach ComplementarySpecializations(ComplementarySpecialization)
		{
			SelectedItems.RemoveItem(GetSpecIndex(ComplementarySpecialization));
			SpecializationsChosen.RemoveItem(ComplementarySpecialization);
		}
	}

	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);
}

simulated function int GetSpecIndex(SoldierSpecialization Spec)
{
	return SpecializationsPool.Find('TemplateName', Spec.TemplateName);
}

simulated function UpdateNavHelp()
{
	Super.UpdateNavHelp();
	`HQPRES.m_kAvengerHUD.NavHelp.AddLeftHelp(class'UIArmory_Promotion'.default.m_strInfo, class'UIUtilities_Input'.static.GetGamepadIconPrefix() $class'UIUtilities_Input'.const.ICON_DPAD_HORIZONTAL);
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;
	// Only pay attention to presses or repeats; ignoring other input types
	// NOTE: Ensure repeats only occur with arrow keys

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_L3 :
			Navigator.SetSelected(StartingAbilities);
			PoolList.OnLoseFocus();
			ChosenList.OnLoseFocus();
			PlaySound( SoundCue'SoundUI.MenuScrollCue', true );
			if(ShowSelect != false)
			{
				ShowSelect = false;
				UpdateNavHelp();
			}
			bHandled = true;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

function bool SwitchList(UIList ToList, UIList FromList, optional bool UISound=true)
{
	if(Super.SwitchList(ToList, FromList, UISound))
	{
		StartingAbilities.OnLoseFocus();
		return true;
	}
	return false;
}

defaultproperties
{
	ListItemClass = class'UIInventory_SpecializationListItem'
	ConfirmButtonOffset = 146
}
