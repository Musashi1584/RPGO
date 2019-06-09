//-----------------------------------------------------------
//	Class:	Config_TaggedConfigProperty
//	Author: Musashi
//	Defines a config entry for a config value with meta information for automatic localization tags
//-----------------------------------------------------------

class Config_TaggedConfigProperty extends Object;

var protectedwrite vector VectorValue;
var protectedwrite string Value;
var protectedwrite array<string> ArrayValue;
var protectedwrite string Namespace;
var protectedwrite string TagFunction;
var protectedwrite string TagParam;
var protectedwrite string TagPrefix;
var protectedwrite string TagSuffix;

var protectedwrite bool bIsVector;
var protectedwrite bool bIsArray;

public function string GetTagParam()
{
	local string PropertyRefValue;

	// Check if the tag param is referencing a property value
	PropertyRefValue = class'Config_Manager'.static.GetConfigStringValue(TagParam);

	if (PropertyRefValue != "")
	{
		return PropertyRefValue;
	}
	return TagParam;
}

public function string GetValue(optional string TagFunction)
{
	return GetTagFunctionValueImmediate(TagFunction);
}

public function vector GetVectorValue()
{
	return VectorValue;
}

public function array<string> GetArrayValue()
{
	`LOG(default.class @ GetFuncName() @ `ShowVar(ArrayValue[0]),, 'RPG');
	return ArrayValue;
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
function string GetTagFunctionValueImmediate(string TagFunction)
{
	local LWTuple Tuple;

	if (TagFunction != "")
	{
		Tuple = new class'LWTuple';
		Tuple.Id = name(TagFunction);
		Tuple.Data.Add(1);
		Tuple.Data[0].kind = LWTVString;
		Tuple.Data[0].s = "";

		class'Config_EventListener'.static.OnTagValue(Tuple, self, none, 'ConfigTagFunction', none);

		if (Tuple.Data[0].s != "")
		{
			return Tuple.Data[0].s;
		}
	}

	return Value;
}

// Used for tag values at runtime for better extensibility
function string GetTagFunctionValueByEvent(string TagFunction)
{
	local LWTuple Tuple;

	if (TagFunction != "")
	{
		Tuple = new class'LWTuple';
		Tuple.Id = name(TagFunction);
		Tuple.Data.Add(1);
		Tuple.Data[0].kind = LWTVString;
		Tuple.Data[0].s = "";

		`LOG(default.class @ GetFuncName() @ "trigger event" @ TagFunction,, 'RPG');

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
	local JSonObject VectorJson;
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
