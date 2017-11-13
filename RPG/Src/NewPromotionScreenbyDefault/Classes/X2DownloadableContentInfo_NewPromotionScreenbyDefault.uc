class X2DownloadableContentInfo_NewPromotionScreenbyDefault extends X2DownloadableContentInfo;

exec function PSSetPos(int X, int Y, int Anchor = -1)
{
	local NPSBDP_UIArmory_PromotionHero UI;
	UI = NPSBDP_UIArmory_PromotionHero(`SCREENSTACK.GetFirstInstanceOf(class'NPSBDP_UIArmory_PromotionHero'));

	UI.Scrollbar.SetX(X);
	UI.Scrollbar.SetY(Y);

	if (Anchor > -1)
	{
		UI.Scrollbar.SetAnchor(Anchor);
	}
}

exec function PSSetSize(int Width = 0, int Height = 0)
{
	local NPSBDP_UIArmory_PromotionHero UI;
	UI = NPSBDP_UIArmory_PromotionHero(`SCREENSTACK.GetFirstInstanceOf(class'NPSBDP_UIArmory_PromotionHero'));

	if (Width > 0)
	{
		UI.Scrollbar.SetWidth(Width);
	}

	if (Height > 0)
	{
		UI.Scrollbar.SetHeight(Height);
	}
}