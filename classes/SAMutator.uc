class SAMutator extends KFGame.KFMutator
    dependson(SAReplicationInfo)
    config(ServerAchievements);

var() config array<string> achievementPackClassnames;
var() config string dataSourceClassname;

var private array<class<AchievementPack> > loadedAchievementPacks;
var private DataSource dataSrc;

function PostBeginPlay() {
    local class<AchievementPack> loadedPack;    
    local array<string> uniqueClassnames;
    local string it;    
    local class<DataSource> dataSourceClass;

    `Log("Attempting to load" @ achievementPackClassnames.Length @ "achievement packs");    
    foreach achievementPackClassnames(it) {
        class'Arrays'.static.uniqueInsert(uniqueClassnames, it);
    }
    foreach uniqueClassnames(it) {
        loadedPack= class<AchievementPack>(DynamicLoadObject(it, class'Class'));
        if (loadedPack == none) {
            `Warn("Failed to load achievement pack" @ it);
        } else {
            `Log("Successfully loaded" @ it);
            loadedAchievementPacks.AddItem(loadedPack);
        }
    }    

    if (Len(dataSourceClassname) == 0) {
        `Warn("No data source specified, defaulting to ServerAchievements.FileDataSource");
        dataSrc= new class'FileDataSource';
    } else {
        dataSourceClass= class<DataSource>(DynamicLoadObject(dataSourceClassname, class'Class'));
        if (dataSourceClass == None) {
            `Warn("Cannot load DataSource class:" @ dataSourceClassname);
            `Warn("Defaulting to ServerAchievements.FileDataSource");
            dataSrc= new class'FileDataSource'; 
        } else {
            dataSrc= new dataSourceClass;
        }
    }
}

function bool CheckReplacement(Actor Other) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRepInfo;

    if (PlayerReplicationInfo(Other) != none && Other.Owner.IsA('PlayerController') && 
            PlayerController(Other.Owner).bIsPlayer) {
        pri= PlayerReplicationInfo(Other);

        saRepInfo= Spawn(class'SAReplicationInfo', pri.Owner);
        saRepInfo.ownerPri= pri;
        saRepInfo.dataSrc= dataSrc;
        saRepInfo.achievementPackClasses= loadedAchievementPacks;
    }
    return super.CheckReplacement(Other);
}

function NetDamage(int OriginalDamage, out int Damage, Pawn Injured, Controller InstigatedBy, 
        vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser) {
    local SAReplicationInfo saRepInfo;
    local HealthWatcher watcher;

    super.NetDamage(OriginalDamage, Damage, Injured, instigatedBy, HitLocation, Momentum, DamageType, 
            DamageCauser);
    if (Injured.IsA('KFPawn_Monster')) {
        saRepInfo= class'SAReplicationInfo'.static.findSAri(instigatedBy.PlayerReplicationInfo);
        if (saRepInfo != None) {
            watcher.health= Injured.Health;
            watcher.monster= KFPawn_Monster(Injured);
            watcher.headHealth= watcher.monster.HitZones[HZI_HEAD].GoreHealth;
            watcher.damageTypeClass= DamageType;
            saRepInfo.damagedZeds.AddItem(watcher);
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
        if (Killed.IsA('KFPawn_Human')) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killed.PlayerReplicationInfo);
            if (saRepInfo != none) {
                saRepInfo.getAchievementPacks(achievementPacks);
                foreach achievementPacks(it) {
                    it.died(Killer, damageType);
                }
            }
        } else if (Killer.IsA('KFPlayerController')) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killer.PlayerReplicationInfo);
            
            if (saRepInfo != none) {
                saRepInfo.getAchievementPacks(achievementPacks);
                if (Killed.IsA('KFPawn_Monster')) {
                    foreach achievementPacks(it) {
                        it.killedMonster(Killed, DamageType);
                    }
                }
            }
        }
        return false;
    }
    return true;
}

function ModifyNextTraderIndex(out byte NextTraderIndex) {
    local KFGameReplicationInfo gri;
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> packs;
    local AchievementPack it;

    super.ModifyNextTraderIndex(NextTraderIndex);

    gri= KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);

    if (gri != none) {
        foreach DynamicActors(class'SAReplicationInfo', saRepInfo) {
            saRepInfo.getAchievementPacks(packs);
            foreach packs(it) {
                it.waveStarted(gri.WaveNum, gri.WaveMax);
            }
        }
    }
}

function NotifyLogout(Controller Exiting) {
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> packs;

    super.NotifyLogout(Exiting);

    saRepInfo= class'SAReplicationInfo'.static.findSAri(Exiting.PlayerReplicationInfo);
    saRepInfo.getAchievementPacks(packs);
    dataSrc.saveAchievementState(saRepInfo.ownerPri.UniqueId, packs);
}
