class AchievementNextButton extends MobileMenuButton
    within AchievementMenuScene;

event bool OnTouch(ETouchType EventType, float TouchX, float TouchY, MobileMenuObject ObjectOver, 
        float DeltaTime) {
    if (EventType == Touch_Began) {
        Outer.nextAchievement();
    }
	return true;
}
