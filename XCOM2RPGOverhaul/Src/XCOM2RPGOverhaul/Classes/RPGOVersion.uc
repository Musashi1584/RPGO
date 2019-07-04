class RPGOVersion extends X2StrategyElement;

var int MajorVersion;
var int MinorVersion;
var int PatchVersion;
var string Commit;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2StrategyElementTemplate Version;

	if (class'RPGOVersionTemplate' != none)
	{
		`CREATE_X2TEMPLATE(class'RPGOVersionTemplate', Version, 'RPGOVersion');
		RPGOVersionTemplate(Version).MajorVersion = default.MajorVersion;
		RPGOVersionTemplate(Version).MinorVersion = default.MinorVersion;
		RPGOVersionTemplate(Version).PatchVersion = default.PatchVersion;
		RPGOVersionTemplate(Version).Commit = default.Commit;

		Templates.AddItem(Version);
	}

	return Templates;
}

// AUTO-CODEGEN: Version-Info
defaultproperties
{
    MajorVersion = 0;
    MinorVersion = 2;
    PatchVersion = 5;
    Commit = "beta";
}