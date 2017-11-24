class XMBGameState_EventProxy extends XComGameState_BaseObject;

var StateObjectReference SourceRef;
var delegate<ProxyOnEventDelegate> OnEvent;
var bool bTriggerOnceOnly;

delegate EventListenerReturn ProxyOnEventDelegate(XComGameState_BaseObject SourceState, Object EventData, Object EventSource, XComGameState GameState, Name EventID);

function EventListenerReturn EventHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2EventManager EventMgr;
	local XComGameState_BaseObject SourceState;
	local object ListenerObj;

	EventMgr = `XEVENTMGR;
	ListenerObj = self;

	SourceState = GameState.GetGameStateForObjectID(SourceRef.ObjectID);
	if (SourceState == none)
		SourceState = `XCOMHISTORY.GetGameStateForObjectID(SourceRef.ObjectID);

	if (bTriggerOnceOnly)
		EventMgr.UnRegisterFromEvent(ListenerObj, EventID);

	return OnEvent(SourceState, EventData, EventSource, GameState, EventID);
}

static function XMBGameState_EventProxy CreateProxy(XComGameState_BaseObject SourceState, XComGameState NewGameState)
{
	local XComGameState_BaseObject NewSourceState;
	local XMBGameState_EventProxy Proxy;

	Proxy = XMBGameState_EventProxy(NewGameState.CreateStateObject(class'XMBGameState_EventProxy'));
	NewSourceState = NewGameState.CreateStateObject(SourceState.class, SourceState.ObjectID);

	NewSourceState.AddComponentObject(Proxy);

	NewGameState.AddStateObject(NewSourceState);
	NewGameState.AddStateObject(Proxy);
	
	Proxy.SourceRef = NewSourceState.GetReference();

	return Proxy;
}