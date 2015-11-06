class StandardAchievementPack extends AchievementPack
    abstract
    dependson(SAInteraction);

var KFPlayerController ownerController;
var PlayerController localController;
var array<StandardAchievement> achievements;
var localized String packName, achvUnlockedMsg, achvInProgressMsg;
var Texture2D defaultAchievementImage;
var Guid packGuid;

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);
event pickedUpItem(Actor item);

simulated function Achievement lookupAchievement(int index) {
    return achievements[index];
}

simulated function int numAchievements() {
    return achievements.Length;
}

simulated function int numCompleted() {
    local int i, numCompleted;

    for(i= 0; i < achievements.Length; i++) {
        if (achievements[i].completed != 0) {
            numCompleted++;
        }
    }
    return numCompleted;
}

simulated function Guid attrId() {
    return packGuid;
}

simulated function String attrName() {
    return packName;
}

reliable client function flushToClient(int index, int progress, byte completed) {
    achievements[index].progress= progress;
    achievements[index].completed= completed;
}

reliable client function notifyProgress(int index) {
    local int i;
    local Texture2D usedImage;
    local PopupMessage newMsg;

    for(i= 0; localController != none && i < localController.Interactions.Length; i++) {
        if (SAInteraction(localController.Interactions[i]) != none) {
            if (achievements[index].image == none) {
                usedImage= defaultAchievementImage;
            } else {
                usedImage= achievements[index].image;
            }
            newMsg.header= achvInProgressMsg;
            newMsg.body= achievements[index].title $ class'SAInteraction'.default.newLineSeparator $ 
                    "(" $ achievements[index].progress $ "/" $ achievements[index].maxProgress $ ")";
            newMsg.image= usedImage;
            SAInteraction(localController.Interactions[i]).addMessage(newMsg);
            break;
        }
    }
}

reliable client function localAchievementCompleted(int index) {
    local int i;
    local Texture2D usedImage;
    local PopupMessage newMsg;

    for(i= 0; localController != none && i < localController.Interactions.Length; i++) {
        if (SAInteraction(localController.Interactions[i]) != none) {
            if (achievements[index].image == none) {
                usedImage= defaultAchievementImage;
            } else {
                usedImage= achievements[index].image;
            }
            newMsg.header= achvUnlockedMsg;
            newMsg.body= packName $ class'SAInteraction'.default.newLineSeparator $ achievements[index].title;
            newMsg.image= usedImage;
            SAInteraction(localController.Interactions[i]).addMessage(newMsg);
            break;
        }
    }
}

defaultproperties
{
    defaultAchievementImage=Texture2D'EditorMaterials.Tick'
}
