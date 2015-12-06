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
    local AchievementState it;

    empty.Length= 0;
    foreach localSavedState(it) {
        if (it.packClassname == classname) {
            return it.serializedValue;
        }
    }

    return empty;
}

function updateSerializedData(string classname, const out array<byte> savedState) {
    local AchievementState it, newItem;

    if (savedState.Length > 0) {
        foreach localSavedState(it) {
            if (it.packClassname == classname) {
                it.serializedValue= savedState;
                return;
            }
        }

        newItem.packClassname= classname;
        newItem.serializedValue= savedState;
        localSavedState.AddItem(newItem);
    }
}
