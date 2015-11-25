class DataConnection extends Info
    abstract;

var private array<class<AchievementPack> > achievementPackClasses;

final function loadAchievementPacks(const out array<string> classnames) {
    local class<AchievementPack> loadedPack;
    local array<string> uniqueClassnames;
    local string it;

    `Log("Attempting to load" @ classnames.Length @ "achievement packs");

    foreach classnames(it) {
        class'Arrays'.static.uniqueInsert(uniqueClassnames, it);
    }
    foreach uniqueClassnames(it) {
        loadedPack= class<AchievementPack>(DynamicLoadObject(it, class'Class'));
        if (loadedPack == none) {
            `Warn("Failed to load achievement pack" @ it);
        } else {
            `Log("Successfully loaded" @ it);
            achievementPackClasses.AddItem(loadedPack);
        }
    }
}

final function spawnAchievementPacks(SAReplicationInfo saRepInfo) {
    local class<AchievementPack> it;
    local array<AchievementPack> packs;

    if (saRepInfo.Owner.IsA('Controller') && Controller(saRepInfo.Owner).bIsPlayer) {
        foreach achievementPackClasses(it) {
            packs.AddItem(Spawn(it, saRepInfo.Owner));
        }
        retrieveAchievementState(saRepInfo.ownerPri.UniqueId, packs);
    }
}

function retrieveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs);
function saveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs);
