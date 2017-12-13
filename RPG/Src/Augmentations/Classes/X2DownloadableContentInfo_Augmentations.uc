class X2DownloadableContentInfo_Augmentations extends X2DownloadableContentInfo
	config(Augmentations);

struct SocketReplacementInfo
{
	var name TorsoName;
	var string SocketMeshString;
	var bool Female;
};

var config array<SocketReplacementInfo> SocketReplacements;


static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local SocketReplacementInfo SocketReplacement;
	local name TorsoName;
	local bool bIsFemale;
	local string DefaultString, ReturnString;
	local XComHumanPawn HumanPawn;

	`LOG("DLCAppendSockets" @ Pawn,, 'LegendaryGear');

	HumanPawn = XComHumanPawn(Pawn);
	if (HumanPawn == none) { return ""; }

	TorsoName = HumanPawn.m_kAppearance.nmTorso;
	bIsFemale = HumanPawn.m_kAppearance.iGender == eGender_Female;

	`LOG("DLCAppendSockets: Torso= " $ TorsoName $ ", Female= " $ string(bIsFemale),, 'LegendaryGear');

	foreach default.SocketReplacements(SocketReplacement)
	{
		if (TorsoName != 'None' && TorsoName == SocketReplacement.TorsoName && bIsFemale == SocketReplacement.Female)
		{
			ReturnString = SocketReplacement.SocketMeshString;
			break;
		}
		else
		{
			if (SocketReplacement.TorsoName == 'Default' && SocketReplacement.Female == bIsFemale)
			{
				DefaultString = SocketReplacement.SocketMeshString;
			}
		}
	}
	if (ReturnString == "")
	{
		// did not find, so use default
		ReturnString = DefaultString;
	}
	`LOG("Returning mesh string: " $ ReturnString,, 'LegendaryGear');

	return ReturnString;
}