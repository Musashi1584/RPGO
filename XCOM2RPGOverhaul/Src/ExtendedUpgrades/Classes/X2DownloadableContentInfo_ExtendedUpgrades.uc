class X2DownloadableContentInfo_ExtendedUpgrades extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	if (class'TemplateHelper'.default.bReconfigureVanillaAttachements)
	{
		class'TemplateHelper'.static.PatchTemplates();
		class'TemplateHelper'.static.ReconfigDefaultAttachments();
	}

	if (class'TemplateHelper'.static.IsModInstalled('X2DownloadableContentInfo_X2WOTCCommunityHighlander'))
	{
		class'TemplateHelper'.static.AddLootTables();
	}
}
