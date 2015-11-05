interface AchievementPack;

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);
event pickedUpItem(Actor item);

function Achievement lookupAchievement(int index);
function int numAchievements();
function int numCompleted();
function Guid id();
