class FileDataConnection extends DataConnection;

function retrieveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local String steamIdString;
    local AchievementPack it;
    local StateDataObject stateObject;
    local Guid packGuid;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    stateObject= new(None, steamIdString) class'StateDataObject';
    foreach packs(it) {
        packGuid= it.attrId();
        it.deserializeAchievements(stateObject.getSerializedData(packGuid));
    }
}

function saveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local String steamIdString;
    local AchievementPack it;
    local StateDataObject stateObject;
    local Guid packGuid;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    stateObject= new(None, steamIdString) class'StateDataObject';
    foreach packs(it) {
        packGuid= it.attrId();
        stateObject.updateSerializedData(packGuid, it.serializeAchievements());
    }

    stateObject.SaveConfig();
}
