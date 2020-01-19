//-----------------------------------------------------------
//	Class:	RPGO_JsonConfig_Interface
//	Author: Musashi
//	
//-----------------------------------------------------------


interface RPGO_JsonConfig_Interface;

public function Serialize(out JsonObject JsonObject, string PropertyName);
public function bool Deserialize(JSonObject Data, string PropertyName);

