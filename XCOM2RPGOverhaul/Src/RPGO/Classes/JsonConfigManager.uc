class JsonConfigManager extends JsonObject config(GameData) abstract;

struct ConfigPropertyMapEntry
{
	var string PropertyName;
	var JsonConfig_TaggedConfigProperty ConfigProperty;
};

var config array<string> ConfigProperties;
var protectedwrite array<ConfigPropertyMapEntry> DeserialzedConfigPropertyMap;
var array< Delegate<TagFunctionDelegate> > OnTagFunctions;

delegate bool TagFunctionDelegate(name TagFunctionName, JsonConfig_TaggedConfigProperty ConfigProperty, out string TagValue);

//
// override in subclasses
//
function bool OnTagFunction(name TagFunctionName, JsonConfig_TaggedConfigProperty ConfigProperty, out string TagValue);

static function JsonConfigManager GetConfigManager()
{
	local JsonConfigManager ConfigManager;

	ConfigManager = JsonConfigManager(class'Engine'.static.FindClassDefaultObject(string(default.class)));
	
	if (ConfigManager.DeserialzedConfigPropertyMap.Length == 0)
	{
		ConfigManager.DeserializeConfig();
		ConfigManager.OnTagFunctions.AddItem(OnTagFunction);
	}

	return ConfigManager;
}

private function DeserializeConfig()
{
	local ConfigPropertyMapEntry MapEntry;
	local JSonObject JSonObject, JSonObjectProperty;
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local string SerializedConfigProperty, PropertyName;

	`LOG(default.class @ GetFuncName() @ "found entries:" @ default.ConfigProperties.Length,, 'RPG');

	foreach default.ConfigProperties(SerializedConfigProperty)
	{
		PropertyName = GetObjectKey(SanitizeJson(SerializedConfigProperty));
		JSonObject = class'JSonObject'.static.DecodeJson(SanitizeJson(SerializedConfigProperty));

		if (JSonObject != none && PropertyName != "")
		{
			JSonObjectProperty = JSonObject.GetObject(PropertyName);

			if (JSonObjectProperty != none &&
				DeserialzedConfigPropertyMap.Find('PropertyName', PropertyName) == INDEX_NONE)
			{
				ConfigProperty = new class'JsonConfig_TaggedConfigProperty';
				ConfigProperty.ManagerInstance = self;
				ConfigProperty.Deserialize(JSonObjectProperty);
				MapEntry.PropertyName = PropertyName;
				MapEntry.ConfigProperty = ConfigProperty;
				DeserialzedConfigPropertyMap.AddItem(MapEntry);
			}
		}
	}
}

static public function bool HasConfigProperty(coerce string PropertyName, optional string Namespace)
{
	PropertyName = GetPropertyName(PropertyName, Namespace);

	return GetConfigManager().DeserialzedConfigPropertyMap.Find('PropertyName', PropertyName) != INDEX_NONE;
}

static public function SetConfigString(string PropertyName, coerce string Value)
{
	local JsonConfigManager ConfigManager;

	ConfigManager = GetConfigManager();
	ConfigManager.SetStringValue(PropertyName, Value);
}

static public function int GetConfigIntValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return int(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static public function float GetConfigFloatValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return float(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static public function name GetConfigNameValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return name(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static public function int GetConfigByteValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return byte(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static public function bool GetConfigBoolValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return bool(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static public function array<int> GetConfigIntArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local array<string> StringArray;
	local string Value;
	local array<int> IntArray;

	StringArray = GetConfigStringArray(PropertyName, TagFunction, Namespace);

	foreach StringArray(Value)
	{
		IntArray.AddItem(int(Value));
	}

	return IntArray;
}

static public function array<float> GetConfigFloatArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local array<string> StringArray;
	local string Value;
	local array<float> FloatArray;

	StringArray = GetConfigStringArray(PropertyName, TagFunction, Namespace);

	foreach StringArray(Value)
	{
		FloatArray.AddItem(float(Value));
	}

	return FloatArray;
}

static public function array<name> GetConfigNameArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local array<string> StringArray;
	local string Value;
	local array<name> NameArray;

	StringArray = GetConfigStringArray(PropertyName, TagFunction, Namespace);

	foreach StringArray(Value)
	{
		NameArray.AddItem(name(Value));
	}

	return NameArray;
}

static public function vector GetConfigVectorValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;

	ConfigProperty = GetConfigProperty(PropertyName);

	if (ConfigProperty != none)
	{
		`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ "Value:" @ ConfigProperty.VectorValue.ToString() @ `ShowVar(Namespace),, 'RPG');
		return ConfigProperty.GetVectorValue();
	}

	return vect(0, 0, 0);
}

static public function array<string> GetConfigStringArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local array<string> EmptyArray;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ "Value:" @ ConfigProperty.ArrayValue.ToString() @ `ShowVar(Namespace),, 'RPG');
		return ConfigProperty.GetArrayValue();
	}

	EmptyArray.Length = 0; // Prevent unassigned warning

	return EmptyArray;
}

static public function WeaponDamageValue GetConfigDamageValue(coerce string PropertyName, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local WeaponDamageValue Value;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		Value =  ConfigProperty.GetDamageValue();
		`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ "Value:" @ ConfigProperty.DamageValue.ToString() @ `ShowVar(Namespace),, 'RPG');
	}

	return Value;
}

static public function string GetConfigStringValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local string Value;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		Value =  ConfigProperty.GetValue(TagFunction);
		`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ `ShowVar(Value) @ `ShowVar(TagFunction) @ `ShowVar(Namespace),, 'RPG');
	}

	return Value;
}

static public function string GetConfigTagValue(coerce string PropertyName, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		return ConfigProperty.GetTagValue();
	}

	return  "";
}


static public function JsonConfig_TaggedConfigProperty GetConfigProperty(
	coerce string PropertyName,
	optional string Namespace
)
{
	local JsonConfigManager ConfigManager;
	local int Index;

	ConfigManager = GetConfigManager();

	PropertyName = GetPropertyName(PropertyName, Namespace);

	Index = ConfigManager.DeserialzedConfigPropertyMap.Find('PropertyName', PropertyName);
	if (Index != INDEX_NONE)
	{
		return ConfigManager.DeserialzedConfigPropertyMap[Index].ConfigProperty;
	}

	`LOG(default.class @ GetFuncName() @ "could not find config property for" @ PropertyName,, 'RPG');

	return none;
}

static private function string GetPropertyName(coerce string PropertyName, optional string Namespace)
{
	if (Namespace != "")
	{
		PropertyName $= ":" $ Namespace;
	}

	return PropertyName;
}

static public function string SanitizeJson(string Json)
{
	local string Buffer;
	local int CountBracketsOpen, CountBracketsClose, CountDoubleQuotes;

	Buffer = Repl(Repl(Repl(Json, "\n", ""), " ", ""), "	", "");
	Buffer = LTrimToFirstBracket(RTrimToFirstBracket(Buffer));

	CountBracketsOpen  = CountCharacters(Buffer, "{");
	CountBracketsClose = CountCharacters(Buffer, "}");
	CountDoubleQuotes = CountCharacters(Buffer, "\"");

	if (CountBracketsOpen != CountBracketsClose ||
		InStr(Buffer, "\"{") != INDEX_NONE ||
		CountDoubleQuotes % 2 != 0)
	{
		`LOG(default.class @ GetFuncName() @ "Warning: invalid json" @ Buffer,, 'RPG');
		return "";
	}

	return Buffer;
}

static public final function int CountCharacters(coerce string S, string Character)
{
	local int Count, Index, Max;
	local string copy;

	copy = S;

	Max = Len(copy);

	for (Index = 0; Index < Max; Index++)
	{
		if (Left(copy, 1) == Character)
		{
			Count++;
		}
		copy = Right(copy, Len(copy) - 1);
	}

	return Count;
}

static public final function string LTrimToFirstBracket(coerce string S)
{
	while (Left(S, 1) != "{")
		S = Right(S, Len(S) - 1);
	return S;
}
static public final function string RTrimToFirstBracket(coerce string S)
{
	while (Right(S, 1) != "}")
		S = Left(S, Len(S) - 1);
	return S;
}

static public final function string GetObjectKey(coerce string S)
{
	local int Index, Max, DoubleQuoteUnicode;
	local string Key;
	local bool bStart;

	Max = Len(S);
	DoubleQuoteUnicode = 34;

	for (Index = 0; Index < Max; Index++)
	{
		if (Asc(Left(S, 1)) == DoubleQuoteUnicode)
		{
			if (bStart)
				break;
			if (!bStart)
				bStart = true;
		}

		if (bStart && Asc(Left(S, 1)) != DoubleQuoteUnicode)
		{
			Key $= Left(S, 1);
		}

		S = Right(S, Len(S) - 1);
	}

	return Key;
}