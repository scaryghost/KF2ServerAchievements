class StateDataObject extends Object
    PerObjectConfig
    Config(ServerAchievementsState);

struct AchievementState {
    var config Guid packGuid;
    var config array<byte> serializedValue;
};

var() config array<AchievementState> localSavedState;

function array<byte> getSerializedData(const out Guid packGuid) {
    local array<byte> empty;
    local AchievementState it;

    empty.Length= 0;
    foreach localSavedState(it) {
        if (it.packGuid.A == packGuid.A && it.packGuid.B == packGuid.B && it.packGuid.C == packGuid.C && 
                it.packGuid.D == packGuid.D) {
            return it.serializedValue;
        }
    }

    return empty;
}

function updateSerializedData(const out Guid packGuid, const out array<byte> savedState) {
    local AchievementState it, newItem;

    if (savedState.Length > 0) {
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
