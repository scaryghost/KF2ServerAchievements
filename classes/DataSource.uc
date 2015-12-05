class DataSource extends Object
    abstract;

function retrieveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs);
function saveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs);
