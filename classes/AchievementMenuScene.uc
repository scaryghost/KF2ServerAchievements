class AchievementMenuScene extends MobileMenuScene;

defaultproperties
{
    Width=440
    Height=640
    Left=0.4
    Top=0.4
Begin Object Class=MobileMenuButton Name=Test
   Tag="Test"
   Top=400
   Left=400
   Width=140
   Height=24
   Images(0) = Texture2D'UI_Shared.AssetLib_IDA'
   Images(1)=Texture2D'UI_Shared.AssetLib_IDA'
   ImagesUVs(0)=(bCustomCoords=true,U=366,V=140,UL=260,VL=48)
   ImagesUVs(1)=(bCustomCoords=true,U=366,V=195,UL=260,VL=48)
   Caption = "Items"
   CaptionColor = (R=1.0,G=1.0,B=1.0,A=1.0)
  End Object
  MenuObjects(0)=Test

  Begin Object Class=MobileMenuButton Name=Test2
   Tag="Test2"
   Top=400
   Left=430
   Width=140
   Height=24

   Images(0) = Texture2D'UI_Shared.AssetLib_IDA'
   Images(1)= Texture2D'UI_Shared.AssetLib_IDA'
   ImagesUVs(0)=(bCustomCoords=true,U=366,V=140,UL=260,VL=48)
   ImagesUVs(1)=(bCustomCoords=true,U=366,V=195,UL=260,VL=48)
   Caption = "Equipment"
   CaptionColor = (R=1.0,G=1.0,B=1.0,A=1.0)
  End Object
  MenuObjects(1)=Test2
  
  Begin Object Class=MobileMenuButton Name=Test3
   Tag="Test3"
   Top=400
   Left=460
   Width=140
   Height=24

   Images(0) = Texture2D'UI_Shared.AssetLib_IDA'
   Images(1)= Texture2D'UI_Shared.AssetLib_IDA'
   ImagesUVs(0)=(bCustomCoords=true,U=366,V=140,UL=260,VL=48)
   ImagesUVs(1)=(bCustomCoords=true,U=366,V=195,UL=260,VL=48)
   Caption = "Status"
   CaptionColor = (R=1.0,G=1.0,B=1.0,A=1.0)
  End Object
  MenuObjects(2)=Test3
}
