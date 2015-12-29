class TestStandardAchievementPack extends StandardAchievementPack;

enum TestSapIndex {
    EXPERIMENTIMILLICIDE,
    AMMO_COLLECTOR,
    WATCH_YOUR_STEP
};

event matchEnded(const out MatchInfo info) {
    `Log("Match is over! name=" $ info.mapName $ ", difficult= " $ info.difficulty $ ", length= " $ info.length $ ", result= " $ info.result);
}

event waveStarted(byte newWave, byte waveMax) {
    `Log("Wave started! newWave= " $ newWave $ ", waveMax= " $ waveMax);
}

event tossedGrenade(class<KFProj_Grenade> grenadeClass) {
    `Log("Tossing a frag! " $ grenadeClass, true, 'ServerAchievements');
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
    addProgress(TestSapIndex.EXPERIMENTIMILLICIDE, 1);
}

event pickedUpItem(Actor item) {
    if (item.IsA('KFPickupFactory_Ammo')) {
        addProgress(TestSapIndex.AMMO_COLLECTOR, 1);
    }
}

defaultproperties
{
    achievements[0]=(maxProgress=1000,notifyProgress=0.25,persistProgress=true)
    achievements[1]=(maxProgress=20,notifyProgress=0.5)
    achievements[2]=(maxProgress=10,persistProgress=true)
}
