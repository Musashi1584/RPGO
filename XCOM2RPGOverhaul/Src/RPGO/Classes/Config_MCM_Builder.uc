class Config_MCM_Builder extends Object;

var int Page;
var string Group;
var string Type;

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

function JSonObject Serialize()
{
	local JsonObject JsonObject;

	JSonObject = new () class'JsonObject';
	JSonObject.SetIntValue("Page", Page);
	JSonObject.SetStringValue("Group", Group);
	JSonObject.SetStringValue("Type", Type);

	return JSonObject;
}

function Deserialize(JSonObject Data)
{
	Page = Data.GetIntValue("Page");
	Group = Data.GetStringValue("Group");
	Type = Data.GetStringValue("Type");
}