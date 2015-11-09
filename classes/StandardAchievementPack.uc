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

function string serializeAchievements() {
    local string serialized;
    local array<string> serializedParts;
    local int i;
    local StandardAchievement it;

    foreach achievements(it, i) {
        if (it.completed != 0 || (it.progress != 0 && it.persistProgress)) {
            serializedParts.AddItem(i $ dataDelim $ it.completed $ dataDelim $ it.progress);
        }
    }

    JoinArray(serializedParts, serialized, achvDelim);
    return serialized;
}

function deserializeAchievements(string serializedAchvs) {
    local array<string> serializedParts, achvData;
    local string it;
    local int index;

    ParseStringIntoArray(serializedAchvs, serializedParts, achvDelim, true);
    foreach serializedParts(it) {
        ParseStringIntoArray(it, achvData, dataDelim, true);
        if (achvData.Length == 3) {
            index= int(achvData[0]);
            achievements[index].completed= byte(achvData[1]);
            achievements[index].progress= int(achvData[2]);
            flushToClient(index, achievements[index].progress, achievements[index].completed);

            if (achievements[index].completed == 0 && achievements[index].maxProgress != 0) {
                achievements[index].notifyCount= achievements[index].progress / 
                        (achievements[index].maxProgress * achievements[index].notifyProgress);
            }
        }
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
