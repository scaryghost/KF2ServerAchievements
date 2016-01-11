class TestStandardAchievementPack extends StandardAchievementPack;

enum TestSapIndex {
    EXPERIMENTIMILLICIDE,
    AMMO_COLLECTOR,
    WATCH_YOUR_STEP,
    FIRE_IN_THE_HOLE
};

event matchEnded(const out MatchInfo info) {
    `Log("Match is over! name=" $ info.mapName $ ", difficult= " $ info.difficulty $ ", length= " $ info.length $ ", result= " $ info.result);
}

event waveStarted(byte newWave, byte waveMax) {
    if (!achievements[FIRE_IN_THE_HOLE].completed) {
        resetProgress(FIRE_IN_THE_HOLE);
    }
}

event tossedGrenade(class<KFProj_Grenade> grenadeClass) {
    addProgress(FIRE_IN_THE_HOLE, 1);
}

event reloadedWeapon(Weapon currentWeapon) {
    `Log("Reloaded my weapon! " $ currentWeapon.class, true, 'ServerAchievements');
}

event firedWeapon(Weapon currentWeapon) {
    `Log("Fired my weapon! " $ currentWeapon.class, true, 'ServerAchievements');
}

event died(Controller killer, class<DamageType> damageType) {
    if (damageType == class'KFDT_Falling') {
        addProgress(WATCH_YOUR_STEP, 1);
    }
}

event killedMonster(Pawn target, class<DamageType> damageType) {
    `Log("Kill damage type: " $ damageType, true, 'ServerAchievements');
    addProgress(TestSapIndex.EXPERIMENTIMILLICIDE, 1);
}

event pickedUpItem(Actor item) {
    if (item.IsA('KFPickupFactory_Ammo')) {
        addProgress(TestSapIndex.AMMO_COLLECTOR, 1);
    }
}

defaultproperties
{
    achievements[0]=(maxProgress=1000,notifyProgress=0.25)
    achievements[1]=(maxProgress=15,hideProgress=true,discardProgress=true)
    achievements[2]=(maxProgress=10)
    achievements[3]=(maxProgress=5,hideProgress=true,discardProgress=true)
}
