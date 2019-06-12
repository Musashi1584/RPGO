class JsonConfig_MCM_Builder extends JsonConfig config(UI) abstract;

struct MCMConfigMapEntry
{
	var string PageID;
	var JsonConfig_MCM_Page MCMConfigPage;
};

var config array<string> MCMPages;
var protectedwrite array<MCMConfigMapEntry> DeserialzedPagesMap;

static public function JsonConfig_MCM_Builder GetMCMBuilder()
{
	local JsonConfig_MCM_Builder MCMBuilder;

	MCMBuilder = JsonConfig_MCM_Builder(class'Engine'.static.FindClassDefaultObject(string(default.class)));
	
	`LOG(default.class @ GetFuncName() @ "1",, 'RPG');

	if (MCMBuilder.DeserialzedPagesMap.Length == 0)
	{
		`LOG(default.class @ GetFuncName() @ "2",, 'RPG');
		MCMBuilder.DeserializeConfig();
	}

	`LOG(default.class @ GetFuncName() @ "3",, 'RPG');

	return MCMBuilder;
}

static public function BuildMCM(
	MCM_API_Instance ConfigAPI,
	int GameMode
)
{
	local JsonConfig_MCM_Builder Builder;
	local MCMConfigMapEntry MCMConfig;
	local JsonConfig_MCM_Page MCMPageConfig;
	local JsonConfig_MCM_Group MCMGroupConfig;
	local JsonConfig_MCM_Checkbox MCMCheckboxConfig;
	local JsonConfig_Manager SaveConfigManager;

	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup Group;
	
	Builder = GetMCMBuilder();

	foreach Builder.DeserialzedPagesMap(MCMConfig)
	{
		MCMPageConfig = MCMConfig.MCMConfigPage;

		SaveConfigManager = JsonConfig_Manager(class'Engine'.static.FindClassDefaultObject(MCMPageConfig.SaveConfigManager));

		Page = ConfigAPI.NewSettingsPage(MCMPageConfig.GetPageTitle());
		Page.SetPageTitle(MCMPageConfig.GetTabLabel());
		MCMPageConfig.MCMPageId = Page.GetPageId();

		foreach MCMPageConfig.Groups(MCMGroupConfig)
		{
			Group = Page.AddGroup(name(MCMGroupConfig.GetGroupName()), MCMGroupConfig.GetGroupLabel());
			
			foreach MCMGroupConfig.Checkboxes(MCMCheckboxConfig)
			{
				Group.AddCheckbox(
					name(MCMCheckboxConfig.SettingName),
					MCMCheckboxConfig.Label,
					MCMCheckboxConfig.Tooltip,
					SaveConfigManager.GetConfigBoolValue(MCMCheckboxConfig.SettingName),
					CheckboxSaveHandler
				);
			}
		}
		
		Page.ShowSettings();
		Page.SetSaveHandler(SaveButtonClicked);
	}
}

static public function JsonConfig_MCM_Page GetPage(int PageID)
{
	local JsonConfig_MCM_Builder Builder;
	local MCMConfigMapEntry MCMConfig;
	local JsonConfig_MCM_Page Page;

	Builder = GetMCMBuilder();

	foreach Builder.DeserialzedPagesMap(MCMConfig)
	{
		Page = MCMConfig.MCMConfigPage;

		if (Page.MCMPageId == PageID)
		{
			return Page;
		}
	}

	`LOG(default.class @ GetFuncName() @ "could not find MCMConfigPage for" @ PageID,, 'RPG');

	return none;
}

static public function JsonConfig_MCM_Group GetGroup(int PageID, name GroupName)
{
	local JsonConfig_MCM_Page Page;
	local JsonConfig_MCM_Group Group;

	Page = GetPage(PageID);

	foreach Page.Groups(Group)
	{
		if (name(Group.GetGroupName()) == GroupName)
		{
			return Group;
		}
	}

	`LOG(default.class @ GetFuncName() @ "could not find JsonConfig_MCM_Group for" @ PageID @ GroupName,, 'RPG');

	return none;
}

static public function JsonConfig_MCM_Checkbox GetCheckbox(int PageID, name GroupName, name SettingName)
{
	local JsonConfig_MCM_Group Group;
	local JsonConfig_MCM_Checkbox Checkbox;

	Group = GetGroup(PageID, GroupName);

	foreach Group.Checkboxes(Checkbox)
	{
		if (name(Checkbox.SettingName) == SettingName)
		{
			return Checkbox;
		}
	}

	`LOG(default.class @ GetFuncName() @ "could not find JsonConfig_MCM_Checkbox for" @ PageID @ GroupName @ SettingName,, 'RPG');

	return none;
}


public static function bool GetMCMBoolValue(
	string PropertyName,
	JsonConfig_Manager DefaultManager,
	JsonConfig_Manager SaveManager
)
{
	if (SaveManager.static.HasConfigProperty(PropertyName))
	{
		return SaveManager.static.GetConfigBoolValue(PropertyName);
	}

	if (DefaultManager.static.HasConfigProperty(PropertyName))
	{
		return DefaultManager.static.GetConfigBoolValue(PropertyName);
	}

	return false;
}

simulated function CheckboxSaveHandler(MCM_API_Setting _Setting, bool _SettingValue)
{
	local JsonConfig_MCM_Page Page;
	//local JsonConfig_Manager DefaultConfigManager;
	local JsonConfig_Manager SaveConfigManager;

	Page = GetPage(_Setting.GetParentGroup().GetParentPage().GetPageId());

	//DefaultConfigManager = JsonConfig_Manager(class'Engine'.static.FindClassDefaultObject(Page.DefaultConfigManager));
	SaveConfigManager = JsonConfig_Manager(class'Engine'.static.FindClassDefaultObject(Page.SaveConfigManager));

	SaveConfigManager.static.SetConfigString(string(_Setting.GetName()), _SettingValue);
	`LOG(default.class @ GetFuncName() @ _Setting.GetName() @ _SettingValue,, 'RPG');

	//GetCheckbox(
	//	_Setting.GetParentGroup().GetParentPage().GetPageId(),
	//	_Setting.GetParentGroup().GetName(),
	//	_Setting.GetName());
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	local JsonConfig_MCM_Page ConfigPage;
	local JsonConfig_Manager SaveConfigManager;

	ConfigPage = GetPage(Page.GetPageId());
	SaveConfigManager = JsonConfig_Manager(class'Engine'.static.FindClassDefaultObject(ConfigPage.SaveConfigManager));

	//SaveConfigManager.static.SetConfigString("VERSION_CFG", `MCM_CH_GetCompositeVersion());
	SaveConfigManager.static.SerializeAndSaveConfig();
}

private function DeserializeConfig()
{
	local MCMConfigMapEntry MapEntry;
	local JSonObject JSonObject;
	local JsonConfig_MCM_Page MCMPage;
	local string SerializedMCMPage, PageID;

	`LOG(default.class @ GetFuncName() @ "found entries:" @ default.MCMPages.Length,, 'RPG');

	foreach default.MCMPages(SerializedMCMPage)
	{
		PageID = GetObjectKey(SanitizeJson(SerializedMCMPage));
		JSonObject = class'JSonObject'.static.DecodeJson(SanitizeJson(SerializedMCMPage));
	
		if (JSonObject != none && PageID != "")
		{
			if (DeserialzedPagesMap.Find('PageID', PageID) == INDEX_NONE)
			{
				MCMPage = new class'JsonConfig_MCM_Page';
				//MCMPage.ManagerInstance = self;
				MCMPage.Deserialize(JSonObject, PageID);
				MapEntry.PageID = PageID;
				MapEntry.MCMConfigPage = MCMPage;
				DeserialzedPagesMap.AddItem(MapEntry);
			}
		}
	}
}

//	Builder = new class'Config_MCM_Builder';
//	Builder.Page = 1;
//	Builder.Group = "My Group";
//	Builder.Type = "My Type";
//	ConfigManager.SetObject("Builder", Builder.Serialize());
//
//	ConfigManager.PropCache = class'JSonObject'.static.EncodeJson(ConfigManager);
//	ConfigManager.SaveConfig();


//	Builder = new class'Config_MCM_Builder';
//	Builder.Deserialize(JSonObject.GetObject("Builder"));
//	`LOG(default.class @ GetFuncName() @ JSonObject @ "PropertyName:" @ Builder @ "Value:" @ Builder.Page @ Builder.Group @ Builder.Type,, 'RPGO');

