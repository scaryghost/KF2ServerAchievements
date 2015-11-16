class AchievementListItem extends MobileMenuListItem
    dependson(AchievementPack);

var Texture2D background, locked;
var LinearColor backgroundColor, lockedColor;
var Achievement achv;

function RenderItem(MobileMenuList List, Canvas Canvas, float DeltaTime) {
    local float TempX, TempY, TempWidth, TempHeight;
    local float IconSize;
    local string ProgressString;

    `Log("{vpos x: " $ VpPos.X $ ", vpos y: " $ VpPos.Y $ ", list left: " $ List.Left $ ", list top: " $ List.Top $ "}");
//    Canvas.SetOrigin(List.Left, List.Top);
    Canvas.SetPos(List.OwnerScene.Left + List.Left, VpPos.Y);
    Canvas.DrawTileStretched(background, List.Width, Height, 0, 0, background.SizeX, background.SizeY, 
            backgroundColor);
    if (achv.completed == 0) {
        Canvas.DrawTile(locked, 64, 64, 0, 0, locked.SizeX, locked.SizeY, lockedColor);
    } else {
        Canvas.DrawTile(achv.image, 64, 64, 0, 0, achv.image.SizeX, achv.image.SizeY);
    }
    Canvas.Font= class'Engine'.static.GetSmallFont();
    Canvas.DrawText(achv.title);

    TempX= Canvas.CurX;
    TempY= Canvas.CurY;
    Canvas.StrLen(achv.title, TempWidth, TempHeight);

    TempY+= TempHeight;
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawText(achv.description);
}

defaultproperties
{
    backgroundColor=(r=1.0,g=1.0,b=1.0,a=0.75)
    background=Texture2D'Bkgnd'
    lockedColor=(r=1.0,g=0.0,b=0.0,a=0.1)
    locked=Texture2D'EngineResources.Bad'
    Height=70
}
