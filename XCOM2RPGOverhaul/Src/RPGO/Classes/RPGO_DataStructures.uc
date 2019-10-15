class RPGO_DataStructures extends Object;

struct LongWarUpgradeInfo
{
	var name ResearchName;
	var name BaseItemName;
	var name ItemName;
};

struct StatVal
{
	var ECharStatType	StatType;
	var float			StatValue;
};

struct StatCap
{
	var ECharStatType	StatType;
	var float			StatCapValue;
};

struct EquipmentStatCap
{
	// will be matched in order
	var name TemplateName;
	var name WeaponCategoryName; // cannon, sniper_rifle, shotgun, rifle, vektor_rifle, bullpup, sword, pistol, sidearm, baton, claymore, gauntlet, wristblade, psiamp, sparkrifle, sparkbit, shoulder_launcher, heavy, grenade, utility, medikit, skulljack
	var name ItemCategoryName; // weapon, utility, armor, combatsim, ammo, tech, grenade, heal
	var name ArmorClass; // light, medium, heavy
	var string ValueConfigKey;

	var StatCap Cap;
};
