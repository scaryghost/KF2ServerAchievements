class AchievementPack extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var Texture2D image;
    var int maxProgress;
    var int progress;
    var byte completed;
};

event killedMonster(Pawn target, class<DamageType> damageType);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType);
event pickedUpItem(Actor item);

function serialize(out array<byte> objectState);
function deserialize(const out array<byte> objectState);
simulated function lookupAchievement(int index, out Achievement result);
simulated function int numAchievements();
simulated function int numCompleted();
simulated function Guid attrId();
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
