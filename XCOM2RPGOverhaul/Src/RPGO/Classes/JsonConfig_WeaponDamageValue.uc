//-----------------------------------------------------------
//	Class:	JsonConfig_WeaponDamageValue
//	Author: Musashi
//	
//-----------------------------------------------------------
class JsonConfig_WeaponDamageValue extends Object;

var protectedwrite WeaponDamageValue DamageValue;

public function SetVectorValue(WeaponDamageValue DamageValueParam)
{
	DamageValue = DamageValueParam;
}

public function WeaponDamageValue GetDamageValue()
{
	return DamageValue;
}

public function string ToString()
{
	// @TODO make proper damage preview function
	return  (DamageValue.Damage - DamageValue.Spread) $ "-" $ (DamageValue.Damage + DamageValue.Spread);
}

public function Serialize(out JsonObject JsonObject, string PropertyName)
{
	JSonObject.SetStringValue(PropertyName, "{\"Damage\":" $ DamageValue.Damage $
											 ",\"Spread\":" $ DamageValue.Spread $
											 ",\"PlusOne\":" $ DamageValue.PlusOne $
											 ",\"Crit\":" $ DamageValue.Crit $
											 ",\"Pierce\":" $ DamageValue.Pierce $
											 ",\"Rupture\":" $ DamageValue.Rupture $
											 ",\"Shred\":" $ DamageValue.Shred $
											 ",\"Tag\":\"" $ DamageValue.Tag $ "\"" $
											 ",\"DamageType\":\"" $ DamageValue.DamageType $ "\"" $
											 "}");
}

public function bool Deserialize(JSonObject Data, string PropertyName)
{
	local JsonObject DamageValueJson;

	DamageValueJson = Data.GetObject(PropertyName);
	if (DamageValueJson != none)
	{
		DamageValue.Damage = DamageValueJson.GetIntValue("Damage");
		DamageValue.Spread = DamageValueJson.GetIntValue("Spread");
		DamageValue.PlusOne = DamageValueJson.GetIntValue("PlusOne");
		DamageValue.Crit = DamageValueJson.GetIntValue("Crit");
		DamageValue.Pierce = DamageValueJson.GetIntValue("Pierce");
		DamageValue.Rupture = DamageValueJson.GetIntValue("Rupture");
		DamageValue.Shred = DamageValueJson.GetIntValue("Shred");
		DamageValue.Tag = name(DamageValueJson.GetStringValue("Tag"));
		DamageValue.DamageType = name(DamageValueJson.GetStringValue("DamageType"));
		
	}

	return false;
}