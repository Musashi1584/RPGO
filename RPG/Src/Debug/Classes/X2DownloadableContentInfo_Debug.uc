class X2DownloadableContentInfo_Debug extends X2DownloadableContentInfo;

exec function DebugGamestates()
{
	local XComGameState_BaseObject GameState, ParentGameState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_BaseObject', GameState)
	{
		`LOG(GameState.SummaryString() @ "ComponentObjectIds" @ GameState.ComponentObjectIds.Length @ "bTacticalTransient" @ GameState.bTacticalTransient @ "bRemoved" @ GameState.bRemoved,, 'DebugGamestates');

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