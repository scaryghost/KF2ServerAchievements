class SAMutator extends Engine.Mutator
    config(ServerAchievements);

var() config array<string> achievementPackClassnames;
var() config string dataSourceClassname;

var private array<class<AchievementPack> > loadedAchievementPacks;
var private DataConnection dataConn;

function PostBeginPlay() {
    local class<DataConnection> dataSourceClass;

    if (Len(dataSourceClassname) == 0) {
        `Warn("No data source specified, defaulting to ServerAchievements.FileDataConnection");
        dataConn= Spawn(class'FileDataConnection');
    } else {
        dataSourceClass= class<DataConnection>(DynamicLoadObject(dataSourceClassname, class'Class'));
        if (dataSourceClass == None) {
            `Warn("Cannot load DataSource class:" @ dataSourceClassname);
            `Warn("Defaulting to ServerAchievements.FileDataConnection");
            dataConn= Spawn(class'FileDataConnection'); 
        } else {
            dataConn= Spawn(dataSourceClass);
        }
    }
    dataConn.loadAchievementPacks(achievementPackClassnames);
}

function bool CheckReplacement(Actor Other) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRepInfo;

    if (PlayerReplicationInfo(Other) != none && Other.Owner.IsA('PlayerController') && 
            PlayerController(Other.Owner).bIsPlayer) {
        pri= PlayerReplicationInfo(Other);

        saRepInfo= Spawn(class'SAReplicationInfo', pri.Owner);
        saRepInfo.ownerPri= pri;
        saRepInfo.dataConn= dataConn;
    }
    return super.CheckReplacement(Other);
}

function NetDamage(int OriginalDamage, out int Damage, Pawn Injured, Controller InstigatedBy, 
        vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser) {
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> achievementPacks;
    local AchievementPack it;

    super.NetDamage(OriginalDamage, Damage, Injured, instigatedBy, HitLocation, Momentum, DamageType, 
            DamageCauser);
    if (Injured.IsA('KFPawn_Monster')) {
        saRepInfo= class'SAReplicationInfo'.static.findSAri(instigatedBy.PlayerReplicationInfo);
        if (saRepInfo != none) {
            saRepInfo.getAchievementPacks(achievementPacks);
            foreach achievementPacks(it) {
                it.damagedMonster(Damage, Injured, DamageType);
            }
        }
    }
}

function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup) {
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> achievementPacks;
    local AchievementPack it;
    local bool result;

    result= super.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup);
    if (!result || (result && bAllowPickup != 0)) {
        saRepInfo= class'SAReplicationInfo'.static.findSAri(Other.PlayerReplicationInfo);
        if (saRepInfo != none) {
            saRepInfo.getAchievementPacks(achievementPacks);
            foreach achievementPacks(it) {
                it.pickedUpItem(Pickup);
            }
        }
    }
    return result;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> achievementPacks;
    local AchievementPack it;

	if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if (Killer.IsA('KFPlayerController')) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killer.PlayerReplicationInfo);
            
            if (saRepInfo != none) {
                saRepInfo.getAchievementPacks(achievementPacks);
                foreach achievementPacks(it) {
                    it.killedMonster(Killed, DamageType);
                }
            }
        }
        return false;
    }
    return true;
}

function NotifyLogout(Controller Exiting) {
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> packs;

    super.NotifyLogout(Exiting);

    saRepInfo= class'SAReplicationInfo'.static.findSAri(Exiting.PlayerReplicationInfo);
    saRepInfo.getAchievementPacks(packs);
    dataConn.saveAchievementState(saRepInfo.ownerPri.UniqueId, packs);
}
