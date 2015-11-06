class AchievementPack extends Actor
    abstract;

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);
event pickedUpItem(Actor item);

simulated function Achievement lookupAchievement(int index);
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
