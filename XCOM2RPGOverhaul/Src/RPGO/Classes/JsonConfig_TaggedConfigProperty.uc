//-----------------------------------------------------------
//	Class:	JsonConfig_TaggedConfigProperty
//	Author: Musashi
//	Defines a config entry for a config value with meta information for automatic localization tags
//-----------------------------------------------------------

class JsonConfig_TaggedConfigProperty extends Object;

var JsonConfigManager ManagerInstance;
var protectedwrite string Value;
var protectedwrite vector VectorValue;
var protectedwrite array<string> ArrayValue;
var protectedwrite WeaponDamageValue DamageValue;

var protectedwrite string Namespace;
var protectedwrite string TagFunction;
var protectedwrite string TagParam;
var protectedwrite string TagPrefix;
var protectedwrite string TagSuffix;

var protectedwrite bool bIsVector;
var protectedwrite bool bIsArray;
var protectedwrite bool bIsDamageValue;

public function string GetTagParam()
{
	local string PropertyRefValue;

	// Check if the tag param is referencing another property value
	if (ManagerInstance.static.HasConfigProperty(TagParam))
	{
		PropertyRefValue = ManagerInstance.static.GetConfigStringValue(TagParam);

		if (PropertyRefValue != "")
		{
			return PropertyRefValue;
		}
	}

	return TagParam;
}

public function string GetValue(optional string TagFunctionIn)
{
	return GetTagFunctionValueImmediate(TagFunctionIn);
}

public function vector GetVectorValue()
{
	return VectorValue;
}

public function array<string> GetArrayValue()
{
	return ArrayValue;
}

public function WeaponDamageValue GetDamageValue()
{
	return DamageValue;
}

public function string GetTagValue()
{
	local string TagValue;

	if (bIsVector)
	{
		TagValue = VectorValue.X $ "," $ VectorValue.Y $ "," $ VectorValue.Z;
	}
	else if (bIsArray && ArrayValue.Length > 0)
	{
		TagValue = Join(ArrayValue, ", ");
	}
	else if (bIsDamageValue)
	{
		// @TODO make proper damage preview function
		TagValue = (DamageValue.Damage - DamageValue.Spread) $ "-" $
				   (DamageValue.Damage + DamageValue.Spread);
	}
	else
	{
		TagValue = Value;
	}

	if (!bIsVector &&
		TagFunction != "")
	{
		TagValue = GetTagFunctionValueByEvent(TagFunction);
	}

	return TagPrefix $ TagValue $ TagSuffix;
}

// Used for direct access because the event system is not working at template creation
function string GetTagFunctionValueImmediate(string TagFunctionIn)
{
	local LWTuple Tuple;

	if (TagFunctionIn != "")
	{
		Tuple = new class'LWTuple';
		Tuple.Id = name(TagFunctionIn);
		Tuple.Data.Add(1);
		Tuple.Data[0].kind = LWTVString;
		Tuple.Data[0].s = "";

		class'JsonConfig_EventListener'.static.OnTagValue(Tuple, self, none, 'ConfigTagFunction', none);

		if (Tuple.Data[0].s != "")
		{
			return Tuple.Data[0].s;
		}
	}

	return Value;
}

// Used for tag values at runtime for better extensibility
function string GetTagFunctionValueByEvent(string TagFunctionIn)
{
	local LWTuple Tuple;

	if (TagFunctionIn != "")
	{
		Tuple = new class'LWTuple';
		Tuple.Id = name(TagFunctionIn);
		Tuple.Data.Add(1);
		Tuple.Data[0].kind = LWTVString;
		Tuple.Data[0].s = "";

		`LOG(default.class @ GetFuncName() @ "trigger event" @ TagFunctionIn,, 'RPG');

		`XEVENTMGR.TriggerEvent('ConfigTagFunction', Tuple, self);

		if (Tuple.Data[0].s != "")
		{
			return Tuple.Data[0].s;
		}
	}

	return Value;
}


function JSonObject Serialize()
{
	local JsonObject JsonObject;

	JSonObject = new () class'JsonObject';

	if (ArrayValue.Length > 0)
	{
		bIsArray = true;
		JSonObject.SetStringValue("ArrayValue", Join(ArrayValue, ", "));
	}
	
	JSonObject.SetStringValue("VectorValue", "{\"X\":" $ VectorValue.X $ ",\"Y\":" $ VectorValue.Y $ ",\"Z\":" $ VectorValue.Z $ "}");
	JSonObject.SetStringValue("DamageValue", "{\"Damage\":" $ DamageValue.Damage $
											 ",\"Spread\":" $ DamageValue.Spread $
											 ",\"PlusOne\":" $ DamageValue.PlusOne $
											 ",\"Crit\":" $ DamageValue.Crit $
											 ",\"Pierce\":" $ DamageValue.Pierce $
											 ",\"Rupture\":" $ DamageValue.Rupture $
											 ",\"Shred\":" $ DamageValue.Shred $
											 ",\"Tag\":\"" $ DamageValue.Tag $ "\"" $
											 ",\"DamageType\":\"" $ DamageValue.DamageType $ "\"" $
											 "}");
	JSonObject.SetStringValue("Value", Value);
	JSonObject.SetStringValue("Namespace", Namespace);
	JSonObject.SetStringValue("TagFunction", TagFunction);
	JSonObject.SetStringValue("TagParam", TagParam);
	JSonObject.SetStringValue("TagPrefix", TagPrefix);
	JSonObject.SetStringValue("TagSuffix", TagSuffix);

	return JSonObject;
}

function Deserialize(JSonObject Data)
{
	local JSonObject VectorJson, DamageValueJson;
	local string UnserializedArrayValue;

	VectorJson = Data.GetObject("VectorValue");
	if (VectorJson != none)
	{
		bIsVector = true;
		VectorValue.X = VectorJson.GetIntValue("X");
		VectorValue.Y = VectorJson.GetIntValue("Y");
		VectorValue.Z = VectorJson.GetIntValue("Z");
	}

	UnserializedArrayValue = Data.GetStringValue("ArrayValue");
	if (UnserializedArrayValue != "")
	{
		ArrayValue = SplitString(Repl(Repl(UnserializedArrayValue, " ", ""), "	", ""), ",", true);
		bIsArray = true;
	}

	DamageValueJson = Data.GetObject("DamageValue");
	if (DamageValueJson != none)
	{
		DamageValue.Damage = DamageValueJson.GetIntValue("Damage");
		DamageValue.Spread = DamageValueJson.GetIntValue("Spread");
		DamageValue.PlusOne = DamageValueJson.GetIntValue("PlusOne");
		DamageValue.Crit = DamageValueJson.GetIntValue("Crit");
		DamageValue.Pierce = DamageValueJson.GetIntValue("Pierce");
		DamageValue.Rupture = DamageValueJson.GetIntValue("Rupture");
		DamageValue.Shred = DamageValueJson.GetIntValue("Shred");
		DamageValue.Tag = name(DamageValueJson.GetStringValue("Tag"));
		DamageValue.DamageType = name(DamageValueJson.GetStringValue("DamageType"));
		bIsDamageValue = true;
	}

	Value = Data.GetStringValue("Value");

	Namespace = Data.GetStringValue("Namespace");
	TagFunction = Data.GetStringValue("TagFunction");
	TagParam = Data.GetStringValue("TagParam");
	TagPrefix = Data.GetStringValue("TagPrefix");
	TagSuffix = Data.GetStringValue("TagSuffix");
}


function static string Join(array<string> StringArray, optional string Delimiter = ",", optional bool bIgnoreBlanks = true)
{
	local string Result;

	JoinArray(StringArray, Result, Delimiter, bIgnoreBlanks);

	return Result;
}
