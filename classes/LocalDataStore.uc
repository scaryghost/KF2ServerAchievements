class LocalDataStore extends Object
    PerObjectConfig
    Config(ServerAchievementsDataStore);

struct Entry {
    var config string key;
    var config array<byte> value;
};

var config array<Entry> playerData;

function array<byte> getValue(string key) {
    local array<byte> empty;
    local int i;

    empty.Length= 0;
    for(i= 0; i < playerData.Length; i++) {
        if (playerData[i].key == key) {
            return playerData[i].value;
        }
    }

    return empty;
}

function saveValue(string key, const out array<byte> value) {
    local Entry newEntry;
    local int i;

    if (value.Length > 0) {
        for(i= 0; i < playerData.Length; i++) {
            if (playerData[i].key == key) {
                playerData[i].value= value;
                return;
            }
        }

        newEntry.key= key;
        newEntry.value= value;
        playerData.AddItem(newEntry);
    }
}
