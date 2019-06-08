class Config_Manager extends JsonObject config (RPGO_SoldierSkills);

var config array<string> ConfigProperties;

static function Config_Manager GetConfigManager()
{
	return Config_Manager(class'Engine'.static.FindClassDefaultObject("Config_Manager"));
}

static function SetConfigString(string PropertyName, coerce string Value)
{
	local Config_Manager ConfigManager;

	ConfigManager = GetConfigManager();
	ConfigManager.SetStringValue(PropertyName, Value);
}

static function int GetConfigIntValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return int(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static function int GetConfigFloatValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return float(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static function name GetConfigNameValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return name(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static function int GetConfigByteValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return byte(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static function bool GetConfigBoolValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return bool(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

static function vector GetConfigVectorValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local Config_TaggedConfigProperty ConfigProperty;

	ConfigProperty = GetConfigProperty(PropertyName);

	if (ConfigProperty != none)
	{
		return ConfigProperty.GetVectorValue();
	}

	return vect(0, 0, 0);
}


static function array<string> GetConfigArrayValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local Config_TaggedConfigProperty ConfigProperty;
	local array<string> EmptyArray;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		return ConfigProperty.GetArrayValue();
	}

	EmptyArray.Length = 0; // Prevent unassigned warning

	return EmptyArray;
}


static function string GetConfigStringValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local Config_TaggedConfigProperty ConfigProperty;
	local string Value;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		Value =  ConfigProperty.GetValue(TagFunction);
		`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ `ShowVar(Value) @ `ShowVar(TagFunction) @ `ShowVar(Namespace),, 'RPG');
	}

	return  Value;
}

static function string GetConfigTagValue(coerce string PropertyName, optional string Namespace)
{
	local Config_TaggedConfigProperty ConfigProperty;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		return ConfigProperty.GetTagValue();
	}

	return  "";
}


static function Config_TaggedConfigProperty GetConfigProperty(
	coerce string PropertyName,
	optional string Namespace
)
{
	local Config_Manager ConfigManager;
	local JSonObject JSonObject, JSonObjectProperty;
	local Config_TaggedConfigProperty ConfigProperty;
	local string SerializedConfigProperty;

	ConfigManager = GetConfigManager();

	//`LOG(default.class @ GetFuncName() @ ConfigManager @ `ShowVar(PropertyName) @ `ShowVar(Namespace),, 'RPG');

	if (Namespace != "")
	{
		PropertyName $= ":" $ Namespace;
	}

	foreach ConfigManager.ConfigProperties(SerializedConfigProperty)
	{
		//`LOG(default.class @ GetFuncName() @ `ShowVar(SerializedConfigProperty),, 'RPG');

		JSonObject = class'JSonObject'.static.DecodeJson(SanitizeJson(SerializedConfigProperty));

		//`LOG(default.class @ GetFuncName() @ `ShowObj(JSonObject),, 'RPG');

		if (JSonObject != none)
		{
			ConfigProperty = new class'Config_TaggedConfigProperty';
			JSonObjectProperty = JSonObject.GetObject(PropertyName);

			if (JSonObjectProperty != none)
			{
				//`LOG(default.class @ GetFuncName() @ `ShowObj(JSonObjectProperty),, 'RPG');
				ConfigProperty.Deserialize(JSonObjectProperty);
				return ConfigProperty;
			}
		}
	}

	`LOG(default.class @ GetFuncName() @ "could not find config property for" @ PropertyName,, 'RPG');

	return none;
}

static function string SanitizeJson(string Json)
{
	local string Buffer;

	Buffer = Repl(Repl(Repl(Json, "\n", ""), " ", ""), "	", "");

	if (CountCharacters(Buffer, "{") != CountCharacters(Buffer, "}"))
	{
		`LOG(default.class @ GetFuncName() @ "Warning: invalid json" @ Buffer,, 'RPG');
		return "";
	} 

	Buffer = LTrimToFirstBracket(RTrimToFirstBracket(Buffer));

	return Buffer;
}

static final function int CountCharacters(coerce string S, string Character)
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

static final function string LTrimToFirstBracket(coerce string S)
{
	while (Left(S, 1) != "{")
		S = Right(S, Len(S) - 1);
	return S;
}
static final function string RTrimToFirstBracket(coerce string S)
{
	while (Right(S, 1) != "}")
		S = Left(S, Len(S) - 1);
	return S;
}