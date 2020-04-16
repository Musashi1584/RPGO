//-----------------------------------------------------------
//	Class:	XComGameState_CustomClassInsignia
//	Author: Musashi
//	
//-----------------------------------------------------------
class XComGameState_CustomClassInsignia extends XComGameState_BaseObject dependson(RPGO_Structs);

var array<ClassInsignia> UnitClassInsignias;

public static function XComGameState_CustomClassInsignia GetGameState()
{
	return XComGameState_CustomClassInsignia(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CustomClassInsignia', true));
}

public static function CreateGameState(out XComGameState NewGameState)
{
	local XComGameState_CustomClassInsignia CustomClassInsigniaGameState;
	
	CustomClassInsigniaGameState = XComGameState_CustomClassInsignia(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CustomClassInsignia', true));

	if (CustomClassInsigniaGameState == none || CustomClassInsigniaGameState.ObjectID == 0)
	{
		CustomClassInsigniaGameState = XComGameState_CustomClassInsignia(NewGameState.CreateNewStateObject(class'XComGameState_CustomClassInsignia'));
	}
}

function SetClassIconForUnit(string ClassImagePath, int UnitObjectID)
{
	local int Index;
	local ClassInsignia NewUnitClassInsignia;
	
	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);
	if (Index != INDEX_NONE)
	{
		UnitClassInsignias[Index].ClassImagePath = ClassImagePath;
	}
	else
	{
		NewUnitClassInsignia.UnitObjectID = UnitObjectID;
		NewUnitClassInsignia.ClassImagePath = ClassImagePath;
		UnitClassInsignias.AddItem(NewUnitClassInsignia);
	}
}

function SetClassTitleForUnit(string ClassTitle, int UnitObjectID)
{
	local int Index;
	local ClassInsignia NewUnitClassInsignia;
	
	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);
	if (Index != INDEX_NONE)
	{
		UnitClassInsignias[Index].ClassTitle = ClassTitle;
	}
	else
	{
		NewUnitClassInsignia.UnitObjectID = UnitObjectID;
		NewUnitClassInsignia.ClassTitle = ClassTitle;
		UnitClassInsignias.AddItem(NewUnitClassInsignia);
	}
}

function SetClassDescriptionForUnit(string ClassDescription, int UnitObjectID)
{
	local int Index;
	local ClassInsignia NewUnitClassInsignia;
	
	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);
	if (Index != INDEX_NONE)
	{
		UnitClassInsignias[Index].ClassDescription = ClassDescription;
	}
	else
	{
		NewUnitClassInsignia.UnitObjectID = UnitObjectID;
		NewUnitClassInsignia.ClassDescription = ClassDescription;
		UnitClassInsignias.AddItem(NewUnitClassInsignia);
	}
}

function string GetClassIconForUnit(int UnitObjectID)
{
	local int Index;

	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);
	if (Index != INDEX_NONE)
	{
		return UnitClassInsignias[Index].ClassImagePath;
	}
	return "";
}

function string GetClassTitleForUnit(int UnitObjectID)
{
	local int Index;

	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);
	if (Index != INDEX_NONE)
	{
		return UnitClassInsignias[Index].ClassTitle;
	}
	return "";
}


function string GetClassDescriptionForUnit(int UnitObjectID)
{
	local int Index;

	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);
	if (Index != INDEX_NONE)
	{
		return UnitClassInsignias[Index].ClassDescription;
	}
	return "";
}

function bool HasClassInsignia(int UnitObjectID)
{
	local int Index;

	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);

	return (Index != INDEX_NONE);
}

function ResetClassInsignia(int UnitObjectID)
{
	local int Index;

	Index = UnitClassInsignias.Find('UnitObjectID', UnitObjectID);

	if (Index != INDEX_NONE)
	{
		UnitClassInsignias.Remove(Index, 1);
	}
}