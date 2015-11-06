class StandardAchievementPack extends AchievementPack
    abstract
    dependson(SAInteraction);

var protectedwrite KFPlayerController ownerController;
var protectedwrite PlayerController localController;
var protectedwrite array<StandardAchievement> achievements;
var protectedwrite localized String packName, achvUnlockedMsg, achvInProgressMsg;
var protectedwrite Texture2D defaultAchievementImage;
var protectedwrite Guid packGuid;

simulated event PostBeginPlay() {
    if (AIController(Owner) != none) {
        localController= GetALocalPlayerController();
    }
    ownerController= KFPlayerController(Owner);
}

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

function achievementCompleted(int index) {
    if (achievements[index].completed == 0) {
        achievements[index].completed= 1;
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        localAchievementCompleted(index);
    }
}

function addProgress(int index, int offset) {
    achievements[index].progress+= offset;
    if (achievements[index].progress >= achievements[index].maxProgress) {
        achievementCompleted(index);
    } else if (!achievements[index].noSave) {
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        if (achievements[index].progress >= achievements[index].notifyIncrement * (achievements[index].timesNotified + 1) * achievements[index].maxProgress) {
            notifyProgress(index);
            achievements[index].timesNotified++;
        }
    }
}

defaultproperties
{
    defaultAchievementImage=Texture2D'EditorMaterials.Tick'
}
