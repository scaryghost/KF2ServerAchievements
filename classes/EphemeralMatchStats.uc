class EphemeralMatchStats extends KFGame.EphemeralMatchStats;

var private SAReplicationInfo repInfo;

function InternalRecordWeaponDamage(class<KFDamageType> KFDT, class<KFWeaponDefinition> WeaponDef, int Damage, KFPawn TargetPawn, int HitZoneIdx) {
    local int DamageCopy;

    if (TargetPawn.IsA('KFPawn_Monster')) {
        DamageCopy = Damage;
        DamageCopy = TargetPawn.Health > 0 ? Damage : TargetPawn.Health + Damage;

        if (DamageCopy < 0) {
            DamageCopy = 0;
        }

        if (repInfo == None) {
            repInfo = class'SAReplicationInfo'.static.findSAri(outer);
        }
        repInfo.playerDispatcher.notifyMonsterDamaged(DamageCopy, TargetPawn, KFDT, HitZoneIdx == HZI_HEAD);
    }
    super.InternalRecordWeaponDamage(KFDT, WeaponDef, Damage, TargetPawn, HitZoneIdx);
}

