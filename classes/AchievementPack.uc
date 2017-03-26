/**
 * Abstract class containing a collection of achievements and defining callbacks for handling game events.  
 * This mutator only uses references to this class. 
 * @author Eric Tsai (scaryghost)
 */
class AchievementPack extends Actor
    abstract;

/**
 * Achievement properties
 */
struct Achievement {
    var string title;               ///< Achievement title
    var string description;         ///< Achievement description
    var Texture2D image;            ///< Achievement image
    var int maxProgress;            ///< Max progress to reach before achievement is completed
    var int progress;               ///< Current achievement progress
    var bool hideProgress;          ///< True if progress is hidden from the player aka no progress bar
    var bool completed;             ///< True if achievement is completed
};

/**
 * Enumeration of possible match outcomes
 */
enum MatchResult {
    SA_MR_UNKNOWN,          ///< Outcome unknown
    SA_MR_WON,              ///< Match won
    SA_MR_LOST              ///< Match lost
};

/**
 * Tuple holding properties of the current match
 */
struct MatchInfo {
    var string mapName;             ///< Map the match was played on
    var byte difficulty;            ///< Difficulty of the match
    var byte length;                ///< Game length
    var MatchResult result;         ///< Result of the match
};

/**
 * Called when the match ends
 * @param info      Information about the match
 */
event matchEnded(const out MatchInfo info);
/**
 * Called when a wave begins
 * @param newWave   Wave number that started
 * @param waveMax   Maximum number of waves in the game
 */
//event waveStarted(byte newWave, byte waveMax);
/**
 * Called when a grenade is thrown
 * @param grenadeClass      Class of the thrown grenade
 */
//event tossedGrenade(class<KFProj_Grenade> grenadeClass);
/**
 * Called when a gun begins its reloading animation
 * @param currentWeapon     Weapon being reloaded
 */
//event reloadedWeapon(Weapon currentWeapon);
/**
 * Called when a gun begins its firing animation
 * @param currentWeapon     Weapon being fired
 */
//event firedWeapon(Weapon currentWeapon);
/**
 * Called when a gun stops its firing animation
 * @param currentWeapon     Weapon that ceases firing
 */
//event stoppedFiringWeapon(Weapon currentWeapon);
/**
 * Called when a weapon begins its swinging animation
 * @param currentWeapon     Weapon that is swinging
 */
//event swungWeapon(Weapon currentWeapon);
/**
 * Called when the player dies
 * @param killer            Controller of the killer
 * @param damageType        Type of damage that killed the player
 */
//event died(Controller killer, class<DamageType> damageType);
/**
 * Called when the player kills a specimen
 * @param target            Specimen the player killed
 * @param damageType        Type of damage that killed the specimen
 */
//event killedMonster(Pawn target, class<DamageType> damageType);
/**
 * Called when the player damages a specimen
 * @param damage            Amount of damage done
 * @param target            Specimen that was hurt
 * @param damageType        Type of damage that hurt the specimen
 * @param headshot          True if attack was a headshot
 */
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);
/**
 * Called when the player picks up an item
 * @param item              Item that is picked up
 */
//event pickedUpItem(Actor item);

function registerHandlers(GlobalEventDispatcher globalDispatcher, PlayerEventDispatcher playerDispatcher);
/**
 * Convert the achievement pack to a byte array to be saved to disk
 * @param objectState           Array to write the bytes to
 */
function serialize(out array<byte> objectState);
/**
 * Restore the achievement pack's internal state 
 * @param objectState           Byte array containing the class' state
 */
function deserialize(const out array<byte> objectState);

/**
 * Look up achievement definition at a specific index
 * @param index         Numerical index to lookup
 * @param result        Pass by reference variable to store the lookup result
 */
simulated function lookupAchievement(int index, out Achievement result);
/**
 * Get the number of achievements in this pack
 */
simulated function int numAchievements();
/**
 * Get the number of achievements that are completed
 */
simulated function int numCompleted();
/**
 * Get the name of the achievement pack
 */
simulated function String attrName();
/**
 * Unique identifier for the achievement pack
 */
simulated function String attrId();

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
