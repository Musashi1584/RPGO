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

//	Random Classes
struct SpecializationMetaInfoStruct
{
	// Enables the spec to participate in the Random Classes SWO
	var bool bUseForRandomClasses;

	// This are the weapon categories provided when the Weapon Restriction SWO is enabled
	var array<name> AllowedWeaponCategories;

	// The weapon categories are supplied to these inventory slots. This is also used by the Random Classes SWO algorithm
	var array<EInventorySlot> InventorySlots;

	// Currently not used
	var array<name> SpecializationRoles;

	// Define specs that should not be rolled together with this spec by the Random Classes SWO
	var array<name> MutuallyExclusiveSpecs;

	//	This specialization can be rolled only as Primary one, and then will provide access to the same AllowedWeaponCategories for both weapon slots.
	//	It can also be rolled as Secondary to a non-Dual Wield primary spec that uses same weapons in the same slots.
	//	It can also be rolled as Complementary to a primary Dual Wield spec, even if bCantBeComplementary = true.
	var bool bDualWield;

	//	Use to determine whether this specialization is valid to complement other soldier's specializations.
	//	it means this spec can complement any other spec in existence because it doesn't depend on equipment, e.g. Scout (phantom and stuff).
	var bool bUniversal;

	//	this spec requires a firearm to function properly.
	var bool bShoot;

	//	requires a melee weapon (ripjack counts as one)
	var bool bMelee;
	
	//	requires a Gremlin 
	var bool bGremlin;

	//	requires Psi Amp. 
	var bool bPsionic;

	//	this spec can be used only as primary or secondary, but cannot complement other specs. "Skirmisher" spec is a good example, as it pretty much requires a ripjack to function. 
	var bool bCantBeComplementary;

	// Weights used by the Random Classes SWO algorithm
	var int  iWeightPrimary;
	var int  iWeightSecondary;
	var int  iWeightComplementary;

	structdefaultproperties
	{
		iWeightPrimary = 1
		iWeightSecondary = 1
		iWeightComplementary = 1
	}
};

struct ClassInsignia
{
	var int UnitObjectID;
	var string ClassImagePath;
	var string ClassTitle;
	var string ClassDescription;
};