//-----------------------------------------------------------
//	Class:	SWO_Helper
//	Author: Musashi
//	
//-----------------------------------------------------------


class SWO_Helper extends Object;

static function JsonConfig_ManagerInterface GetUserSettingsConfig()
{
	return class'ConfigFactory'.static.GetConfigManager("RPGOUserSettingsConfigManager");
}

static function JsonConfig_ManagerInterface GetUserSettingsSWOConfig()
{
	return class'ConfigFactory'.static.GetConfigManager("RPGO_SWO_UserSettingsConfigManager");
}