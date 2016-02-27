class StateDataObject extends Object
    PerObjectConfig
    Config(ServerAchievementsState);

struct AchievementState {
    var config string packClassname;
    var config array<byte> serializedValue;
};

var config array<AchievementState> localSavedState;

function array<byte> getSerializedData(string classname) {
    local array<byte> empty;
    local int i;

    empty.Length= 0;
    for(i= 0; i < localSavedState.Length; i++) {
        if (localSavedState[i].packClassname == classname) {
            return localSavedState[i].serializedValue;
        }
    }

    return empty;
}

function updateSerializedData(string classname, const out array<byte> savedState) {
    local AchievementState newItem;
    local int i;

    if (savedState.Length > 0) {
        for(i= 0; i < localSavedState.Length; i++) {
            if (localSavedState[i].packClassname == classname) {
                localSavedState[i].serializedValue= savedState;
                return;
            }
        }

        newItem.packClassname= classname;
        newItem.serializedValue= savedState;
        localSavedState.AddItem(newItem);
    }
}
