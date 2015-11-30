class SAReplicationInfo extends ReplicationInfo;

var private bool initialized;
var DataConnection dataConn;
var PlayerReplicationInfo ownerPri;
var private array<AchievementPack> achievementPacks;

replication {
    if (Role == ROLE_Authority)
        ownerPRI;
}

simulated event Tick(float DeltaTime) {
    local AchievementPack pack;
    local PlayerController localController;
    local SAInteraction newInteraction;

    if (!initialized) {
        if (Role == ROLE_Authority) {
            dataConn.spawnAchievementPacks(self);
        }

        foreach DynamicActors(class'AchievementPack', pack) {
            if (pack.Owner == Owner) {
                addAchievementPack(pack);
            }
        }

        localController= GetALocalPlayerController();
        if (localController != none) {
            newInteraction= new class'SAInteraction';
            newInteraction.owner= localController;
            localController.Interactions.InsertItem(0, newInteraction);
        }

        initialized= true;
    }
}

simulated function addAchievementPack(AchievementPack pack) {
    local int i;
    
    for(i= 0; i < achievementPacks.Length; i++) {
        if (achievementPacks[i] == pack)
            return;
    }
    achievementPacks[achievementPacks.Length]= pack;
}

simulated function getAchievementPacks(out array<AchievementPack> packs) {
    local int i;
    for(i= 0; i < achievementPacks.Length; i++) {
        packs[i]= achievementPacks[i];
    }
}

static function SAReplicationInfo findSAri(PlayerReplicationInfo pri) {
    local SAReplicationInfo repInfo;

    if (pri == none)
        return none;

    foreach pri.DynamicActors(class'SAReplicationInfo', repInfo)
        if (repInfo.ownerPri == pri) {
            return repInfo;
        }
 
    return none;
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
}
