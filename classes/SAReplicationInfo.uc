class SAReplicationInfo extends ReplicationInfo;

struct HealthWatcher {
    var int health;
    var int headHealth;
    var class<DamageType> damageTypeClass;
    var KFPawn_Monster monster;
};

var array<class<AchievementPack> > achievementPackClasses;
var DataLink dataLnk;
var PlayerEventDispatcher playerDispatcher;
var GlobalEventDispatcher globalDispatcher;

var private bool initialized, signalFire, signalReload, signalFragToss, signalSwing;
var private array<AchievementPack> achievementPacks;

event Destroyed() {
    local AchievementPack it;

    foreach achievementPacks(it) {
        it.Destroy();
    }
    achievementPacks.Length= 0;

    super.Destroyed();
}

simulated event Tick(float DeltaTime) {
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
                pack = Spawn(it, Owner);
                pack.registerHandlers(globalDispatcher, playerDispatcher);
                addAchievementPack(pack);
            }

            dataLnk.retrieveAchievementState(PlayerController(Owner).PlayerReplicationInfo.UniqueId, achievementPacks);
        }
        
        localController= GetALocalPlayerController();
        if (localController != none) {
            SetOwner(localController);
            foreach DynamicActors(class'AchievementPack', pack) {
                addAchievementPack(pack);
            }

            newInteraction= new class'SAInteraction';
            newInteraction.owner= localController;
            localController.Interactions.InsertItem(0, newInteraction);
        }

        initialized= true;
    }

    if (Role == ROLE_Authority) {
        if (Owner == None) {
            Destroy();
            return;
        }

        ownerPawn= KFPawn(Controller(Owner).Pawn);

        if (ownerPawn != None && ownerPawn.Weapon != none) {
            weaponState= ownerPawn.Weapon.GetStateName();
//            `Log("Weapon State: " $ weaponState, true, 'ServerAchievements');

            weaponIsFiring= weaponState == 'WeaponSingleFiring' || weaponState == 'WeaponFiring' ||
                    weaponState == 'WeaponBurstFiring' || weaponState == 'SprayingFire';
            if (!signalFire && weaponIsFiring) {
                playerDispatcher.notifyWeaponEvent(playerDispatcher.WeaponEventType.FIRED, ownerPawn.Weapon);
                signalFire= true;
            } else if (signalFire && !weaponIsFiring) {
                playerDispatcher.notifyWeaponEvent(playerDispatcher.WeaponEventType.STOPPED_FIRING, ownerPawn.Weapon);
                signalFire= false;
            }

            weaponIsSwinging= weaponState == 'MeleeAttackBasic' || weaponState == 'MeleeChainAttacking' ||
                    weaponState == 'MeleeHeavyAttacking';
            if (!signalSwing && weaponIsSwinging) {
                playerDispatcher.notifyWeaponEvent(playerDispatcher.WeaponEventType.SWUNG, ownerPawn.Weapon);
                signalSwing= true;
            } else if (signalSwing && !weaponIsSwinging) {
                signalSwing= false;
            }

            weaponIsReloading= ownerPawn.Weapon.IsInState('Reloading');
            if (!signalReload && weaponIsReloading) {
                playerDispatcher.notifyWeaponEvent(playerDispatcher.WeaponEventType.RELOADED, ownerPawn.Weapon);
                signalReload= true;
            } else if (signalReload && !weaponIsReloading) {
                signalReload= false;
            }

            tossingFrag= ownerPawn.Weapon.IsInState('GrenadeFiring');
            if (!signalFragToss && tossingFrag) {
                playerDispatcher.notifyGrenadeTossed(ownerPawn.GetPerk().GetGrenadeClass());
                signalFragToss= true;
            } else if (signalFragToss && !tossingFrag) {
                signalFragToss= false;
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

static function SAReplicationInfo findSAri(Controller RepInfoOwner) {
    local SAReplicationInfo repInfo;

    if (RepInfoOwner == none)
        return none;

    foreach RepInfoOwner.DynamicActors(class'SAReplicationInfo', repInfo)
        if (repInfo.Owner == RepInfoOwner) {
            return repInfo;
        }
 
    return none;
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
}
