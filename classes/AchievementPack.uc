class AchievementPack extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var Texture2D image;
    var bool hideProgress;
    var int maxProgress;
    var int progress;
    var bool completed;
};

enum MatchResult {
    SA_MR_UNKNOWN,
    SA_MR_WON,
    SA_MR_LOST
};

struct MatchInfo {
    var string mapName;
    var byte difficulty;
    var byte length;
    var MatchResult result;
};

event matchEnded(const out MatchInfo info);
event waveStarted(byte newWave, byte waveMax);
event tossedGrenade(class<KFProj_Grenade> grenadeClass);
event reloadedWeapon(Weapon currentWeapon);
event firedWeapon(Weapon currentWeapon);
event died(Controller killer, class<DamageType> damageType);
event killedMonster(Pawn target, class<DamageType> damageType);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType);
event pickedUpItem(Actor item);

function serialize(out array<byte> objectState);
function deserialize(const out array<byte> objectState);
simulated function lookupAchievement(int index, out Achievement result);
simulated function int numAchievements();
simulated function int numCompleted();
simulated function String attrName();

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true
}
