class TestStandardAchievementPack extends StandardAchievementPack
    dependson(GlobalEventDispatcher);

enum TestSapIndex {
    EXPERIMENTIMILLICIDE,
    AMMO_COLLECTOR,
    WATCH_YOUR_STEP,
    FIRE_IN_THE_HOLE,
    BLOODY_RUSSIANS,
    NOT_THE_FACE,
    SAVOR_EMOTIONS,
    MERDE
};

private function checkBloodyRussians(Weapon currentWeapon) {
    if (!achievements[BLOODY_RUSSIANS].completed && currentWeapon.IsA('KFWeap_AssaultRifle_AK12') && !currentWeapon.HasAmmo(0)) {
        if (achievements[BLOODY_RUSSIANS].progress == achievements[BLOODY_RUSSIANS].maxProgress) {
            achievementCompleted(BLOODY_RUSSIANS);
        } else {
            achievements[BLOODY_RUSSIANS].progress= 0;
        }
    }
}

function registerHandlers(GlobalEventDispatcher globalDispatcher, PlayerEventDispatcher playerDispatcher) {
    globalDispatcher.started.AddItem(waveStarted);
    globalDispatcher.ended.AddItem(matchEnded);

    playerDispatcher.tossed.AddItem(tossedGrenade);
    playerDispatcher.reloaded.AddItem(reloadedWeapon);
    playerDispatcher.stoppedFiring.AddItem(stoppedFiringWeapon);
    playerDispatcher.pickedUpItem.AddItem(pickedUpItem);
    playerDispatcher.monsterDamaged.AddItem(damagedMonster);
}

private function matchEnded(const out MatchInfo info) {
    if (info.result == SA_MR_LOST && Locs(info.mapName) == "kf-burningparis") {
        achievementCompleted(MERDE);
    }
}

private function waveStarted(byte newWave, byte waveMax) {
    if (!achievements[FIRE_IN_THE_HOLE].completed) {
        resetProgress(FIRE_IN_THE_HOLE);
    }
}

private function tossedGrenade(class<KFProj_Grenade> grenadeClass) {
    addProgress(FIRE_IN_THE_HOLE, 1);
}

private function reloadedWeapon(Weapon currentWeapon) {
    achievements[BLOODY_RUSSIANS].progress= 0;
}

private function stoppedFiringWeapon(Weapon currentWeapon) {
    checkBloodyRussians(currentWeapon);
}

private function died(Controller killer, class<DamageType> damageType) {
    if (damageType == class'KFDT_Falling') {
        addProgress(WATCH_YOUR_STEP, 1);
    }
}

private function killedMonster(Pawn target, class<DamageType> damageType) {
    addProgress(EXPERIMENTIMILLICIDE, 1);

    if (ClassIsChildOf(damageType, class'KFDT_Ballistic_AK12')) {
        achievements[BLOODY_RUSSIANS].progress++;
    } else if (ClassIsChildOf(damageType, class'KFDT_Slashing_Knife') || ClassIsChildOf(damageType, class'KFDT_Piercing_KnifeStab')) {
        addProgress(SAVOR_EMOTIONS, 1);
    }
}

private function pickedUpItem(Actor item) {
    if (item.IsA('KFPickupFactory_Ammo')) {
        addProgress(AMMO_COLLECTOR, 1);
    }
}

private function damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (headshot && ClassIsChildOf(damageType, class'KFDT_Bludgeon')) {
        addProgress(NOT_THE_FACE, 1);
    }
}

defaultproperties
{
    achievements[0]=(maxProgress=1000,nNotifies=4)
    achievements[1]=(maxProgress=15,hideProgress=true,discardProgress=true)
    achievements[2]=(maxProgress=10)
    achievements[3]=(maxProgress=5,hideProgress=true,discardProgress=true)
    achievements[4]=(maxProgress=1,hideProgress=true,discardProgress=true)
    achievements[5]=(maxProgress=50,nNotifies=2)
    achievements[6]=(maxProgress=100,nNotifies=4)
    achievements[7]=(hideProgress=true,discardProgress=true)
}
