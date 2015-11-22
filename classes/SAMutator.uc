class SAMutator extends Engine.Mutator
    config(ServerAchievements);

var() config array<string> achievementPackClassNames;
var private array<class<AchievementPack> > loadedAchievementPacks;
var private array<AchievementPack> pendingPacks;

simulated function Tick(float DeltaTime) {
    local PlayerController localController;
    local SAInteraction newInteraction;

    localController= GetALocalPlayerController();
    if (localController != none) {
        newInteraction= new class'SAInteraction';
        newInteraction.owner= localController;
        localController.Interactions.InsertItem(0, newInteraction);
    }
    Disable('Tick');
}

function PostBeginPlay() {
    local class<AchievementPack> loadedPack;
    local array<string> uniquePackClassNames;
    local string it;

    `Log("Attempting to load" @ achievementPackClassNames.Length @ "achievement packs");
    foreach achievementPackClassNames(it) {
        class'Arrays'.static.uniqueInsert(uniquePackClassNames, it);
    }
    foreach uniquePackClassNames(it) {
        loadedPack= class<AchievementPack>(DynamicLoadObject(it, class'Class'));
        if (loadedPack == none) {
            `Warn("Failed to load achievement pack" @ it);
        } else {
            `Log("Successfully loaded" @ it);
            loadedAchievementPacks.AddItem(loadedPack);
        }
    }

}

function bool CheckReplacement(Actor Other) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRepInfo;

    if (PlayerReplicationInfo(Other) != none && Other.Owner != none) {
        pri= PlayerReplicationInfo(Other);
        saRepInfo= Spawn(class'SAReplicationInfo', pri.Owner);
        saRepInfo.ownerPri= pri;
        saRepInfo.mutRef= self;
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
    local array<string> queryParts;
    local string query;
    local AchievementPack it;
    local HttpRequestInterface httpRequest;
    local Guid packId;

    super.NotifyLogout(Exiting);

    saRepInfo= class'SAReplicationInfo'.static.findSAri(Exiting.PlayerReplicationInfo);
    saRepInfo.getAchievementPacks(packs);
    foreach packs(it) {
        packId= it.attrId();

        queryParts.Length= 0;
        queryParts.AddItem("steamid=" $ class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(saRepInfo.ownerPri.UniqueId));
        queryParts.AddItem("action=save");
        queryParts.AddItem("packid=" $ GetStringFromGuid(packId));
        queryParts.AddItem("state=" $ it.serializeAchievements());

        JoinArray(queryParts, query, "&");

        httpRequest= class'HttpFactory'.static.CreateRequest();
        httpRequest.SetVerb("POST")
                .SetHeader("Content-Type", "text/plain")
                .SetContentAsString(query $ "\n")
                .SetURL("http://192.168.0.121:8000/serverachievements/1.0.0")
                .ProcessRequest();
    }
}

function sendAchievements(SAReplicationInfo saRepInfo) {
    local class<AchievementPack> it;
    local AchievementPack pack;
    local array<string> queryParts;
    local string query;
    local HttpRequestInterface httpRequest;
    local Guid packId;

    if (Controller(saRepInfo.Owner) != none && Controller(saRepInfo.Owner).bIsPlayer) {
        foreach loadedAchievementPacks(it) {
            pack= Spawn(it, saRepInfo.Owner);
            pendingPacks.AddItem(pack);

            packId= pack.attrId();

            queryParts.Length= 0;
            queryParts.AddItem("steamid=" $ class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(saRepInfo.ownerPri.UniqueId));
            queryParts.AddItem("action=get");
            queryParts.AddItem("packid=" $ GetStringFromGuid(packId));

            JoinArray(queryParts, query, "&");
            
            httpRequest= class'HttpFactory'.static.CreateRequest();
            httpRequest.SetVerb("POST")
                .SetHeader("Content-Type", "text/plain")
                .SetContentAsString(query $ "\n")
                .SetURL("http://192.168.0.121:8000/serverachievements/1.0.0")
                .SetProcessRequestCompleteDelegate(getRequestComplete)
                .ProcessRequest();
            saRepInfo.addAchievementPack(pack);
        }
    }
}

function getRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) {
    if (bDidSucceed) {
        pendingPacks[0].deserializeAchievements(InHttpResponse.GetContentAsString());
        pendingPAcks.Remove(0, 1);
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
}
