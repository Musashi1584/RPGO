class X2Action_Airstrike extends X2Action_Fire;

var private CustomAnimParams Params;
var private AnimNotify_FireWeaponVolley FireWeaponNotify;
var private int TimeDelayIndex;

var X2UnifiedProjectile RocketLauncherProjectile;

var bool		ProjectileHit;
/*var XGWeapon	UseWeapon;
var XComWeapon	PreviousWeapon;*/
var XComUnitPawn FocusUnitPawn;
//*************************************

function bool CheckInterrupted()
{
	return false;
}

function NotifyTargetsAbilityApplied()
{
	super.NotifyTargetsAbilityApplied();
	ProjectileHit = true;
}

function AddProjectiles()
{
	local TTile SourceTile;
	local XComWorldData World;
	local vector SourceLocation, ImpactLocation;
	local int ZValue;

	local X2UnifiedProjectile NewProjectile;
	local AnimNotify_FireWeaponVolley FireVolleyNotify;

	World = `XWORLD;

	// Move it above the top level of the world a bit with *2
	ZValue = World.WORLD_FloorHeightsPerLevel * World.WORLD_TotalLevels * 2;

	ImpactLocation = AbilityContext.InputContext.TargetLocations[0];

	// Calculate the upper z position for the projectile
	SourceTile = World.GetTileCoordinatesFromPosition(ImpactLocation);
	
	World.GetFloorPositionForTile(SourceTile, ImpactLocation);

	SourceTile.Z = ZValue;
	
	SourceLocation = World.GetPositionFromTileCoordinates(SourceTile);
	// don't have it be completely vertical
	SourceLocation.X += 280;

	FireVolleyNotify = new class'AnimNotify_FireWeaponVolley';
	FireVolleyNotify.NumShots = 1;
	FireVolleyNotify.ShotInterval = 0.3f;
	FireVolleyNotify.bCosmeticVolley = true;

	NewProjectile = class'WorldInfo'.static.GetWorldInfo().Spawn(class'X2UnifiedProjectile', , , , , RocketLauncherProjectile);
	NewProjectile.ConfigureNewProjectileCosmetic(FireVolleyNotify, AbilityContext, , , Unit.CurrentFireAction, SourceLocation, TargetLocation, true);
	NewProjectile.GotoState('Executing');


}

simulated state Executing
{
Begin:
	/*PreviousWeapon = XComWeapon(UnitPawn.Weapon);
	UnitPawn.SetCurrentWeapon(XComWeapon(UseWeapon.m_kEntity));*/

	Unit.CurrentFireAction = self;

	AddProjectiles();

	while (!ProjectileHit)
	{
		Sleep(0.01f);
	}

	//UnitPawn.SetCurrentWeapon(PreviousWeapon);

	Sleep(0.5f * GetDelayModifier()); // Sleep to allow destruction to be seenw

	CompleteAction();
}

defaultproperties
{
	// this works for vanilla assets
	// if we have to use our own projectile, consider using
	// DynamicLoadObject or `CONTENT.RequestGameArchetype
	RocketLauncherProjectile=X2UnifiedProjectile'WP_Heavy_RocketLauncher.PJ_Heavy_RocketLauncher'
}