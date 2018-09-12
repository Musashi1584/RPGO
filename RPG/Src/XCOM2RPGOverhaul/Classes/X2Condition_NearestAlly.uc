class X2Condition_NearestAlly extends X2Condition;

var bool bBeyond;
var int TileDistance;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit Unit, TestAlly;
	local XComUnitPawn	TestAllyPawn;
	local XGUnit TestAllyVisualizer;

	Unit = XComGameState_Unit(kTarget);

	if (Unit == none)
		return 'AA_NotAUnit';

	foreach `XCOMHISTORY.IterateByClassType (class'XComGameState_Unit', TestAlly)
	{
		// Found a unit that doesn't exist or is self, keep looking
		if (TestAlly == none) { continue; }
		if (Unit == TestAlly) { continue; }

		// Can we visualize this unit?
		TestAllyVisualizer = XGUnit(TestAlly.GetVisualizer());
		if (TestAllyVisualizer == none) { continue; }

		// Is this unit knocked out/on my team, and if so, within range?
		TestAllyPawn = TestAllyVisualizer.GetPawn();
		if (TestAllyPawn == none) { continue; }
		if (TestAlly.IsAlive() &&
			!TestAlly.GetMytemplate().bIsCosmetic)
		{
			if (!TestAlly.bRemovedFromPlay)
			{
				if (!TestAlly.IsBleedingOut())
				{
					if (Unit.GetTeam() == TestAlly.GetTeam())
					{						
						if (bBeyond){
							if (Unit.TileDistanceBetween(TestAlly) < TileDistance + 1)								
								return 'AA_NearestAllyTooClose';			
						}	
						
						if (!bBeyond){
							if (Unit.TileDistanceBetween(TestAlly) > TileDistance)								
								return 'AA_NearestAllyTooFar';
						}
							
					}
				}
			}
		}
	}

	return 'AA_Success';
}