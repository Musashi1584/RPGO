class X2DownloadableContentInfo_ExtendedUpgrades extends X2DownloadableContentInfo;

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	class'TemplateHelper'.static.PatchTemplates();
	class'TemplateHelper'.static.ReconfigDefaultAttachments();
	class'TemplateHelper'.static.AddLootTables();
}
