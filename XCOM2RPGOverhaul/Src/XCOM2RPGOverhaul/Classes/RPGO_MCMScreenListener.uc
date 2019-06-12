//-----------------------------------------------------------
//	Class:	RPGO_MCMScreenListener
//	Author: Musashi
//	
//-----------------------------------------------------------

class RPGO_MCMScreenListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local RPGO_MCMScreen MCMScreen;

	if (ScreenClass==none)
	{
		if (MCM_API(Screen) != none)
			ScreenClass=Screen.Class;
		else return;
	}

	MCMScreen = new class'RPGO_MCMScreen';
	MCMScreen.OnInit(Screen);
}

defaultproperties
{
    ScreenClass = none;
}
