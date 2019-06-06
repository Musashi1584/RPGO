class RPGOVersionTemplate extends X2StrategyElementTemplate;

var int MajorVersion;
var int MinorVersion;
var int PatchVersion;

var string Commit;

var localized string strRPGOVersion;

// "Short" version number (minus the patch)
function String GetShortVersionString()
{
    return MajorVersion $ "." $ MinorVersion;
}

// Version number in string format.
function String GetVersionString()
{
    return MajorVersion $ "." $ MinorVersion $ "." $ PatchVersion;
}

// Version number in comparable numeric format. Number in decimal is MMmmmmPPPP where:O
// "M" is major version
// "m" is minor version
// "P" is patch number
//
// Allows for approx. 2 digits of major, 4 digits of minor versions and 9,999 builds before overflowing.
//
// Optional params take individual components of the version
//
// Note: build number currently disabled and is always 0.
function int GetVersionNumber()
{
    return (MajorVersion * 100000000) + (MinorVersion * 10000) + (PatchVersion);
}

function string GetSemanticVersionString()
{
	local string VersionString;

	VersionString = strRPGOVersion;

	VersionString = Repl(VersionString, "%MAJOR", MajorVersion);
	VersionString = Repl(VersionString, "%MINOR", MinorVersion);
	VersionString = Repl(VersionString, "%PATCH", PatchVersion);

	if (Commit != "")
	{
		VersionString @= "(" $ Commit $ ")";
	}
	return VersionString;
}
// AUTO-CODEGEN: Version-Info
defaultproperties
{
    MajorVersion = 0
    MinorVersion = 0
    PatchVersion = 0
	Commit = "";
}
