//-----------------------------------------------------------
//	Class:	JsonConfig_MCM_Group
//	Author: Musashi
//	
//-----------------------------------------------------------
class JsonConfig_MCM_Group extends Object implements (JsonConfig_Interface);

var protectedwrite string GroupName;
var protectedwrite string GroupLabel;

var array<JsonConfig_MCM_Element> Elements;

public function SetGroupName(string GroupNameParam)
{
	GroupName = GroupNameParam;
}

public function string GetGroupName()
{
	return GroupName;
}

public function SetGroupLabel(string GroupLabelParam)
{
	GroupLabel = GroupLabelParam;
}

public function string GetGroupLabel()
{
	return GroupLabel;
}

public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	local JsonObject JsonSubObject;

	JsonSubObject = new () class'JsonObject';
	JsonSubObject.SetStringValue("GroupName", GroupName);
	JsonSubObject.SetStringValue("GroupLabel", GroupLabel);

	JSonObject.SetObject(PropertyName, JsonSubObject);
}

public function bool Deserialize(JSonObject Data, string PropertyName)
{
	local JsonObject GroupJson;

	GroupJson = Data.GetObject(PropertyName);
	if (GroupJson != none)
	{
		GroupName = GroupJson.GetStringValue("GroupName");
		GroupLabel = GroupJson.GetStringValue("GroupLabel");

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
		if(Element.Deserialize(GroupJson, "Element" $ Index))
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