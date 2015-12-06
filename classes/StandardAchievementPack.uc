class StandardAchievementPack extends AchievementPack
    abstract
    dependson(SAInteraction);

struct StandardAchievement extends Achievement {
    var localized string title;
    var localized string description;
    var float notifyProgress;
    var bool persistProgress;
    var byte notifyCount;
};

var protectedwrite KFPlayerController ownerController;
var protectedwrite PlayerController localController;
var protectedwrite array<StandardAchievement> achievements;
var protectedwrite localized String packName;
var protectedwrite Texture2D defaultAchievementImage;
var protectedwrite Guid packGuid;

var private localized String achvUnlockedMsg, achvInProgressMsg;
var private const String dataDelim, achvDelim;

simulated event PostBeginPlay() {
    if (AIController(Owner) == none) {
        localController= GetALocalPlayerController();
    }
    ownerController= KFPlayerController(Owner);
}

function serialize(out array<byte> objectState) {
    local StandardAchievement it;

    objectState.Length= 0;
    foreach achievements(it) {
        if (it.persistProgress) {
            objectState.AddItem(it.progress & 0xff);
            objectState.AddItem((it.progress >> 8) & 0xff);
            objectState.AddItem((it.progress >> 16) & 0xff);
            objectState.AddItem((it.progress >> 24) & 0xff);
        } else {
            objectState.AddItem(it.completed);
        }
    }
}

function deserialize(const out array<byte> objectState) {
    local int i, j;
    local StandardAchievement it;

    i= 0;
    foreach achievements(it, j) {
        if (i >= objectState.Length) {
            break;
        }
        if (it.persistProgress) {
            it.progress= (objectState[i] | (objectState[i + 1] << 8) | (objectState[i + 2] << 16) | (objectState[i + 3] << 24));
            i+= 4;

            it.completed= it.progress >= it.maxProgress ? 1 : 0;
            if (it.completed == 0 && it.maxProgress != 0 && it.persistProgress) {
                it.notifyCount= it.progress / (it.maxProgress * it.notifyProgress);
            }
        } else {
            it.completed= objectState[i];
            i++;
        }

        flushToClient(j, it.progress, it.completed);
    }
}

simulated function lookupAchievement(int index, out Achievement result) {
    result.title= achievements[index].title;
    result.description= achievements[index].description;
    result.maxProgress= achievements[index].maxProgress;
    result.progress= achievements[index].progress;
    result.completed= achievements[index].completed;

    if (achievements[index].image == none) {
        result.image= defaultAchievementImage;
    } else {
        result.image= achievements[index].image;
    }
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

function protected achievementCompleted(int index) {
    if (achievements[index].completed == 0) {
        achievements[index].completed= 1;
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        localAchievementCompleted(index);
    }
}

function protected addProgress(int index, int offset) {
    achievements[index].progress+= offset;
    if (achievements[index].progress >= achievements[index].maxProgress) {
        achievementCompleted(index);
    } else if (achievements[index].persistProgress) {
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        if (achievements[index].progress >= achievements[index].notifyProgress * 
                    (achievements[index].notifyCount + 1) * achievements[index].maxProgress) {
            notifyProgress(index);
            achievements[index].notifyCount++;
        }
    }
}

defaultproperties
{
    dataDelim=","
    achvDelim=";"
    defaultAchievementImage=Texture2D'EditorMaterials.Tick'
}
