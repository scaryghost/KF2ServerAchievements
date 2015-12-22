class StandardAchievementPack extends AchievementPack
    abstract
    dependson(SAInteraction);

struct StandardAchievement extends Achievement {
    var localized string title;
    var localized string description;
    var float notifyProgress;
    var int nextProgress;
    var bool persistProgress;
};

var protectedwrite KFPlayerController ownerController;
var protectedwrite PlayerController localController;
var protectedwrite array<StandardAchievement> achievements;
var protectedwrite localized String packName;
var protectedwrite Texture2D defaultAchievementImage;

var private localized String achvUnlockedMsg, achvInProgressMsg;

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
            objectState.AddItem(it.completed ? 1 : 0);
        }
    }
}

function deserialize(const out array<byte> objectState) {
    local int i, j, count, notifyStep;

    i= 0;
    for(j= 0; j < achievements.Length; j++) {
        if (i >= objectState.Length) {
            break;
        }
        if (achievements[j].persistProgress) {
            achievements[j].progress= (objectState[i] | (objectState[i + 1] << 8) | (objectState[i + 2] << 16) | (objectState[i + 3] << 24));
            i+= 4;

            achievements[j].completed= achievements[j].progress >= achievements[j].maxProgress;
            if (!achievements[j].completed && achievements[j].maxProgress != 0 && achievements[j].notifyProgress != 0) {
                notifyStep= achievements[j].maxProgress * achievements[j].notifyProgress;
                count= achievements[j].progress / notifyStep;
                achievements[j].nextProgress= (count + 1) * notifyStep;
            }
        } else {
            achievements[j].completed= (objectState[i] != 0);
            i++;
        }

        flushToClient(j, achievements[j].progress, achievements[j].completed);
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
    local int numCompleted;
    local StandardAchievement it;

    foreach achievements(it) {
        if (!it.completed) {
            numCompleted++;
        }
    }
    return numCompleted;
}

simulated function String attrName() {
    return packName;
}

reliable client function flushToClient(int index, int progress, bool completed) {
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
    if (!achievements[index].completed) {
        achievements[index].completed= true;
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        localAchievementCompleted(index);
    }
}

function protected addProgress(int index, int offset) {
    achievements[index].progress+= offset;
    if (achievements[index].progress >= achievements[index].maxProgress) {
        achievementCompleted(index);
    } else {
        if (achievements[index].notifyProgress != 0) {
            flushToClient(index, achievements[index].progress, achievements[index].completed);

            if (achievements[index].nextProgress == 0) {
                achievements[index].nextProgress= achievements[index].maxProgress * achievements[index].notifyProgress;
            }

            if (achievements[index].progress >= achievements[index].nextProgress) {
                notifyProgress(index);
                achievements[index].nextProgress+= achievements[index].maxProgress * achievements[index].notifyProgress;
            }
        }
    }
}

defaultproperties
{
    defaultAchievementImage=Texture2D'EditorMaterials.Tick'
}
