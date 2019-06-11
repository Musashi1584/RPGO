//-----------------------------------------------------------
//	Class:	JsonConfig_Vector
//	Author: Muasshi
//	
//-----------------------------------------------------------
class JsonConfig_Vector extends Object;

var protectedwrite vector VectorValue;

public function SetVectorValue(vector VectorParam)
{
	VectorValue = VectorParam;
}

public function vector GetVectorValue()
{
	return VectorValue;
}

public function string ToString()
{
	return VectorValue.X $ "," $ VectorValue.Y $ "," $ VectorValue.Z;
}

public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	JSonObject.SetStringValue(PropertyName, "{\"X\":" $ VectorValue.X $ ",\"Y\":" $ VectorValue.Y $ ",\"Z\":" $ VectorValue.Z $ "}");
}

public function bool Deserialize(JSonObject Data, string PropertyName)
{
	local JSonObject VectorJson;

	VectorJson = Data.GetObject(PropertyName);
	if (VectorJson != none)
	{
		VectorValue.X = VectorJson.GetIntValue("X");
		VectorValue.Y = VectorJson.GetIntValue("Y");
		VectorValue.Z = VectorJson.GetIntValue("Z");
		return true;
	}

	return false;
}