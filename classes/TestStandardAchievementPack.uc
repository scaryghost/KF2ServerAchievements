class TestStandardAchievementPack extends StandardAchievementPack;

enum TestSapIndex {
    EXPERIMENTIMILLICIDE,
    AMMO_COLLECTOR,
    WATCH_YOUR_STEP,
    FIRE_IN_THE_HOLE,
    BLOODY_RUSSIANS
};

private function checkBloodyRussians(Weapon currentWeapon) {
    if (!achievements[TestSapIndex.BLOODY_RUSSIANS].completed && currentWeapon.IsA('KFWeap_AssaultRifle_AK12') && !currentWeapon.HasAmmo(0)) {
        if (achievements[TestSapIndex.BLOODY_RUSSIANS].progress == achievements[TestSapIndex.BLOODY_RUSSIANS].maxProgress) {
            achievementCompleted(TestSapIndex.BLOODY_RUSSIANS);
        } else {
            achievements[TestSapIndex.BLOODY_RUSSIANS].progress= 0;
        }
    }
}

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
    achievements[TestSapIndex.BLOODY_RUSSIANS].progress= 0;
}

event firedWeapon(Weapon currentWeapon) {
    `Log("Fired my weapon! " $ currentWeapon.class, true, 'ServerAchievements');
}

event stoppedFiringWeapon(Weapon currentWeapon) {
    checkBloodyRussians(currentWeapon);
}

event died(Controller killer, class<DamageType> damageType) {
    if (damageType == class'KFDT_Falling') {
        addProgress(WATCH_YOUR_STEP, 1);
    }
}

event killedMonster(Pawn target, class<DamageType> damageType) {
    addProgress(TestSapIndex.EXPERIMENTIMILLICIDE, 1);

    if (ClassIsChildOf(damageType, class'KFDT_Ballistic_AK12')) {
        achievements[TestSapIndex.BLOODY_RUSSIANS].progress++;
    }
}

event pickedUpItem(Actor item) {
    if (item.IsA('KFPickupFactory_Ammo')) {
        addProgress(TestSapIndex.AMMO_COLLECTOR, 1);
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType) {
    `Log("Damaged a monster! " $ damageType, true, 'ServerAchievements');
}

event swungWeapon(Weapon currentWeapon) {
    `Log("Swinging weapon: " $ currentWeapon);
}

defaultproperties
{
    achievements[0]=(maxProgress=1000,notifyProgress=0.25)
    achievements[1]=(maxProgress=15,hideProgress=true,discardProgress=true)
    achievements[2]=(maxProgress=10)
    achievements[3]=(maxProgress=5,hideProgress=true,discardProgress=true)
    achievements[4]=(maxProgress=1,hideProgress=true,discardProgress=true)
}
