class AchievementMenuScene extends MobileMenuScene;

function InitMenuScene(MobilePlayerInput PlayerInput, int ScreenWidth, int ScreenHeight,
        bool bIsFirstInitialization) {
    super.InitMenuScene(PlayerInput, ScreenWidth, ScreenHeight, bIsFirstInitialization);

    `Log("Width= " $ MenuObjects[0].Width $ ", Height= " $ MenuObjects[0].Height $ "Left/Top=" $ Left $ ", " $ Top);
}

defaultproperties
{
    bRelativeLeft=true;
    bRelativeTop=true;
    bRelativeWidth=true;
    bRelativeHeight=true;
    Width=0.779688
    Height=0.847083
    Left=0.110313
    Top=0.057916

    Begin Object class=MobileMenuImage Name=Background
        bRelativeLeft=true;
        bRelativeTop=true;
        bRelativeWidth=true;
        bRelativeHeight=true;
        Width=1.0
        Height=1.0
        Left=0.0
        Top=0.0

        Image=Texture2D'Wep_1P_Shared_TEX.T_RefCube_PosZ'
        ImageDrawStyle=IDS_Stretched
    End Object
    MenuObjects.Add(Background)
}
