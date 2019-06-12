//-----------------------------------------------------------
//	Class:	JsonConfig_MCM_Page
//	Author: Musashi
//	
//-----------------------------------------------------------
class JsonConfig_MCM_Page extends Object implements (JsonConfig_Interface);

var int MCMPageId;
var string PageTitle;
var string TabLabel;
var string SaveConfigManager;
var array<JsonConfig_MCM_Group> Groups;

public function SetPageTitle(string PageTitleParam)
{
	PageTitle = PageTitleParam;
}

public function string GetPageTitle()
{
	return PageTitle;
}

public function SetTabLabel(string TabLabelParam)
{
	TabLabel = TabLabelParam;
}

public function string GetTabLabel()
{
	return TabLabel;
}

public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	local JsonObject JsonSubObject;

	JsonSubObject = new () class'JsonObject';
	JsonSubObject.SetStringValue("PageTitle", PageTitle);
	JsonSubObject.SetStringValue("TabLabel", TabLabel);
	JsonSubObject.SetStringValue("SaveConfigManager", SaveConfigManager);

	JSonObject.SetObject(PropertyName, JsonSubObject);
}

public function bool Deserialize(JSonObject Data, string PropertyName)
{
	local JsonObject PageJson;

	PageJson = Data.GetObject(PropertyName);
	if (PageJson != none)
	{
		PageTitle = PageJson.GetStringValue("PageTitle");
		TabLabel = PageJson.GetStringValue("TabLabel");
		SaveConfigManager = PageJson.GetStringValue("SaveConfigManager");

		DeserializeGroups(PageJson);
		
		return true;
	}

	return false;
}

private function DeserializeGroups(JsonObject PageJson)
{
	local int Index;
	local JsonConfig_MCM_Group Group;

	Index = 1;
	while(true && Index <= 20)
	{
		Group = new class'JsonConfig_MCM_Group';
		if(Group.Deserialize(PageJson, "Group" $ Index))
		{
			Groups.AddItem(Group);
		}
		else
		{
			break;
		}

		Index++;
	}
}