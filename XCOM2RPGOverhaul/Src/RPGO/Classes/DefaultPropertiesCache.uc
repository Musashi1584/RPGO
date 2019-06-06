class DefaultPropertiesCache extends JsonObject config (RPGO_TEST_NullConfig);

var config string PropCache;

static function SetString(string PropertyName, coerce string Value)
{
	local DefaultPropertiesCache CDODefaultPropertiesCache;

	CDODefaultPropertiesCache = DefaultPropertiesCache(class'Engine'.static.FindClassDefaultObject("DefaultPropertiesCache"));
	CDODefaultPropertiesCache.SetStringValue(PropertyName, Value);
	CDODefaultPropertiesCache.PropCache = EncodeJson(CDODefaultPropertiesCache);
	CDODefaultPropertiesCache.SaveConfig();
}

static function string GetString(coerce string PropertyName)
{
	return DefaultPropertiesCache(class'Engine'.static.FindClassDefaultObject("DefaultPropertiesCache")).GetStringValue(PropertyName);
}