class AchievementListItem extends MobileMenuListItem;

var int id;
var Texture2D background;

function RenderItem(MobileMenuList List, Canvas Canvas, float DeltaTime) {
    `Log("{vpos x: " $ VpPos.X $ ", vpos y: " $ VpPos.Y $ ", list left: " $ List.Left $ ", list top: " $ List.Top $ "}");
//    Canvas.SetOrigin(List.Left, List.Top);
    Canvas.SetPos(List.OwnerScene.Left + List.Left, VpPos.Y);
    Canvas.Font= Font'UI_Canvas_Fonts.Font_General_Small';
    //Canvas.DrawTile(background, background.SizeX, background.SizeY, 0, 0, background.SizeX, background.SizeY);
    Canvas.DrawText("Achievement item " $ id);
}

defaultproperties
{
    background=Texture2D'EngineResources.Black'
    Width=250
    Height=10
}
