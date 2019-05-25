class X2Effect_Silencer extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	//local X2EventManager EventMgr;
	//local XComGameState_Unit UnitState;
	//local Object EffectObj;
	//
	//EventMgr = `XEVENTMGR;
	//
	//EffectObj = EffectGameState;
	//UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	//
	//EventMgr.RegisterForEvent(EffectObj, 'RetainConcealmentOnActivation', OnRetainConcealmentOnActivation, ELD_Immediate, , EffectGameState);
}

function EventListenerReturn OnRetainConcealmentOnActivation(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	//local XComGameState_Effect EffectGameState;
	//local XComGameStateContext_Ability AbilityContext;
	//local XComGameState_Ability AbilityState;
	//local XComLWTuple Tuple;
	//local XComGameState_Unit UnitState;
	//local UnitValue UsesStealthOverhaul;
	//local bool bRetainConcealment;
	//
	//EffectGameState = XComGameState_Effect(CallbackData);
	//Tuple = XComLWTuple(EventData);
	//AbilityContext = XComGameStateContext_Ability(EventSource);
	//AbilityState = XComGameState_Ability(GameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	//UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	//
	//if (EffectGameState == none || EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID != UnitState.ObjectID)
	//{
	//	return ELR_NoInterrupt;
	//}
	//
	//bRetainConcealment = Tuple.Data[0].b;
	//
	//// TODO
	//if (!bRetainConcealment)
	//{
	//	Tuple.Data[0].b = true;
	//	EventSource = Tuple;
	//}
	//
	//return ELR_NoInterrupt;
}