//-----------------------------------------------------------
//	Class:	JsonConfig_TaggedConfigProperty
//	Author: Musashi
//	Defines a config entry for a config value with meta information for automatic localization tags
//-----------------------------------------------------------

class JsonConfig_TaggedConfigProperty extends Object dependson(JsonConfigManager);

var JsonConfigManager ManagerInstance;
var protectedwrite string Value;
var protectedwrite JsonConfig_Vector VectorValue;
var protectedwrite JsonConfig_Array ArrayValue;
var protectedwrite JsonConfig_WeaponDamageValue DamageValue;

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
	if (TagFunctionIn != "")
	{
		return GetTagFunctionValue(TagFunctionIn);
	}

	return Value;
}

public function vector GetVectorValue()
{
	return VectorValue.GetVectorValue();
}

public function array<string> GetArrayValue()
{
	return ArrayValue.GetArrayValue();
}

public function WeaponDamageValue GetDamageValue()
{
	return DamageValue.GetDamageValue();
}

public function string GetTagValue()
{
	local string TagValue;

	if (bIsVector)
	{
		TagValue = VectorValue.ToString();
	}
	else if (bIsArray)
	{
		TagValue = ArrayValue.ToString();
	}
	else if (bIsDamageValue)
	{
		DamageValue.ToString();
	}
	else
	{
		TagValue = Value;
	}

	if (!bIsVector &&
		TagFunction != "")
	{
		TagValue = GetTagFunctionValue(TagFunction);
	}

	return TagPrefix $ TagValue $ TagSuffix;
}

function string GetTagFunctionValue(string TagFunctionIn)
{
	local int OutValue;
	local string DelegateValue;
	local array<string> LocalArrayValue;
	local delegate<JsonConfigManager.TagFunctionDelegate> TagFunctionCB;

	foreach ManagerInstance.OnTagFunctions(TagFunctionCB)
	{
		if (TagFunctionCB(name(TagFunctionIn), self, DelegateValue))
		{
			return DelegateValue;
		}
	}

	switch (name(TagFunctionIn))
	{
		case 'TagValueToPercent':
			OutValue = int(float(Value) * 100);
			break;
		case 'TagValueToPercentMinusHundred':
			OutValue = int(float(Value) * 100 - 100);
			break;
		case 'TagValueMetersToTiles':
			OutValue = int(float(Value) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize);
			break;
		case 'TagValueTilesToMeters':
			OutValue = int(float(Value) * class'XComWorldData'.const.WORLD_StepSize / class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER);
			break;
		case 'TagValueTilesToUnits':
			OutValue = int(float(Value) * class'XComWorldData'.const.WORLD_StepSize);
			break;
		case 'TagValueParamAddition':
			 OutValue = int(float(Value) + float(GetTagParam()));
			 break;
		case 'TagValueParamMultiplication':
			 OutValue = int(float(Value) * float(GetTagParam()));
			 break;
		case 'TagArrayValue':
			LocalArrayValue = GetArrayValue();
			return  LocalArrayValue[int(GetTagParam())];
			break;
		default:
			break;
	}

	return string(OutValue);
}


function JSonObject Serialize()
{
	local JsonObject JsonObject;

	JSonObject = new () class'JsonObject';

	ArrayValue.Serialize(JSonObject, "VectorValue");
	VectorValue.Serialize(JSonObject, "ArrayValue");
	DamageValue.Serialize(JSonObject, "DamageValue");
	
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
	bIsVector = VectorValue.Deserialize(Data, "VectorValue");
	bIsArray = ArrayValue.Deserialize(Data, "ArrayValue");
	bIsDamageValue = DamageValue.Deserialize(Data, "DamageValue");

	Value = Data.GetStringValue("Value");

	Namespace = Data.GetStringValue("Namespace");
	TagFunction = Data.GetStringValue("TagFunction");
	TagParam = Data.GetStringValue("TagParam");
	TagPrefix = Data.GetStringValue("TagPrefix");
	TagSuffix = Data.GetStringValue("TagSuffix");
}

defaultproperties
{
	Begin Object Class=JsonConfig_Vector Name=DefaultJsonConfig_Vector
	End Object
	VectorValue = DefaultJsonConfig_Vector;

	Begin Object Class=JsonConfig_Array Name=DefaultJsonConfig_Array
	End Object
	ArrayValue = DefaultJsonConfig_Array;

	Begin Object Class=JsonConfig_WeaponDamageValue Name=DefaultJsonConfig_WeaponDamageValue
	End Object
	DamageValue = DefaultJsonConfig_WeaponDamageValue;
}