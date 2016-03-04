/**
 * Abstract class providing a link to a data container
 */
class DataLink extends Object
    abstract;

/**
 * Retrieve serialized data from disk and restore achieveemnt state
 * @param ownerSteamId          SteamID of the player owning the achievement packs
 * @param packs                 Achievement packs to deserialize
 */
function retrieveAchievementState(const out UniqueNetId ownerSteamId, out array<AchievementPack> packs);
/**
 * Serialize and save the the achievement state to disk
 * @param ownerSteamId          SteamID of the player owning the achievement packs
 * @param packs                 Achievement packs to save to disk
 */
function saveAchievementState(const out UniqueNetId ownerSteamId, const out array<AchievementPack> packs);

static function string byteArrayToHexString(const out array<byte> byteArray) {
    local byte it, lowBits, highBits;
    local string result;

    foreach byteArray(it) {
        lowBits= it & 0xf;
        highBits= (it >> 4) & 0xf;

        result$= (Chr(highBits + (highBits < 10 ? 48 : 55)) $ Chr(lowBits + (lowBits < 10 ? 48 : 55)));
    }

    return result;
}

static function hexStringToByteArray(string stringValue, out array<byte> byteArray) {
    local string next;

    while(Len(stringValue) != 0) {
        next= Left(stringValue, 2);
        byteArray.AddItem(hexCharToInt(Right(next, 1)) | (hexCharToInt(Left(next, 1)) << 4));
        stringValue= Mid(stringValue, 2);
    }
}

static function int hexCharToInt(string hexChar) {
    if (hexChar >= "a" && hexChar <= "f") {
        return Asc(hexChar) - 87;
    } else if (hexChar >= "A" && hexChar <= "F") {
        return Asc(hexChar) - 55;
    } else if (hexChar >= "0" && hexChar <= "9") {
        return Asc(hexChar) - 48;
    }
}
