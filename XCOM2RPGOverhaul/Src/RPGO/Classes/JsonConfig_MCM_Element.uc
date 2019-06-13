//-----------------------------------------------------------
//	Class:	JsonConfig_MCM_Element
//	Author: Musashi
//	
//-----------------------------------------------------------
class JsonConfig_MCM_Element extends Object;

var string ConfigKey;
var JsonConfig_MCM_Builder Builder;
var string SettingName;
var string Type;
var string Label;
var string Tooltip;
var string SliderMin;
var string SliderMax;
var string SliderStep;
var string ButtonLabel;
var JsonConfig_Array Options;

public function string GetLabel()
{
	if (Label != "")
	{
		return Label;
	}

	return Builder.LocalizeItem(SettingName $ "_LABEL");
}

public function string GetTooltip()
{
	if (Tooltip != "")
	{
		return Tooltip;
	}

	return Builder.LocalizeItem(SettingName $ "_TOOLTIP");
}

public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	local JsonObject JsonSubObject;

	ConfigKey = PropertyName;

	JsonSubObject = new () class'JsonObject';
	JsonSubObject.SetStringValue("SettingName", SettingName);
	JsonSubObject.SetStringValue("Type", Type);
	JsonSubObject.SetStringValue("Label", Label);
	JsonSubObject.SetStringValue("Tooltip", Tooltip);
	JsonSubObject.SetStringValue("SliderMin", SliderMin);
	JsonSubObject.SetStringValue("SliderMax", SliderMax);
	JsonSubObject.SetStringValue("SliderStep", SliderStep);
	JsonSubObject.SetStringValue("ButtonLabel", ButtonLabel);
	Options.Serialize(JSonObject, "Options");

	JSonObject.SetObject(PropertyName, JsonSubObject);
}

public function bool Deserialize(JSonObject Data, string PropertyName, JsonConfig_MCM_Builder BuilderParam)
{
	local JsonObject GroupJson;

	ConfigKey = PropertyName;

	GroupJson = Data.GetObject(PropertyName);
	if (GroupJson != none)
	{
		Builder = BuilderParam;
		SettingName = GroupJson.GetStringValue("SettingName");
		Type = GroupJson.GetStringValue("Type");
		Label = GroupJson.GetStringValue("Label");
		Tooltip = GroupJson.GetStringValue("Tooltip");
		SliderMin = GroupJson.GetStringValue("SliderMin");
		SliderMax = GroupJson.GetStringValue("SliderMax");
		SliderStep = GroupJson.GetStringValue("SliderStep");
		ButtonLabel = GroupJson.GetStringValue("ButtonLabel");
		Options.Deserialize(Data, "Options");

		return true;
	}
	return false;
}