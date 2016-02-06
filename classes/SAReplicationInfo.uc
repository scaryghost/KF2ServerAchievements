class SAReplicationInfo extends ReplicationInfo;

struct HealthWatcher {
    var int health;
    var int headHealth;
    var class<DamageType> damageTypeClass;
    var KFPawn_Monster monster;
};

var array<HealthWatcher> damagedZeds;
var array<class<AchievementPack> > achievementPackClasses;
var DataSource dataSrc;
var PlayerReplicationInfo ownerPri;

var private bool initialized, signalFire, signalReload, signalFragToss, signalSwing, handledGameEnded;
var private array<AchievementPack> achievementPacks;

replication {
    if (Role == ROLE_Authority)
        ownerPri;
}

event PostBeginPlay() {
    SetTimer(0.5, true, 'checkMonsterHealth');
}

simulated event Tick(float DeltaTime) {
    local MatchInfo info;
    local KFPawn ownerPawn;
    local bool weaponIsFiring, weaponIsReloading, weaponIsSwinging, tossingFrag;
    local class<AchievementPack> it;
    local AchievementPack pack;
    local PlayerController localController;
    local SAInteraction newInteraction;
    local Name weaponState;

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
            weaponState= ownerPawn.Weapon.GetStateName();
//            `Log("Weapon State: " $ weaponState, true, 'ServerAchievements');

            weaponIsFiring= weaponState == 'WeaponSingleFiring' || weaponState == 'WeaponFiring' ||
                    weaponState == 'WeaponBurstFiring' || weaponState == 'SprayingFire';
            if (!signalFire && weaponIsFiring) {
                foreach achievementPacks(pack) {
                    pack.firedWeapon(ownerPawn.Weapon);
                }
                signalFire= true;
            } else if (signalFire && !weaponIsFiring) {
                foreach achievementPacks(pack) {
                    pack.stoppedFiringWeapon(ownerPawn.Weapon);
                }
                signalFire= false;
            }

            weaponIsSwinging= weaponState == 'MeleeAttackBasic' || weaponState == 'MeleeChainAttacking' ||
                    weaponState == 'MeleeHeavyAttacking';
            if (!signalSwing && weaponIsSwinging) {
                foreach achievementPacks(pack) {
                    pack.swungWeapon(ownerPawn.Weapon);
                }
                signalSwing= true;
            } else if (signalSwing && !weaponIsSwinging) {
                signalSwing= false;
            }

            weaponIsReloading= ownerPawn.Weapon.IsInState('Reloading');
            if (!signalReload && weaponIsReloading) {
                foreach achievementPacks(pack) {
                    pack.reloadedWeapon(ownerPawn.Weapon);
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

function checkMonsterHealth() {
    local int i, end, damage;
    local AchievementPack it;
    local bool headshot;

    end= damagedZeds.Length;
    while(i < end) {
        if (damagedZeds[i].Health != damagedZeds[i].monster.Health) {
            headshot= damagedZeds[i].monster.HitZones[HZI_HEAD].GoreHealth != damagedZeds[i].headHealth;
            damage= damagedZeds[i].Health - damagedZeds[i].monster.Health;
            foreach achievementPacks(it) {
                it.damagedMonster(damage, damagedZeds[i].monster, damagedZeds[i].damageTypeClass, headshot);
            }

            damagedZeds.Remove(i, 1);
            end--;
        } else {
            i++;
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
