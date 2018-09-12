class X2Condition_MissionData extends X2Condition;

//Plots
var() array<string> AllowedPlots;

//MissionTypes
var bool bRecovery, bHack, bSabotage, bNeutralize, bDefend, bRescue, bSupply, bTrain, bVehicle;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_BattleData BattleData;
	local string CurrentMission;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	CurrentMission = BattleData.MapData.ActiveMission.sType;

	if (AllowedPlots.Length > 0)
	{
		if (AllowedPlots.Find(BattleData.PlotType) != INDEX_NONE)
			return 'AA_Success';
	}

	if (bRecovery)
	{	
		//Recover
		//Recover_ADV
		//Recover_Train
		//Recover_Vehicle
		//Recover_FlightDevice
		if(StringContains(CurrentMission, "Recover"))
			return 'AA_Success';
	}

	if (bHack)
	{	
		//Hack
		//Hack_ADV
		//Hack_Train
		if(StringContains(CurrentMission, "Hack"))
			return 'AA_Success';
	}

	if (bDefend)
	{
		//ProtectDevice
		//ChosenRetaliation
		//DefaultTerror
		//DefaultAvengerDefense
		//SwarmDefense
		if(StringContains(CurrentMission, "Protect") || StringContains(CurrentMission, "Terror") || StringContains(CurrentMission, "Retaliation") || StringContains(CurrentMission, "Defense")) 
			return 'AA_Success';
	}
	
	if (bSabotage)
	{
		//DESTROY/SABOTAGE
		//DefaultDestroyRelay
		//DefaultSabotage
		//DefaultSabotageCC
		//SabotageTransmitter
		if(StringContains(CurrentMission, "Sabotage") || StringContains(CurrentMission, "DestroyRelay") || StringContains(CurrentMission, "GP")) 
			return 'AA_Success';
	}

	if (bSupply)
	{
		//DefaultSupplyRaidATT
		//DefaultSupplyRaidTrain
		//DefaultSupplyRaidConvoy
		//SupplyExtraction
		if(StringContains(CurrentMission, "Supply"))
			return 'AA_Success';
	}

	if (bNeutralize)
	{
		//DefaultNeutralizeTarget
		//DefaultNeutralizeVehicle
		//NeutralizeFieldCommander
		if(StringContains(CurrentMission, "Neutralize"))
			return 'AA_Success';
	}

	if (bRescue)
	{
		//DefaultExtract
		//DefaultRescue_AdventCell
		//DefaultRescue_Vehicle
		//CompoundRescueOperative
		//RecoverExpedition
		//CovertEscape

		if(StringContains(CurrentMission, "Rescue") || StringContains(CurrentMission, "RecoverExpedition") || StringContains(CurrentMission, "Escape") || StringContains(CurrentMission, "Extract"))
			return 'AA_Success';
	}

	if (bVehicle)
	{
		if(StringContains(CurrentMission, "Vehicle") || StringContains(CurrentMission, "Train"))
			return 'AA_Success';
	}

	//Nothing  matched
	return 'AA_Invalid_Mission_Parameters';
}

function bool StringContains(string a, string b){

	`LOG( InStr(Caps(a), Caps(b)) );

	return InStr(Caps(a), Caps(b)) != INDEX_NONE;

}