class X2Condition_ArcthrowerAbilities extends X2Condition config (RPG);

var config array<name> ARCTHROWER_ABILITIES;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
    local name                      AbilityName;
    local XComGameState_Item        SourceWeapon;

    if(kAbility == none)
        return 'AA_InvalidAbilityName';

    SourceWeapon = kAbility.GetSourceWeapon();
    AbilityName = kAbility.GetMyTemplateName();

    if (SourceWeapon == none)
        return 'AA_InvalidAbilityName';

    if (default.ARCTHROWER_ABILITIES.Find(AbilityName) != INDEX_NONE)
        return 'AA_Success';

    return 'AA_InvalidAbilityName';
}