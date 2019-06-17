class X2TemplateHelper_ExtendedUpgrades extends Object config (ExtendedUpgrades);

var config bool bReconfigureVanillaAttachements;
var config array<LootTable> LootTables;
var config array<name> OverrideAttachment;

static function PatchTemplates()
{
	PatchTemplatesWithHairTriggerShot();
}

static function PatchTemplatesWithHairTriggerShot()
{
	local X2AbilityTemplateManager   TemplateManager;
	local X2AbilityTemplate          Template;
	local Array<name>				 TemplateNames;
	local name						 TemplateName;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	TemplateNames.AddItem('StandardShot');
	TemplateNames.AddItem('SniperStandardFire');
	TemplateNames.AddItem('PistolStandardShot');

	foreach TemplateNames(TemplateName)
	{
		Template = TemplateManager.FindAbilityTemplate(TemplateName);
		if (Template != none)
		{
			Template.PostActivationEvents.AddItem('HairTriggerShot');
		}
	}
	
	Template = TemplateManager.FindAbilityTemplate('Reload');
	if (Template != none)
	{
		Template.PostActivationEvents.AddItem('Reload');
	}
	
}

static function ReconfigDefaultAttachments()
{
	local X2DataTemplateManager TemplateManager;
	local X2WeaponUpgradeTemplate ItemTemplate;
	local array<Name> TemplateNames;
	local Name TemplateName;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate;
	local int Difficulty;
	
	TemplateManager	= class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	TemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		TemplateManager.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
		foreach DataTemplates(DataTemplate)
		{
			ItemTemplate = X2WeaponUpgradeTemplate(DataTemplate);
			if(ItemTemplate != none)
			{
				Difficulty = GetDifficultyFromTemplateName(TemplateName);
				ReconfigAttachment(ItemTemplate, Difficulty);
			}
		}
	}
}

static function ReconfigAttachment(X2WeaponUpgradeTemplate WeaponUpgradeTemplate, int Difficulty)
{
	local X2WeaponUpgradeTemplate UnpatchedTemplate;

	class'RPGOTemplateCache'.static.AddWeaponUpgradeTemplate(WeaponUpgradeTemplate);
	UnpatchedTemplate = class'RPGOTemplateCache'.static.GetWeaponUpgradeTemplate(WeaponUpgradeTemplate.DataName);

	if (WeaponUpgradeTemplate != none && default.OverrideAttachment.Find(WeaponUpgradeTemplate.DataName) != INDEX_NONE)
	{
		//specific alterations
		if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_LASER_SIGHTS"))
		{
			if (WeaponUpgradeTemplate.DataName == 'CritUpgrade_Bsc')
			{
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.BasicLaserSightAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'CritUpgrade_Adv')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_LASER_SIGHTS"))
			{
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.AdvancedLaserSightAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}

		}

		if (WeaponUpgradeTemplate.DataName == 'CritUpgrade_Sup')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_LASER_SIGHTS"))
			{
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.SuperiorLaserSightAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}
		
		if (WeaponUpgradeTemplate.DataName == 'AimUpgrade_Bsc')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SCOPES"))
			{
				WeaponUpgradeTemplate.AimBonus = 0;
				WeaponUpgradeTemplate.AddHitChanceModifierFn = none;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.BasicScopeAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.AimBonus = UnpatchedTemplate.AimBonus;
				WeaponUpgradeTemplate.AddHitChanceModifierFn = UnpatchedTemplate.AddCritChanceModifierFn;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}
		if (WeaponUpgradeTemplate.DataName == 'AimUpgrade_Adv')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SCOPES"))
			{
				WeaponUpgradeTemplate.AimBonus = 0;
				WeaponUpgradeTemplate.AddHitChanceModifierFn = none;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.AdvancedScopeAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.AimBonus = UnpatchedTemplate.AimBonus;
				WeaponUpgradeTemplate.AddHitChanceModifierFn = UnpatchedTemplate.AddCritChanceModifierFn;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}
		if (WeaponUpgradeTemplate.DataName == 'AimUpgrade_Sup')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_SCOPES"))
			{
				WeaponUpgradeTemplate.AimBonus = 0;
				WeaponUpgradeTemplate.AddHitChanceModifierFn = none;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.SuperiorScopeAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.AimBonus = UnpatchedTemplate.AimBonus;
				WeaponUpgradeTemplate.AddHitChanceModifierFn = UnpatchedTemplate.AddCritChanceModifierFn;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'MissDamageUpgrade_Bsc')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_STOCKS"))
			{
				WeaponUpgradeTemplate.BonusDamage.Damage = 0;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.BasicStockAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.BonusDamage.Damage = UnpatchedTemplate.BonusDamage.Damage;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}
		if (WeaponUpgradeTemplate.DataName == 'MissDamageUpgrade_Adv')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_STOCKS"))
			{
				WeaponUpgradeTemplate.BonusDamage.Damage = 0;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.AdvancedStockAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.BonusDamage.Damage = UnpatchedTemplate.BonusDamage.Damage;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}
		if (WeaponUpgradeTemplate.DataName == 'MissDamageUpgrade_Sup')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_STOCKS"))
			{
				WeaponUpgradeTemplate.BonusDamage.Damage = 0;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.SuperiorStockAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.BonusDamage.Damage = UnpatchedTemplate.BonusDamage.Damage;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}
			
		if (WeaponUpgradeTemplate.DataName == 'FreeFireUpgrade_Bsc')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_HAIR_TRIGGERS"))
			{
				WeaponUpgradeTemplate.FreeFireCostFn = none;
				WeaponUpgradeTemplate.FreeFireChance = 0;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.BasicHairTriggerAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.FreeFireCostFn = UnpatchedTemplate.FreeFireCostFn;
				WeaponUpgradeTemplate.FreeFireChance = UnpatchedTemplate.FreeFireChance;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'FreeFireUpgrade_Adv')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_HAIR_TRIGGERS"))
			{
				WeaponUpgradeTemplate.FreeFireCostFn = none;
				WeaponUpgradeTemplate.FreeFireChance = 0;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.AdvancedHairTriggerAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.FreeFireCostFn = UnpatchedTemplate.FreeFireCostFn;
				WeaponUpgradeTemplate.FreeFireChance = UnpatchedTemplate.FreeFireChance;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'FreeFireUpgrade_Sup')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_HAIR_TRIGGERS"))
			{
				WeaponUpgradeTemplate.FreeFireCostFn = none;
				WeaponUpgradeTemplate.FreeFireChance = 0;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.SuperiorHairTriggerAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.FreeFireCostFn = UnpatchedTemplate.FreeFireCostFn;
				WeaponUpgradeTemplate.FreeFireChance = UnpatchedTemplate.FreeFireChance;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'ReloadUpgrade_Bsc')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_AUTOLOADERS"))
			{
				WeaponUpgradeTemplate.FreeReloadCostFn = none;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.FriendlyRenameFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.BasicAutoLoaderAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.FreeReloadCostFn = UnpatchedTemplate.FreeReloadCostFn;
				WeaponUpgradeTemplate.FriendlyRenameFn = UnpatchedTemplate.FriendlyRenameFn;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'ReloadUpgrade_Adv')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_AUTOLOADERS"))
			{
				WeaponUpgradeTemplate.FreeReloadCostFn = none;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.FriendlyRenameFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.AdvancedAutoLoaderAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.FreeReloadCostFn = UnpatchedTemplate.FreeReloadCostFn;
				WeaponUpgradeTemplate.FriendlyRenameFn = UnpatchedTemplate.FriendlyRenameFn;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		if (WeaponUpgradeTemplate.DataName == 'ReloadUpgrade_Sup')
		{
			if (class'RPGOUserSettingsConfigManager'.static.GetConfigBoolValue("PATCH_AUTOLOADERS"))
			{
				WeaponUpgradeTemplate.FreeReloadCostFn = none;
				WeaponUpgradeTemplate.GetBonusAmountFn = none;
				WeaponUpgradeTemplate.FriendlyRenameFn = none;
				WeaponUpgradeTemplate.BonusAbilities.length = 0;
				WeaponUpgradeTemplate.BonusAbilities.AddItem (class'X2Ability_UpgradeAbilitySet'.default.SuperiorAutoLoaderAbilityName);
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, true);
			}
			else
			{
				WeaponUpgradeTemplate.FreeReloadCostFn = UnpatchedTemplate.FreeReloadCostFn;
				WeaponUpgradeTemplate.FriendlyRenameFn = UnpatchedTemplate.FriendlyRenameFn;
				WeaponUpgradeTemplate.GetBonusAmountFn = UnpatchedTemplate.GetBonusAmountFn;
				WeaponUpgradeTemplate.BonusAbilities = UnpatchedTemplate.BonusAbilities;
				SetLocalization(WeaponUpgradeTemplate, UnpatchedTemplate, false);
			}
		}

		//if (WeaponUpgradeTemplate.DataName == 'FreeKillUpgrade_Bsc' ||
		//	WeaponUpgradeTemplate.DataName == 'FreeKillUpgrade_Adv' ||
		//	WeaponUpgradeTemplate.DataName == 'FreeKillUpgrade_Sup')
		//{
		//	WeaponUpgradeTemplate.FreeKillChance = 0;
		//	WeaponUpgradeTemplate.FreeKillFn = none;
		//	WeaponUpgradeTemplate.GetBonusAmountFn = none;
		//	//Abilities are added by supressor mechanic
		//}

		`LOG("Patch" @ WeaponUpgradeTemplate.DataName,, 'ExtendedUpgrades');

		WeaponUpgradeTemplate.CanApplyUpgradeToWeaponFn = CanApplyUpgradeToWeaponEU;
	}
}

static function SetLocalization(
	out X2WeaponUpgradeTemplate WeaponUpgradeTemplate,
	X2WeaponUpgradeTemplate UnpatchedTemplate,
	bool bOverride)
{
	if (bOverride)
	{
		WeaponUpgradeTemplate.FriendlyName = Localize(WeaponUpgradeTemplate.DataName $ "_OVERIDE X2WeaponUpgradeTemplate", "FriendlyName", "XComGame");
		WeaponUpgradeTemplate.FriendlyNamePlural = Localize(WeaponUpgradeTemplate.DataName $ "_OVERIDE X2WeaponUpgradeTemplate", "FriendlyNamePlural", "XComGame");
		WeaponUpgradeTemplate.BriefSummary = Localize(WeaponUpgradeTemplate.DataName $ "_OVERIDE X2WeaponUpgradeTemplate", "BriefSummary", "XComGame");
		WeaponUpgradeTemplate.TinySummary = Localize(WeaponUpgradeTemplate.DataName $ "_OVERIDE X2WeaponUpgradeTemplate", "TinySummary", "XComGame");
		WeaponUpgradeTemplate.LootTooltip = Localize(WeaponUpgradeTemplate.DataName $ "_OVERIDE X2WeaponUpgradeTemplate", "LootTooltip", "XComGame");
	}
	else
	{
		WeaponUpgradeTemplate.FriendlyName = UnpatchedTemplate.FriendlyName;
		WeaponUpgradeTemplate.FriendlyNamePlural = UnpatchedTemplate.FriendlyNamePlural;
		WeaponUpgradeTemplate.BriefSummary = UnpatchedTemplate.BriefSummary;
		WeaponUpgradeTemplate.TinySummary = UnpatchedTemplate.TinySummary;
		WeaponUpgradeTemplate.LootTooltip = UnpatchedTemplate.LootTooltip;
	}
}

static function bool CanApplyUpgradeToWeaponEU(X2WeaponUpgradeTemplate UpgradeTemplate, XComGameState_Item Weapon, int SlotIndex)
{
	local X2WeaponTemplate WeaponTemplate;

	WeaponTemplate = X2WeaponTemplate(Weapon.GetMyTemplate());

	`LOG(GetFuncName() @ UpgradeTemplate.DataName @ WeaponTemplate.WeaponCat,, 'ExtendedUpgrades');

	if (WeaponTemplate != none && WeaponTemplate.iRange != INDEX_NONE)
	{
		return false;
	}

	return class'X2Item_DefaultUpgrades'.static.CanApplyUpgradeToWeapon(UpgradeTemplate, Weapon, SlotIndex);
}

static function AddLootTables()
{
	local LootTable Loot;
	local LootTableEntry Entry;
	local X2LootTableManager LootManager;
	local int Index;
	local bool bLog;

	bLog = false;

	`LOG("AddLootTables LootTables.Length" @ default.LootTables.Length, bLog, 'ExtendedUpgrades');

	foreach default.LootTables(Loot)
	{
		foreach Loot.Loots(Entry)
		{
			`LOG("Adding" @ Entry.TemplateName @ "(" $ Entry.TableRef $ ")"  @ "Table" @ Loot.TableName, bLog, 'ExtendedUpgrades');
			class'X2LootTableManager'.static.AddEntryStatic(Loot.TableName, Entry, false);
		}
		class'X2LootTableManager'.static.RecalculateLootTableChanceStatic(Loot.TableName);

		LootManager = X2LootTableManager(class'Engine'.static.FindClassDefaultObject("X2LootTableManager"));
		Index = LootManager.default.LootTables.Find('TableName', Loot.TableName);
		`LOG("New Loot Table" @ Loot.TableName, bLog, 'ExtendedUpgrades');
		foreach LootManager.LootTables[Index].Loots(Entry)
		{
			`LOG("	->" $ Entry.TemplateName @ Entry.TableRef @ Entry.RollGroup @ Entry.Chance, bLog, 'ExtendedUpgrades');
		}
	}
}

static function int GetDifficultyFromTemplateName(name TemplateName)
{
	return int(GetRightMost(string(TemplateName)));
}

static function bool HasLaserWeapons()
{
	return IsModInstalled('X2DownloadableContentInfo_LWLaserPack') || IsModInstalled('X2DownloadableContentInfo_LW_Overhaul');
}

static function bool HasSMGWeapons()
{
	return IsModInstalled('X2DownloadableContentInfo_LWSMGPack') || IsModInstalled('X2DownloadableContentInfo_LW_Overhaul');
}

static function bool HasMercPlasmaWeapons()
{
	return IsModInstalled('X2DownloadableContentInfo_MercenaryPlasmaWeapons') || IsModInstalled('X2DownloadableContentInfo_LW2MercenaryPlasmaWeapons');
}

static function bool HasCoilGuns()
{
	return IsModInstalled('X2DownloadableContentInfo_LW_Coilpack') || IsModInstalled('X2DownloadableContentInfo_LW_Overhaul');
}

static function bool IsModInstalled(name X2DCIName)
{
	local X2DownloadableContentInfo Mod;
	foreach `ONLINEEVENTMGR.m_cachedDLCInfos (Mod)
	{
		if (Mod.Class.Name == X2DCIName)
		{
			return true;
		}
	}

	return false;
}