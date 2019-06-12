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

	if (MCMBuilder.DeserialzedPagesMap.Length == 0)
	{
		MCMBuilder.DeserializeConfig();
	}

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
	local JsonConfig_MCM_Element MCMElementConfig;
	local JsonConfig_Manager SaveConfigManager;	
	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup Group;
	local name SetttingName;
	
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
			
			foreach MCMGroupConfig.Elements(MCMElementConfig)
			{
				SetttingName = name(Caps(MCMElementConfig.SettingName));

				switch (MCMElementConfig.Type)
				{
					case "Label":
						Group.AddLabel(
							SetttingName,
							MCMElementConfig.Label,
							MCMElementConfig.Tooltip
						);
						break;
					case "Button":
						Group.AddButton(
							SetttingName,
							MCMElementConfig.Label,
							MCMElementConfig.Tooltip,
							MCMElementConfig.ButtonLabel,
							ButtonClickHandler
						);
						break;
					case "Checkbox":
						Group.AddCheckbox(
							SetttingName,
							MCMElementConfig.Label,
							MCMElementConfig.Tooltip,
							SaveConfigManager.GetConfigBoolValue(MCMElementConfig.SettingName),
							BoolSaveHandler,
							BoolChangeHandler
						);
						break;
					case "Slider":
						Group.AddSlider(
							SetttingName,
							MCMElementConfig.Label,
							MCMElementConfig.Tooltip,
							float(MCMElementConfig.SliderMin),
							float(MCMElementConfig.SliderMax),
							float(MCMElementConfig.SliderStep),
							SaveConfigManager.GetConfigFloatValue(MCMElementConfig.SettingName),
							FloatSaveHandler,
							FloatChangeHandler
						);
						break;
					case "Spinner":
						Group.AddSpinner(
							SetttingName,
							MCMElementConfig.Label,
							MCMElementConfig.Tooltip,
							MCMElementConfig.Options.GetArrayValue(),
							SaveConfigManager.GetConfigStringValue(MCMElementConfig.SettingName),
							StringSaveHandler,
							StringChangeHandler
						);
						break;
					case "Dropdown":
						Group.AddDropdown(
							SetttingName,
							MCMElementConfig.Label,
							MCMElementConfig.Tooltip,
							MCMElementConfig.Options.GetArrayValue(),
							SaveConfigManager.GetConfigStringValue(MCMElementConfig.SettingName),
							StringSaveHandler,
							StringChangeHandler
						);
						break;
					default:
						`LOG(default.class @ GetFuncName() @ "unknown MCM element type" @ MCMElementConfig.Type);
						break;
				}
			}
		}
		
		Page.ShowSettings();
		Page.SetSaveHandler(SaveButtonClicked);
	}
}

simulated function ButtonClickHandler(MCM_API_Setting Setting);

simulated function BoolChangeHandler(MCM_API_Setting Setting, bool SettingValue);
simulated function BoolSaveHandler(MCM_API_Setting Setting, bool SettingValue)
{
	ElementSaveHandler(Setting, SettingValue);
}

simulated function FloatChangeHandler(MCM_API_Setting Setting, float SettingValue);
simulated function FloatSaveHandler(MCM_API_Setting Setting, float SettingValue)
{
	ElementSaveHandler(Setting, SettingValue);
}

simulated function StringChangeHandler(MCM_API_Setting Setting, string SettingValue);
simulated function StringSaveHandler(MCM_API_Setting Setting, string SettingValue)
{
	ElementSaveHandler(Setting, SettingValue);
}

simulated function ElementSaveHandler(MCM_API_Setting Setting, coerce string SettingValue)
{
	local JsonConfig_MCM_Page Page;
	local JsonConfig_Manager SaveConfigManager;

	Page = GetPage(Setting.GetParentGroup().GetParentPage().GetPageId());
	SaveConfigManager = JsonConfig_Manager(class'Engine'.static.FindClassDefaultObject(Page.SaveConfigManager));
	SaveConfigManager.static.SetConfigString(Caps(string(Setting.GetName())), SettingValue);
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	local JsonConfig_MCM_Page ConfigPage;
	local JsonConfig_Manager SaveConfigManager;

	ConfigPage = GetPage(Page.GetPageId());
	SaveConfigManager = JsonConfig_Manager(class'Engine'.static.FindClassDefaultObject(ConfigPage.SaveConfigManager));
	SaveConfigManager.static.SerializeAndSaveConfig();
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

static public function JsonConfig_MCM_Element GetElement(int PageID, name GroupName, name SettingName)
{
	local JsonConfig_MCM_Group Group;
	local JsonConfig_MCM_Element Element;

	Group = GetGroup(PageID, GroupName);

	foreach Group.Elements(Element)
	{
		if (name(Element.SettingName) == SettingName)
		{
			return Element;
		}
	}

	`LOG(default.class @ GetFuncName() @ "could not find JsonConfig_MCM_Element for" @ PageID @ GroupName @ SettingName,, 'RPG');

	return none;
}

public static function SerializeAndSaveBuilderConfig()
{
	local JsonConfig_MCM_Builder Builder;

	Builder = GetMCMBuilder();
	Builder.SerializeConfig();
	Builder.SaveConfig();
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

private function SerializeConfig()
{
	local MCMConfigMapEntry MapEntry;
	local JSonObject JSonObject;

	MCMPages.Length = 0;

	foreach DeserialzedPagesMap(MapEntry)
	{
		JSonObject = new () class'JsonObject';
		MapEntry.MCMConfigPage.Serialize(JSonObject, MapEntry.PageID);
		MCMPages.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
	}
}