class X2DownloadableContentInfo_ExtendedUpgrades extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	if (class'TemplateHelper'.default.bReconfigureVanillaAttachements)
	{
		class'TemplateHelper'.static.PatchTemplates();
		class'TemplateHelper'.static.ReconfigDefaultAttachments();
	}

	class'TemplateHelper'.static.AddLootTables();
}
