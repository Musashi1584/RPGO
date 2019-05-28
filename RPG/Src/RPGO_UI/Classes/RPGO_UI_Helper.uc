class RPGO_UI_Helper extends Object config(Null);

var config array<string> RequiredModsMissing;
var config array<string> RequiredModsLoaded;
var config array<string> IncompatibleModsLoaded;

static function array<string> GetIncompatibleMods()
{
	local string IncompatibleMod;

	if (default.IncompatibleModsLoaded.Length > 0)
	{
		return default.IncompatibleModsLoaded;
	}

	foreach class'X2DownloadableContentInfo_XCOM2RPGOverhaul'.default.IncompatibleMods(IncompatibleMod)
	{
		if (IsDLCInstalled(name(IncompatibleMod)))
		{
			default.IncompatibleModsLoaded.AddItem(IncompatibleMod);
		}
	}
	return default.IncompatibleModsLoaded;
}

static function array<string> GetRequiredModsMissing()
{
	if (default.RequiredModsMissing.Length > 0)
	{
		return default.RequiredModsMissing;
	}

	CacheRequiredMods();

	return default.RequiredModsMissing;
}

static function array<string> GetRequiredModsLoaded()
{
	if (default.RequiredModsLoaded.Length > 0)
	{
		return default.RequiredModsLoaded;
	}

	CacheRequiredMods();

	return default.RequiredModsLoaded;
}

static function CacheRequiredMods()
{
	local string RequiredMod;

	default.RequiredModsMissing.Length = 0;
	default.RequiredModsLoaded.Length = 0;
	foreach class'X2DownloadableContentInfo_XCOM2RPGOverhaul'.default.RequiredMods(RequiredMod)
	{
		if (!IsDLCInstalled(name(RequiredMod)))
		{
			 default.RequiredModsMissing.AddItem(RequiredMod);
		}
		else
		{
			default.RequiredModsLoaded.AddItem(RequiredMod);
		}
	}
}


static function bool IsDLCInstalled(name DLCName)
{
	local XComOnlineEventMgr EventManager;
	local int i;
		
	EventManager = `ONLINEEVENTMGR;
	for(i = 0; i < EventManager.GetNumDLC(); ++i)
	{
		if (DLCName == EventManager.GetDLCNames(i))
		{
			return true;
		}
	}
	return false;
}


function static string Join(array<string> StringArray, optional string Delimiter = ",", optional bool bIgnoreBlanks = true)
{
	local string Result;

	JoinArray(StringArray, Result, Delimiter, bIgnoreBlanks);

	return Result;
}


function static string MakeBulletList(array<string> List)
{
	local string TipText;
	local int i;

	TipText = "<ul>";
	for(i=0; i<List.Length; i++)
	{
		TipText $= "<li>" $ List[i] $ "</li>";
	}
	TipText $= "</ul>";
	
	return TipText;
}