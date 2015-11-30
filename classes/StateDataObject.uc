class StateDataObject extends Object
    PerObjectConfig
    Config(ServerAchievementsState);

struct AchievementState {
    var config Guid packGuid;
    var config String serializedValue;
};

var() config array<AchievementState> localSavedState;

function string getSerializedData(const out Guid packGuid) {
    local AchievementState it;

    foreach localSavedState(it) {
        if (it.packGuid.A == packGuid.A && it.packGuid.B == packGuid.B && it.packGuid.C == packGuid.C && 
                it.packGuid.D == packGuid.D) {
            return it.serializedValue;
        }
    }

    return "";
}

function updateSerializedData(const out Guid packGuid, string savedState) {
    local AchievementState it, newItem;

    if (Len(savedState) > 0) {
        foreach localSavedState(it) {
            if (it.packGuid.A == packGuid.A && it.packGuid.B == packGuid.B && it.packGuid.C == packGuid.C && 
                    it.packGuid.D == packGuid.D) {
                it.serializedValue= savedState;
                return;
            }
        }

        newItem.packGuid= packGuid;
        newItem.serializedValue= savedState;
        localSavedState.AddItem(newItem);
    }
}
