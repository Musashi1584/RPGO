class X2EventListener_Augmentations_Strategy extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreatePostMissionUpdateSoldierHealingListenerTemplate());

	return Templates;
}

static function CHEventListenerTemplate CreatePostMissionUpdateSoldierHealingListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'AugmentationsOnPostMissionUpdateSoldierHealing');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('PostMissionUpdateSoldierHealing', OnPostMissionUpdateSoldierHealing, ELD_Immediate);
	`LOG("Register Event OnPostMissionUpdateSoldierHealing",, 'RPG');

	return Template;
}

static function EventListenerReturn OnPostMissionUpdateSoldierHealing(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple			OverrideTuple;
	local XComGameState_Unit	UnitState;
	local int Random;

	OverrideTuple = XComLWTuple(EventData);
	if(OverrideTuple == none)
	{
		`REDSCREEN("OnPostMissionUpdateSoldierHealing event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(EventSource);

	// Prevent gravely units from healing and randomly determine a severed body part that needs to be augmented
	if (UnitState != none && UnitState.IsGravelyInjured())
	{
		Random = Rand(3);

		if ((Random == eHead && UnitState.GetItemInSlot(eInvSlot_AugmentationHead) == none) ||
			(Random == eTorso && UnitState.GetItemInSlot(eInvSlot_AugmentationTorso) == none) ||
			(Random == eArms && UnitState.GetItemInSlot(eInvSlot_AugmentationArms) == none) ||
			(Random == eLegs && UnitState.GetItemInSlot(eInvSlot_AugmentationLegs) == none))
		{
			OverrideTuple.Data[0].b = false;
			`LOG(GetFuncName() @ "SeveredBodyPart" @ GetEnum(Enum'ESeveredBodyPart', Random),,'Augmentations');
			UnitState = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.SetUnitFloatValue('SeveredBodyPart', float(Random), eCleanup_Never);
			
		}
	}

	return ELR_NoInterrupt;
}