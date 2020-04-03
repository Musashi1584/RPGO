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

//	IRI Random Classes
struct IRIMetaInfoStruct
{
	var bool bMeta;
	var array<name> AllowedWeaponCategories;
	var array<EInventorySlot> InventorySlots;

	//	This specialization can be rolled only as Primary one, and then will provide access to the same AllowedWeaponCategories for both weapon slots.
	var bool bDualWield;

	//	Use to determine whether this specialization is valid to complement other soldier's specializations.
	var bool bUniversal;
	var bool bShoot;
	var bool bMelee;
	var bool bGremlin;
	var bool bPsionic;
	var bool bCantBeComplementary;
	var int  iWeightPrimary;
	var int  iWeightSecondary;
	var int  iWeightComplementary;

	//	check necromancer skills that are weapon agnostic
	//	look at AllowedWeapons instead of using bool flags?..
	structdefaultproperties
	{
		iWeightPrimary = 1
		iWeightSecondary = 1
		iWeightComplementary = 1
	}
};