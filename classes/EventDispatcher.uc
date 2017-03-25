class EventDispatcher extends Object;

var array<delegate<WaveEvent> > started;
var array<delegate<WeaponEvent> > reloaded, fired, stoppedFiring, swung;
var array<delegate<DeathEvent> > died;

delegate WaveEvent(byte waveNew, byte waveMax);
delegate GrenadeEvent(class<KFProj_Grenade> grenadeClass);
delegate DeathEvent(Pawn Killed, Controller Killer, class<DamageType> damageType);
delegate WeaponEvent(Weapon weapon);
delegate ActorEvent(Actor actor);

