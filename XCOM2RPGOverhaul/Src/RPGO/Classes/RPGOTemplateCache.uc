//-----------------------------------------------------------
//	Class:	RPGOTemplateCache
//	Author: Musashi
//	Cache template if the need to be restored for config changes
//-----------------------------------------------------------
class RPGOTemplateCache extends Object;

var array <X2DataTemplate> Templates;

public static function RPGOTemplateCache GetRPGOTemplateCache()
{
	return RPGOTemplateCache(class'Engine'.static.FindClassDefaultObject(string(default.class)));
}

public static function AddWeaponUpgradeTemplate(X2WeaponUpgradeTemplate Template)
{
	local RPGOTemplateCache TemplateCache;
	local X2WeaponUpgradeTemplate ClonedTemplate;

	TemplateCache = GetRPGOTemplateCache();

	if (GetWeaponTemplate(Template.DataName) == none)
	{
		ClonedTemplate = new Template.Class (Template);
		ClonedTemplate.SetTemplateName(name(Template.DataName $ "_Cache"));
		TemplateCache.Templates.AddItem(ClonedTemplate);
	}
}

public static function X2WeaponUpgradeTemplate GetWeaponUpgradeTemplate(name DataName)
{
	local RPGOTemplateCache TemplateCache;
	local X2DataTemplate Template;

	TemplateCache = GetRPGOTemplateCache();

	foreach TemplateCache.Templates(Template)
	{
		if (Template.DataName == name(DataName $ "_Cache"))
		{
			return X2WeaponUpgradeTemplate(Template);
		}
	}

	return none;
}

public static function AddWeaponTemplate(X2WeaponTemplate Template)
{
	local RPGOTemplateCache TemplateCache;
	local X2WeaponTemplate ClonedTemplate;

	TemplateCache = GetRPGOTemplateCache();

	if (GetWeaponTemplate(Template.DataName) == none)
	{
		ClonedTemplate = new Template.Class (Template);
		ClonedTemplate.SetTemplateName(name(Template.DataName $ "_Cache"));
		TemplateCache.Templates.AddItem(ClonedTemplate);
	}
}

public static function X2WeaponTemplate GetWeaponTemplate(name DataName)
{
	local RPGOTemplateCache TemplateCache;
	local X2DataTemplate Template;

	TemplateCache = GetRPGOTemplateCache();

	foreach TemplateCache.Templates(Template)
	{
		if (Template.DataName == name(DataName $ "_Cache"))
		{
			return X2WeaponTemplate(Template);
		}
	}

	return none;
}