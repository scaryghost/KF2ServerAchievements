interface AchievementPack;

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);
event pickedUpItem(Actor item);

simulated function Achievement lookupAchievement(int index);
simulated function int numAchievements();
simulated function int numCompleted();
simulated function Guid attrId();
simulated function String attrName();
