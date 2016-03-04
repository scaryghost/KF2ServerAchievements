class SAMutator extends KFGame.KFMutator
    dependson(SAReplicationInfo)
    config(ServerAchievements);

var() config array<string> achievementPackClassnames;
var() config string dataLinkClassname;

var private array<class<AchievementPack> > loadedAchievementPacks;
var private DataLink dataLnk;

function PostBeginPlay() {
    local class<AchievementPack> loadedPack;    
    local array<string> uniqueClassnames;
    local string it;    
    local class<DataLink> dataLinkClass;

    `Log("Attempting to load" @ achievementPackClassnames.Length @ "achievement packs", true, 'ServerAchievements');    
    if (achievementPackClassnames.Length == 0) {
        achievementPackClassnames.AddItem(PathName(class'TestStandardAchievementPack'));
    }
    foreach achievementPackClassnames(it) {
        class'Arrays'.static.uniqueInsert(uniqueClassnames, it);
    }
    foreach uniqueClassnames(it) {
        loadedPack= class<AchievementPack>(DynamicLoadObject(it, class'Class'));
        if (loadedPack == none) {
            `Warn("Failed to load achievement pack" @ it, true, 'ServerAchievements');
        } else {
            `Log("Successfully loaded" @ it, true, 'ServerAchievements');
            loadedAchievementPacks.AddItem(loadedPack);
        }
    }

    if (Len(dataLinkClassname) == 0) {
        `Warn("No data link specified, defaulting to ServerAchievements.FileDataLink", true, 'ServerAchievements');
        dataLnk= new class'FileDataLink';
        dataLinkClassname= PathName(dataLnk.class);
    } else {
        dataLinkClass= class<DataLink>(DynamicLoadObject(dataLinkClassname, class'Class'));
        if (dataLinkClass == None) {
            `Warn("Cannot load DataLink class:" @ dataLinkClassname, true, 'ServerAchievements');
            `Warn("Defaulting to ServerAchievements.FileDataLink", true, 'ServerAchievements');
            dataLnk= new class'FileDataLink'; 
        } else {
            dataLnk= new dataLinkClass;
        }
    }

    SaveConfig();
}

function bool CheckReplacement(Actor Other) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRepInfo;

    if (PlayerReplicationInfo(Other) != none && Other.Owner != None && Other.Owner.IsA('PlayerController') && 
            PlayerController(Other.Owner).bIsPlayer) {
        pri= PlayerReplicationInfo(Other);

        saRepInfo= Spawn(class'SAReplicationInfo', pri.Owner);
        saRepInfo.dataLnk= dataLnk;
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
        saRepInfo= class'SAReplicationInfo'.static.findSAri(instigatedBy);
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
        saRepInfo= class'SAReplicationInfo'.static.findSAri(Other.Controller);
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
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killed.Controller);
            if (saRepInfo != none) {
                saRepInfo.getAchievementPacks(achievementPacks);
                foreach achievementPacks(it) {
                    it.died(Killer, damageType);
                }
            }
        } else if (Killer.IsA('KFPlayerController')) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killer);
            
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

    saRepInfo= class'SAReplicationInfo'.static.findSAri(Exiting);
    saRepInfo.getAchievementPacks(packs);
    dataLnk.saveAchievementState(PlayerController(saRepInfo.Owner).PlayerReplicationInfo.UniqueId, packs);
}
