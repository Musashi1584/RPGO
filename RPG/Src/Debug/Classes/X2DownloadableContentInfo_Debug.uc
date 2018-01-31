class X2DownloadableContentInfo_Debug extends X2DownloadableContentInfo;

exec function DebugGamestates()
{
	CheckGamestates();
}

static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	CheckGamestates();
}

static event ModifyTacticalTransferStartState(XComGameState TransferStartState)
{
	CheckGamestates();
}

static function CheckGamestates()
{
	local XComGameState_BaseObject GameState, ParentGameState;

	`LOG(GetFuncName(),, 'DebugGamestates');

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_BaseObject', GameState)
	{
		`LOG(GameState.SummaryString() @ "OwningObjectId" @ GameState.OwningObjectId @ "ComponentObjectIds" @ GameState.ComponentObjectIds.Length @ "bTacticalTransient" @ GameState.bTacticalTransient @ "bRemoved" @ GameState.bRemoved,, 'DebugGamestates');

		if (GameState.OwningObjectId > INDEX_NONE)
		{
			ParentGameState = `XCOMHISTORY.GetGameStateForObjectID(GameState.OwningObjectId);

			if (ParentGameState == none)
			{
				`LOG("This is bad, could not find parent GS for" @ GameState.SummaryString(),, 'DebugGamestates');
			}
		}
	}
}