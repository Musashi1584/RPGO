class DataStructure_StatUpgradeUI extends Object;

enum ENaturalAptitude
{
	eNaturalAptitude_Standard,
	eNaturalAptitude_AboveAverage,
	eNaturalAptitude_Gifted,
	eNaturalAptitude_Genius,
	eNaturalAptitude_Savant,
};

struct StatCostBind
{
	var ECharStatType Stat;
	var int AbilityPointCost;
	var int NonLinearProgressionCostLamda;
};

struct StatIconBind
{
	var ECharStatType Stat;
	var string Icon;
};

struct StatLocaleBind
{
	var ECharStatType Stat;
	var string LocalString;
};

struct ClassStatPoints
{
	var name SoldierClassTemplateName;
	var int StatPointsPerPromotion;
};