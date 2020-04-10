//-----------------------------------------------------------
//	Class:	XComGameState_Effect_CapStats
//	Author: Musashi
//	
//-----------------------------------------------------------
class XComGameState_Effect_CapStats extends XComGameState_Effect dependson(RPGO_DataStructures);

var array<StatCap>  m_aStatCaps;
var array<EquipmentStatCap> EquipmentStatCaps;

function AddStatCap(ECharStatType StatType, float StatCapValue)
{
	local StatCap Cap;
	
	Cap.StatType = StatType;
	Cap.StatCapValue = StatCapValue;
	m_aStatCaps.AddItem(Cap);
}

public function AddCap(StatCap Cap, optional bool bUseMaxCap = false)
{
	local int Index;

	Index = m_aStatCaps.Find('StatType', Cap.StatType);

	if (Index != INDEX_NONE && bUseMaxCap)
	{
		m_aStatCaps[Index].StatCapValue = Max(m_aStatCaps[Index].StatCapValue, Cap.StatCapValue);
		//`LOG(default.class @ GetFuncName() @ Cap.StatType @ Cap.StatCapValue @ m_aStatCaps[Index].StatCapValue);
	}
	else
	{
		m_aStatCaps.AddItem(Cap);
	}
}