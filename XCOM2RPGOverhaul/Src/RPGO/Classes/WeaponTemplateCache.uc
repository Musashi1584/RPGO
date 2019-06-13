//-----------------------------------------------------------
//	Class:	WeaponTemplateCache
//	Author: Musashi
//	Cache template if the need to be restored for config changes
//-----------------------------------------------------------
class WeaponTemplateCache extends Object;

var array <X2WeaponTemplate> Templates;

public static function WeaponTemplateCache GetWeaponTemplateCache()
{
	return WeaponTemplateCache(class'Engine'.static.FindClassDefaultObject(string(default.class)));
}

public static function AddTemplate(X2WeaponTemplate Template)
{
	local WeaponTemplateCache TemplateCache;
	local X2WeaponTemplate ClonedTemplate;

	TemplateCache = GetWeaponTemplateCache();

	if (GetTemplate(Template.DataName) == none)
	{
		ClonedTemplate = new Template.Class (Template);
		ClonedTemplate.SetTemplateName(name(Template.DataName $ "_Cache"));
		TemplateCache.Templates.AddItem(ClonedTemplate);
	}
}

public static function X2WeaponTemplate GetTemplate(name DataName)
{
	local WeaponTemplateCache TemplateCache;
	local X2WeaponTemplate Template;

	TemplateCache = GetWeaponTemplateCache();

	foreach TemplateCache.Templates(Template)
	{
		if (Template.DataName == name(DataName $ "_Cache"))
		{
			return Template;
		}
	}

	return none;
}