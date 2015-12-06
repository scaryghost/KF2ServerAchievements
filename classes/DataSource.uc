class DataSource extends Object
    abstract;

function retrieveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs);
function saveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs);

static function string byteArrayToString(const out array<byte> byteArray) {
    local byte it;
    local string result;
    local array<string> stringValues;

    foreach byteArray(it) {
        stringValues.AddItem(string(it));
    }

    JoinArray(stringValues, result, ",");
    return result;
}

static function stringToByteArray(string stringValue, out array<byte> byteArray) {
    local array<string> parts;
    local string it;

    ParseStringIntoArray(stringValue, parts, ",", true);
    foreach parts(it) {
        byteArray.AddItem(byte(it));
    }
}
