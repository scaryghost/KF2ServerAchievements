class TestStandardAchievementPack extends StandardAchievementPack;

enum TestSapIndex {
    EXPERIMENTIMILLICIDE,
    AMMO_COLLECTOR
};

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
}
