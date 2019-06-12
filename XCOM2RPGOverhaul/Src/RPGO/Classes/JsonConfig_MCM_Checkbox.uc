//-----------------------------------------------------------
//	Class:	JsonConfig_MCM_Checkbox
//	Author: Musashi
//	
//-----------------------------------------------------------
class JsonConfig_MCM_Checkbox extends Object implements (JsonConfig_Interface);

var string SettingName;
var string Label;
var string Tooltip;


public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	local JsonObject JsonSubObject;

	JsonSubObject = new () class'JsonObject';
	JsonSubObject.SetStringValue("SettingName", SettingName);
	JsonSubObject.SetStringValue("Label", Label);
	JsonSubObject.SetStringValue("Tooltip", Tooltip);

	JSonObject.SetObject(PropertyName, JsonSubObject);
}

public function bool Deserialize(JSonObject Data, string PropertyName)
{
	local JsonObject GroupJson;

	GroupJson = Data.GetObject(PropertyName);
	if (GroupJson != none)
	{
		SettingName = GroupJson.GetStringValue("SettingName");
		Label = GroupJson.GetStringValue("Label");
		Tooltip = GroupJson.GetStringValue("Tooltip");
		return true;
	}
	return false;
}