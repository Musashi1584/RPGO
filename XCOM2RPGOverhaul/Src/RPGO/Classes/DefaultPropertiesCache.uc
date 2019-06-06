class DefaultPropertiesCache extends JsonObject;

static function SetString(string PropertyName, coerce string Value)
{
	DefaultPropertiesCache(class'Engine'.static.FindClassDefaultObject("DefaultPropertiesCache")).SetStringValue(PropertyName, Value);
}

static function string GetString(coerce string PropertyName)
{
	return DefaultPropertiesCache(class'Engine'.static.FindClassDefaultObject("DefaultPropertiesCache")).GetStringValue(PropertyName);
}