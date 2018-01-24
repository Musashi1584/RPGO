class X2EventListener_Debug extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateOnTacticalBeginPlayTemplate());

	return Templates;
}


static function CHEventListenerTemplate CreateOnTacticalBeginPlayTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'DEBUGOnTacticalBeginPlay');

	Template.RegisterInTactical = true;

	Template.AddCHEvent('OnTacticalBeginPlay', OnTacticalBeginPlay, ELD_OnStateSubmitted);
	`LOG("Register Event OnTacticalBeginPlay",, 'RPG');

	return Template;
}

static function EventListenerReturn OnTacticalBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	`LOG(GetFuncName() @ "FirstSeenVODisabled",, 'RPG');
	`CHEATMGR.SetFirstSeenVODisabled(true);
	return ELR_NoInterrupt;
}