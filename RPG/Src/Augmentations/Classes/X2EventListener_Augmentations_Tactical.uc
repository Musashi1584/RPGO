class X2EventListener_Augmentations_Tactical extends X2EventListener config (Augmentations);

var const localized string CyborgBerserk;
var protected const config WillEventRollData AugmentationWillRollData;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateUnitTookDamageTemplate());

	return Templates;
}


static function X2EventListenerTemplate CreateUnitTookDamageTemplate()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'UnitTookDamage');

	Template.RegisterInTactical = true;
	Template.AddEvent('UnitTakeEffectDamage', OnUnitTookDamage);

	return Template;
}


static protected function EventListenerReturn OnUnitTookDamage(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit WoundedUnit;
	local XComGameStateContext_WillRoll WillRollContext;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	WoundedUnit = XComGameState_Unit(EventSource);
	`assert(WoundedUnit != none);

	if (!class'X2Condition_Cyborg'.static.IsCyborg(WoundedUnit))
	{
		return ELR_NoInterrupt;
	}

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	if( XComHQ.Squad.Find('ObjectID', WoundedUnit.ObjectID) != INDEX_NONE )
	{
		if( class'XComGameStateContext_WillRoll'.static.ShouldPerformWillRoll(default.AugmentationWillRollData, WoundedUnit) )
		{
			WillRollContext = class'XComGameStateContext_WillRoll'.static.CreateWillRollContext(WoundedUnit, 'UnitTookDamage', default.CyborgBerserk);
			WillRollContext.DoWillRoll(default.AugmentationWillRollData, WoundedUnit);
			WillRollContext.Submit();
		}
	}

	return ELR_NoInterrupt;
}