//-----------------------------------------------------------
//	Class:	JsonConfig_EventListener
//	Author: Musashi
//	EventListener for tag value calculation
//-----------------------------------------------------------
class JsonConfig_EventListener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'ConfigListenerTemplate');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('ConfigTagFunction', OnTagValue, ELD_Immediate);
	`LOG("Register Event ConfigTagFunction",, 'RPG');

	return Template;
}

static function EventListenerReturn OnTagValue(Object EventData, Object EventSource, XComGameState GameState, Name EventName, Object CallbackData)
{
	local LWTuple Tuple;
	local JsonConfig_TaggedConfigProperty Prop;
	local int Value;
	local array<string> ArrayValue;

	Tuple = LWTuple(EventData);
	Prop = JsonConfig_TaggedConfigProperty(EventSource);

	switch (Tuple.Id)
	{
		case 'TagValueToPercent':
			Value = int(float(Prop.GetValue()) * 100);
			break;
		case 'TagValueToPercentMinusHundred':
			Value = int(float(Prop.GetValue()) * 100 - 100);
			break;
		case 'TagValueMetersToTiles':
			Value = int(float(Prop.GetValue()) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize);
			break;
		case 'TagValueTilesToMeters':
			Value = int(float(Prop.GetValue()) * class'XComWorldData'.const.WORLD_StepSize / class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER);
			break;
		case 'TagValueTilesToUnits':
			`LOG(default.class @ GetFuncName() @ int(Prop.GetValue()) @ class'XComWorldData'.const.WORLD_StepSize,, 'RPG');
			Value = int(float(Prop.GetValue()) * class'XComWorldData'.const.WORLD_StepSize);
			break;
		case 'TagValueLockDown':
			 Value = int(Prop.GetValue()) / (1 - class'X2AbilityToHitCalc_StandardAim'.default.REACTION_FINALMOD);
			 break;
		case 'TagValueParamAddition':
			 Value = int(float(Prop.GetValue()) + float(Prop.GetTagParam()));
			 break;
		case 'TagValueParamMultiplication':
			 Value = int(float(Prop.GetValue()) * float(Prop.GetTagParam()));
			 break;
		case 'TagArrayValue':
			ArrayValue = Prop.GetArrayValue();
			Tuple.Data[0].s = ArrayValue[int(Prop.GetTagParam())];
			return ELR_NoInterrupt;
			break;
		default:
			break;
	}

	Tuple.Data[0].s = string(Value);

	return ELR_NoInterrupt;
}
