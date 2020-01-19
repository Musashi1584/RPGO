//-----------------------------------------------------------
//	Class:	RPGOAbilityConfigManager
//	Author: Musashi
//	
//-----------------------------------------------------------
class RPGOAbilityConfigManager extends RPGO_JsonConfig_Manager config (RPGO_SoldierSkills);

function bool OnTagFunction(name TagFunctionName, RPGO_JsonConfig_TaggedConfigProperty ConfigProperty, out string TagValue)
{
	switch (TagFunctionName)
	{
		case 'TagValueLockDown':
			 TagValue = string(Round(float(ConfigProperty.GetValue()) * (1 - class'X2AbilityToHitCalc_StandardAim'.default.REACTION_FINALMOD)));
			 return true;
			 break;
		default:
			break;
	}

	return false;
}