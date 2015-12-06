class AchievementListItem extends MobileMenuListItem
    dependson(AchievementPack);

var float progressBarOffset, iconSizeX, iconSizeY;
var Texture2D background, locked, progressBar;
var LinearColor backgroundColor, lockedColor;
var Achievement achv;

function RenderItem(MobileMenuList List, Canvas Canvas, float DeltaTime) {
    local float TempX, TempY, TempWidth, TempHeight;
    local float progressBarPercentage;
    local string ProgressString;

    TempY= VpPos.Y;

    Canvas.SetOrigin(List.OwnerScene.Left + List.Left, List.Top);
    Canvas.SetPos(0, TempY);
    Canvas.DrawTileStretched(background, List.Width, Height, 0, 0, background.SizeX, background.SizeY, 
            backgroundColor);

    TempY+= (Height - iconSizeY) / 2;
    Canvas.SetPos(0, TempY);
    if (achv.completed) {
        Canvas.DrawTile(achv.image, iconSizeX, iconSizeY, 0, 0, achv.image.SizeX, achv.image.SizeY);
    } else {
        Canvas.DrawTile(locked, iconSizeX, iconSizeY, 0, 0, locked.SizeX, locked.SizeY, lockedColor);
    }

    Canvas.Font= class'Engine'.static.GetSmallFont();
    Canvas.StrLen(achv.title, TempWidth, TempHeight);
    TempY+= (Height - TempHeight * 2) / 2;
    Canvas.SetPos(iconSizeX + 5, TempY);
    Canvas.DrawText(achv.title);
    Canvas.DrawText(achv.description);

    if (achv.maxProgress != 0) {
        TempX= List.Width * (1 - 0.227 - progressBarOffset);
        Canvas.SetPos(TempX, TempY);
        if (achv.progress >= achv.maxProgress) {
            progressBarPercentage= 1.0;
        } else {
            progressBarPercentage= achv.progress / float(achv.maxProgress);
        }
        Canvas.DrawTileStretched(progressBar, 0.227 * List.Width * progressBarPercentage, Height * 0.25, 0, 0, 
                progressBar.SizeX, progressBar.SizeY);

        Canvas.SetPos(TempX + 10, TempY);
        ProgressString= achv.progress $ "/" $ achv.maxProgress;
        Canvas.DrawText(ProgressString);
    }
}

defaultproperties
{
    backgroundColor=(r=1.0,g=1.0,b=1.0,a=0.25)
    background=Texture2D'Bkgnd'
    progressBar=Texture2D'BkgndHi'
    lockedColor=(r=1.0,g=0.0,b=0.0,a=1.0)
    locked=Texture2D'EditorMaterials.TerrainLayerBrowser.TLB_Lock'

    Height=70
    progressBarOffset=0.025
    iconSizeX=64
    iconSizeY=64
}
