//-----------------------------------------------------------
//	Class:	JsonConfig_MCM_Group
//	Author: Musashi
//	
//-----------------------------------------------------------
class JsonConfig_MCM_Group extends Object;

var JsonConfig_MCM_Builder Builder;
var protectedwrite string GroupName;
var protectedwrite string GroupLabel;
var string ConfigKey;

var array<JsonConfig_MCM_Element> Elements;

public function SetGroupName(string GroupNameParam)
{
	GroupName = GroupNameParam;
}

public function string GetGroupName()
{
	if (GroupName != "")
	{
		return GroupName;
	}

	return ConfigKey;
}

public function SetGroupLabel(string GroupLabelParam)
{
	GroupLabel = GroupLabelParam;
}

public function string GetGroupLabel()
{
	if (GroupLabel != "")
	{
		return GroupLabel;
	}

	return Builder.LocalizeItem(ConfigKey $ "_LABEL");
}

public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	local JsonObject JsonSubObject;

	ConfigKey = PropertyName;

	JsonSubObject = new () class'JsonObject';
	JsonSubObject.SetStringValue("GroupName", GroupName);
	JsonSubObject.SetStringValue("GroupLabel", GroupLabel);

	JSonObject.SetObject(PropertyName, JsonSubObject);
}

public function bool Deserialize(JSonObject Data, string PropertyName, JsonConfig_MCM_Builder BuilderParam)
{
	local JsonObject GroupJson;

	ConfigKey = PropertyName;

	GroupJson = Data.GetObject(PropertyName);
	if (GroupJson != none)
	{
		GroupName = GroupJson.GetStringValue("GroupName");
		GroupLabel = GroupJson.GetStringValue("GroupLabel");
		Builder = BuilderParam;
		DeserializeElements(GroupJson);

		return true;
	}
	return false;
}

private function DeserializeElements(JsonObject GroupJson)
{
	local int Index;
	local JsonConfig_MCM_Element Element;

	Index = 1;
	while(true && Index <= 20)
	{
		Element = new class'JsonConfig_MCM_Element';
		if(Element.Deserialize(GroupJson, "ELEMENT" $ Index, Builder))
		{
			Elements.AddItem(Element);
		}
		else
		{
			break;
		}

		Index++;
	}
}