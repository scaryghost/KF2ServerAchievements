class FileDataSource extends DataSource;

function retrieveAchievementState(const out UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local array<byte> objectState;
    local string steamIdString;
    local AchievementPack it;
    local LocalDataStore dataStore;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    dataStore= new(None, steamIdString) class'LocalDataStore';
    foreach packs(it) {
        objectState= dataStore.getValue(PathName(it.class));
        it.deserialize(objectState);
    }
}

function saveAchievementState(const out UniqueNetId ownerSteamId, const out array<AchievementPack> packs) {
    local array<byte> objectState;
    local String steamIdString;
    local AchievementPack it;
    local LocalDataStore dataStore;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    dataStore= new(None, steamIdString) class'LocalDataStore';
    foreach packs(it) {
        it.serialize(objectState);
        dataStore.saveValue(PathName(it.class), objectState);
    }

    dataStore.SaveConfig();
}
