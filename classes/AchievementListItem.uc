class AchievementListItem extends MobileMenuListItem;

var int id;
var Texture2D background;

function RenderItem(MobileMenuList List, Canvas Canvas, float DeltaTime) {
    Canvas.Font= Font'UI_Canvas_Fonts.Font_General_Small';
    //Canvas.DrawTile(background, background.SizeX, background.SizeY, 0, 0, background.SizeX, background.SizeY);
    Canvas.DrawText("Achievement item " $ id);
}

defaultproperties
{
    background=Texture2D'EngineResources.Black'
    Height=100
}
