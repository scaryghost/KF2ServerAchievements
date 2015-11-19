class AchievementMenuScene extends MobileMenuScene;

var private MobileMenuList achievementList;
var private MobileMenuLabel achievementPackLabel;
var array<AchievementPack> achievementPacks;
var int currAchvIndex;

event InitMenuScene(MobilePlayerInput PlayerInput, int ScreenWidth, int ScreenHeight, bool bIsFirstInitialization) {
    MenuObjects.AddItem(achievementPackLabel);
    MenuObjects.AddItem(achievementList);

    super.InitMenuScene(PlayerInput, ScreenWidth, ScreenHeight, bIsFirstInitialization);
}

function refreshAchievementLabel() {
    local int i;
    local AchievementListItem item;

    achievementPackLabel.Caption= achievementPacks[currAchvIndex].attrName();
    achievementList.Items.Length= 0;

    for(i= 0; i < achievementPacks[currAchvIndex].numAchievements(); i++) {
        item= new class'AchievementListItem';
        achievementPacks[currAchvIndex].lookupAchievement(i, item.achv);
        achievementList.AddItem(item);
    }
}

function prevAchievement() {
    currAchvIndex--;
    if (currAchvIndex < 0) {
        currAchvIndex= achievementPacks.Length - 1;
    }

    refreshAchievementLabel();
}

function nextAchievement() {
    currAchvIndex++;
    if (currAchvIndex >= achievementPacks.Length) {
        currAchvIndex= 0;
    }

    refreshAchievementLabel();
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

    Begin Object class=MobileMenuList Name=AchievementListSubObj
        bRelativeLeft=true;
        bRelativeTop=true;
        bRelativeWidth=true;
        bRelativeHeight=true;
        Width=0.85
        Height=0.725
        Left=0.075
        Top=0.175
    End Object
    achievementList=AchievementListSubObj

    Begin Object class=MobileMenuImage Name=ListBackground
        bRelativeLeft=true;
        bRelativeTop=true;
        bRelativeWidth=true;
        bRelativeHeight=true;
        Width=0.90
        Height=0.775
        Left=0.05
        Top=0.15
        Image=Texture2D'EngineResources.Black'
        ImageColor=(r=1.0,g=1.0,b=1.0,a=0.35)
        ImageDrawStyle=IDS_Stretched
    End Object
    MenuObjects.Add(ListBackground)

    Begin Object class=AchievementNextButton Name=NextAchvBtn
        bRelativeLeft=true;
        bRelativeTop=true;
        bRelativeWidth=true;
        bRelativeHeight=true;
        Width=0.15
        Height=0.05
        Left=0.05
        Top=0.037916
        Images[0]=Texture2D'EditorResources.RedSquareTexture'
        Images[1]=Texture2D'Bkgnd'
        Caption="Next"
        bIsActive=true
    End Object
    MenuObjects.Add(NextAchvBtn)

    Begin Object class=AchievementPrevButton Name=PrevAchvBtn
        bRelativeLeft=true;
        bRelativeTop=true;
        bRelativeWidth=true;
        bRelativeHeight=true;
        Width=0.15
        Height=0.05
        Left=0.80
        Top=0.037916
        Images[0]=Texture2D'EditorResources.RedSquareTexture'
        Images[1]=Texture2D'Bkgnd'
        Caption="Previous"
        bIsActive=true
    End Object
    MenuObjects.Add(PrevAchvBtn)

    Begin Object class=MobileMenuLabel Name=AchvPackLabelSubObj
        bRelativeLeft=true;
        bRelativeTop=true;
        bRelativeWidth=true;
        bRelativeHeight=true;
        Width=0.5
        Height=0.1
        Left=0.3
        Top=0.037916
        TextFont=Font'Font_General'
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    achievementPackLabel=AchvPackLabelSubObj
}
