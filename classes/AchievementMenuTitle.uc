class AchievementMenuTitle extends MobileMenuLabel;

function RenderObject(canvas Canvas, float DeltaTime) {
    local float UL,VL;

    if (Caption != "") {
        Canvas.Font = TextFont;
        Canvas.TextSize(Caption, UL, VL);

        SetCanvasPos(Canvas, (Width / 2) - UL, (Height / 2) - (VL / 2));

        Canvas.DrawColor = bIsTouched ? TouchedColor : TextColor;
    	Canvas.DrawColor.A *= Opacity * OwnerScene.Opacity;
        Canvas.DrawText(Caption);
    }
}
