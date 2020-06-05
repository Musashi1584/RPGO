class X2Ability_ShadowOps extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(Firebug());
	Templates.AddItem(Scrounger());
	Templates.AddItem(ScroungerTrigger());
	Templates.AddItem(Airstrike());

	return Templates;
}
	
static function X2AbilityTemplate Firebug()
{
	local X2Effect_AddGrenade ItemEffect;

	ItemEffect = new class 'X2Effect_AddGrenade';
	ItemEffect.DataName = 'Firebomb';
	ItemEffect.SkipAbilities.AddItem('SmallItemWeight');

	return Passive('RpgFirebug', "img:///UILibrary_RPGO.UIPerk_pyromaniac", true, ItemEffect);
}

static function X2AbilityTemplate Scrounger()
{
	local X2AbilityTemplate						Template;
	
	Template = PurePassive('RpgScrounger', "img:///UILibrary_RPGO.UIPerk_scrounger", true);
	Template.AdditionalAbilities.AddItem('RpgScroungerTrigger');

	return Template;
}

static function X2AbilityTemplate ScroungerTrigger()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgScroungerTrigger');
	Template.IconImage = "img:///UILibrary_RPGO.UIPerk_scrounger";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	MultiTargetStyle = new class'X2AbilityMultiTarget_AllUnits';
	MultiTargetStyle.bAcceptEnemyUnits = true;
	MultiTargetStyle.bRandomlySelectOne = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	Template.AddMultiTargetEffect(new class'X2Effect_DropLoot');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Airstrike()
{
	local X2AbilityTemplate                 Template;	
	local X2Condition_Visibility            VisibilityCondition;
	local X2Effect_ApplyWeaponDamage		Effect;
	local X2Effect_ApplyFireToWorld			FireEffect;
	local X2AbilityToHitCalc_StandardAim	StandardAim;
	local X2AbilityMultiTarget_Cylinder		MultiTarget;

	// Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RpgAirstrike');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_RPGO.UIPerk_airstrike";
	Template.ShotHUDPriority = default.AUTO_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = false;
	Template.AbilitySourceName = 'eAbilitySource_Perk'; 
	Template.Hostility = eHostility_Offensive;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AddShooterEffectExclusions();

	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bVisibleToAnyAlly = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);

	Template.AbilityTargetStyle = new class'X2AbilityTarget_Cursor';
	Template.TargetingMethod = class'X2TargetingMethod_ViperSpit';

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_DoubleConsumeAll));

	MultiTarget = new class'X2AbilityMultiTarget_Cylinder';
	MultiTarget.bUseOnlyGroundTiles = true;
	MultiTarget.bIgnoreBlockingCover = true;
	MultiTarget.fTargetRadius = 10;
	MultiTarget.fTargetHeight = 10;
	Template.AbilityMultiTargetStyle = MultiTarget;
	
	Effect = new class'X2Effect_ApplyWeaponDamage';
	Effect.EffectDamageValue = class'RPGOAbilityConfigManager'.static.GetConfigDamageValue("AIRSTRIKEDAMAGE");
	Effect.bExplosiveDamage = true;
	Effect.bIgnoreBaseDamage = true;
	Effect.EnvironmentalDamageAmount = 40;

	Template.AddMultiTargetEffect(Effect);

	FireEffect = new class'X2Effect_ApplyFireToWorld';
	FireEffect.bCheckForLOSFromTargetLocation = false;
	Template.AddMultiTargetEffect(FireEffect);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	StandardAim.bAllowCrit = false;
	StandardAim.bIndirectFire = true;
	Template.AbilityToHitCalc = StandardAim;
	
	Template.bUsesFiringCamera = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = Airstrike_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	// Template.bSkipFireAction = true;
	Template.CustomFireAnim = 'FF_Fire';
	Template.bSkipExitCoverWhenFiring = true;

	Template.bCrossClassEligible = false;

	AddCharges(Template, class'RPGOAbilityConfigManager'.static.GetConfigIntValue("AIRSTRIKECHARGES"));

	return Template;	
}

// Courtesy of robojumper
static simulated function Airstrike_BuildVisualization(XComGameState VisualizeGameState)
{
        local XComGameStateHistory History;
        local XComGameStateContext_Ability Context;
        local StateObjectReference InteractingUnitRef;

        local XComGameState_Ability AbilityState;
        local X2AbilityTemplate AbilityTemplate;
        
        local VisualizationActionMetadata EmptyTrack;
        local VisualizationActionMetadata BuildTrack;
        local X2Action_PlayAnimation PlayAnimation;
        local X2VisualizerInterface TargetVisualizerInterface;
        local int i, j;
        local XComGameState_EnvironmentDamage DamageEventStateObject;
        

        History = class'XComGameStateHistory'.static.GetGameStateHistory();

        Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

        AbilityState = XComGameState_Ability(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
        AbilityTemplate = AbilityState.GetMyTemplate();
        
        //Configure the visualization track for the shooter
        //****************************************************************************************

        //****************************************************************************************
        InteractingUnitRef = Context.InputContext.SourceObject;
        BuildTrack = EmptyTrack;
        BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
        BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
        BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

        // Exit Cover
        class'X2Action_ExitCover'.static.AddToVisualizationTree(BuildTrack, Context);

        // Play the firing action (requires CustomFireAnim)
        PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(BuildTrack, Context));
        PlayAnimation.Params.AnimName = AbilityTemplate.CustomFireAnim;

        // Air strike:
        // is a part of the shooter track, because who else would be the track actor?
        // this action will notify all the targets that the projectile hit
        class'X2Action_Airstrike'.static.AddToVisualizationTree(BuildTrack, Context);

        // enter cover
        class'X2Action_EnterCover'.static.AddToVisualizationTree(BuildTrack, Context);


        //****************************************************************************************

        //****************************************************************************************
        //Configure the visualization track for the targets
        //****************************************************************************************
        for( i = 0; i < Context.InputContext.MultiTargets.Length; ++i )
        {
                InteractingUnitRef = Context.InputContext.MultiTargets[i];
                BuildTrack = EmptyTrack;
                BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
                BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
                BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

                class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( BuildTrack, Context );

                for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
                {
                        Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
                }

                TargetVisualizerInterface = X2VisualizerInterface(BuildTrack.VisualizeActor);
                if( TargetVisualizerInterface != none )
                {
                        //Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
                        TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildTrack);
                }
        }
        //****************************************************************************************

        //****************************************************************************************
        //Configure the visualization track for the targets
        //****************************************************************************************
        // add visualization of environment damage
        foreach VisualizeGameState.IterateByClassType( class'XComGameState_EnvironmentDamage', DamageEventStateObject )
        {
                BuildTrack = EmptyTrack;
                BuildTrack.StateObject_OldState = DamageEventStateObject;
                BuildTrack.StateObject_NewState = DamageEventStateObject;
                BuildTrack.VisualizeActor = class'XComGameStateHistory'.static.GetGameStateHistory().GetVisualizer(DamageEventStateObject.ObjectID);
                class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(BuildTrack, Context);
                class'X2Action_ApplyWeaponDamageToTerrain'.static.AddToVisualizationTree(BuildTrack, Context);
        }
        //****************************************************************************************

}