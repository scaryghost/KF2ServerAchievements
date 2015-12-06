class FileDataSource extends DataSource;

function retrieveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local array<byte> objectState;
    local string steamIdString;
    local AchievementPack it;
    local StateDataObject stateObject;
    local Guid packGuid;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    stateObject= new(None, steamIdString) class'StateDataObject';
    foreach packs(it) {
        packGuid= it.attrId();

        objectState= stateObject.getSerializedData(packGuid);
        it.deserialize(objectState);
    }
}

function saveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local array<byte> objectState;
    local String steamIdString;
    local AchievementPack it;
    local StateDataObject stateObject;
    local Guid packGuid;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    stateObject= new(None, steamIdString) class'StateDataObject';
    foreach packs(it) {
        packGuid= it.attrId();
        it.serialize(objectState);

        stateObject.updateSerializedData(packGuid, objectState);
    }

    stateObject.SaveConfig();
}
