class PlayerEventDispatcher extends Object;

enum WeaponEventType {
    RELOADED,
    FIRED,
    STOPPED_FIRING,
    SWUNG
};

enum DeathEventType {
    PLAYER_DIED,
    MONSTER_DIED
};

var array<delegate<GrenadeEvent> > tossed;
var array<delegate<WeaponEvent> > reloaded, fired, stoppedFiring, swung;
var array<delegate<DeathEvent> > playerDied, monsterDied;
var array<delegate<ActorEvent> > pickedUpItem;

delegate GrenadeEvent(class<KFProj_Grenade> grenadeClass);
delegate DeathEvent(Pawn killed, Controller killer, class<DamageType> dmgType);
delegate WeaponEvent(Weapon weapon);
delegate ActorEvent(Actor actor);

function notifyGrenadeTossed(class<KFProj_Grenade> grenadeClass) {
    local delegate<GrenadeEvent> it;

    foreach tossed(it) {
        it(grenadeClass);
    }
}

function notifyWeaponEvent(WeaponEventType eventType, Weapon weapon) {
    local delegate<WeaponEvent> it;
    local array<delegate<WeaponEvent> > handlers;

    switch(eventType) {
    case RELOADED:
        handlers = reloaded;
        break;
    case FIRED:
        handlers = fired;
        break;
    case STOPPED_FIRING:
        handlers = stoppedFiring;
        break;
    case SWUNG:
        handlers = swung;
        break;
    }

    foreach handlers(it) {
        it(weapon);
    }
}

function notifyDeathEvent(DeathEventType eventType, Pawn killed, Controller killer, class<DamageType> dmgType) {
    local delegate<DeathEvent> it;
    local array<delegate<DeathEvent> > handlers;

    switch(eventType) {
    case PLAYER_DIED:
        handlers = playerDied;
        break;
    case MONSTER_DIED:
        handlers = monsterDied;
        break;
    }

    foreach handlers(it) {
        it(killed, killer, dmgType);
    }
}

function notifyItemPickup(Actor item) {
    local delegate<ActorEvent> it;

    foreach pickedUpItem(it) {
        it(item);
    }
}
