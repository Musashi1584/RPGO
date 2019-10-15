class RPGO_Structs extends Object;

struct SoldierSpecialization
{
	var int Order;
	var name TemplateName;
	var bool bEnabled;
	structdefaultproperties
	{
		bEnabled = true
	}
};

struct AbilityWeaponCategoryRestriction
{
	var name AbilityName;
	var array<name> WeaponCategories;
};

struct AbilityPrerequisite
{
	var array<name> PrerequisiteTree;
};

struct MutuallyExclusiveAbilityPool
{
	var array<name> Abilities;
};

struct UniqueItemCategories
{
	var array<name> Categories;
};

struct WeaponProficiency
{
	var name AbilityName;
	var name UnlocksWeaponCategory;
};
