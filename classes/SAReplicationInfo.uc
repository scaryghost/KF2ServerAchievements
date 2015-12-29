class SAReplicationInfo extends ReplicationInfo;

var array<class<AchievementPack> > achievementPackClasses;
var DataSource dataSrc;
var PlayerReplicationInfo ownerPri;

var private bool initialized, signalFire, signalReload, signalFragToss, handledGameEnded;
var private array<AchievementPack> achievementPacks;

replication {
    if (Role == ROLE_Authority)
        ownerPri;
}

simulated event Tick(float DeltaTime) {
    local MatchInfo info;
    local KFPawn ownerPawn;
    local bool weaponIsFiring, weaponIsReloading, tossingFrag;
    local class<AchievementPack> it;
    local AchievementPack pack;
    local PlayerController localController;
    local SAInteraction newInteraction;

    if (!initialized) {
        if (Role == ROLE_Authority) {
            foreach achievementPackClasses(it) {
                addAchievementPack(Spawn(it, Owner));
            }

            dataSrc.retrieveAchievementState(ownerPri.UniqueId, achievementPacks);
        }

        localController= GetALocalPlayerController();
        if (localController != none) {
            foreach DynamicActors(class'AchievementPack', pack) {
                if (pack.Owner == Owner) {
                    addAchievementPack(pack);
                }
            }

            newInteraction= new class'SAInteraction';
            newInteraction.owner= localController;
            localController.Interactions.InsertItem(0, newInteraction);
        }

        initialized= true;
    }

    if (Role == ROLE_Authority) {
        ownerPawn= KFPawn(Controller(Owner).Pawn);

        if (ownerPawn != None && ownerPawn.Weapon != none) {
//            `Log("Weapon State: " $ ownerPawn.Weapon.GetStateName(), true, 'ServerAchievements');
            weaponIsFiring= ownerPawn.Weapon.GetStateName() == 'WeaponSingleFiring' || 
                    ownerPawn.Weapon.GetStateName() == 'WeaponBurstFiring' || ownerPawn.Weapon.GetStateName() == 'SprayingFire';
            if (!signalFire && weaponIsFiring) {
                foreach achievementPacks(pack) {
                    pack.firedWeapon(ownerPawn.Weapon);
                }
                signalFire= true;
            } else if (signalFire && !weaponIsFiring) {
                signalFire= false;
            }

            weaponIsReloading= ownerPawn.Weapon.IsInState('Reloading');
            if (!signalReload && weaponIsReloading) {
                foreach achievementPacks(pack) {
                    pack.firedWeapon(ownerPawn.Weapon);
                }
                signalReload= true;
            } else if (signalReload && !weaponIsReloading) {
                signalReload= false;
            }

            tossingFrag= ownerPawn.Weapon.IsInState('GrenadeFiring');
            if (!signalFragToss && tossingFrag) {
                foreach achievementPacks(pack) {
                    pack.tossedGrenade(ownerPawn.GetPerk().GetGrenadeClass());
                }
                signalFragToss= true;
            } else if (signalFragToss && !tossingFrag) {
                signalFragToss= false;
            }
        }

        if (!handledGameEnded && WorldInfo.Game.GameReplicationInfo.bMatchIsOver) {
            handledGameEnded= true;
            info.mapName= WorldInfo.GetMapName(true);
            info.difficulty= KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo).GameDifficulty;
            info.length= KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo).GameLength;

            if (WorldInfo.Game.IsA('KFGameInfo')) {
                info.result= KFGameInfo(WorldInfo.Game).GetLivingPlayerCount() <= 0 ? SA_MR_LOST : SA_MR_WON;
            } else {
                info.result= SA_MR_UNKNOWN;
            }

            foreach achievementPacks(pack) {
                pack.matchEnded(info);
            }
        }
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
