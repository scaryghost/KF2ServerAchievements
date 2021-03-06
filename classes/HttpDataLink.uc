class HttpDataLink extends DataLink
    Config(ServerAchievements);

var() config string httpHostname;
var private array<AchievementPack> pendingPacks;

function retrieveAchievementState(const out UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local array<string> queryParts;
    local string query, steamIdString;
    local AchievementPack it;
    local HttpRequestInterface httpRequest;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    foreach packs(it) {
        pendingPacks.AddItem(it);

        queryParts.Length= 0;
        queryParts.AddItem("action=get");
        queryParts.AddItem("key=serverachievements/" $ steamIdString $ "/" $ it.attrId());

        JoinArray(queryParts, query, "&");

        httpRequest= class'HttpFactory'.static.CreateRequest();
        httpRequest.SetVerb("POST")
            .SetHeader("Content-Type", "application/x-www-form-urlencoded")
            .SetContentAsString(query)
            .SetURL("http://" $ httpHostname)
            .SetProcessRequestCompleteDelegate(retrieveRequestComplete)
            .ProcessRequest();
    }
}

function saveAchievementState(const out UniqueNetId ownerSteamId, const out array<AchievementPack> packs) {
    local array<byte> objectState;
    local array<string> queryParts;
    local string query, steamIdString;
    local AchievementPack it;
    local HttpRequestInterface httpRequest;

    steamIdString= class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId);
    foreach packs(it) {
        it.serialize(objectState);

        queryParts.Length= 0;
        queryParts.AddItem("action=save");
        queryParts.AddItem("key=serverachievements/" $ steamIdString $ "/" $ it.attrId());
        queryParts.AddItem("value=" $ byteArrayToHexString(objectState));

        JoinArray(queryParts, query, "&");

        httpRequest= class'HttpFactory'.static.CreateRequest();
        httpRequest.SetVerb("POST")
                .SetHeader("Content-Type", "application/x-www-form-urlencoded")
                .SetContentAsString(query)
                .SetURL("http://" $ httpHostname)
                .SetProcessRequestCompleteDelegate(saveRequestComplete)
                .ProcessRequest();
    }
}

private function saveRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) {
    if (!bDidSucceed) {
        //<TODO Use FileDataLink to save data locally if server is unreacable
        `Warn("Error saving achievement to http server '" $ httpHostname $ "'.  Response code= " $ InHttpResponse.GetResponseCode(), true, GetPackageName());
        `Warn(InHttpResponse.GetContentAsString(), true, GetPackageName());
    }
}

private function retrieveRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) {
    local array<byte> objectState;

    if (bDidSucceed) {
        hexStringToByteArray(InHttpResponse.GetContentAsString(), objectState);
        pendingPacks[0].deserialize(objectState);
    } else {
        ///<TODO Read data from local file if retrieve request fail
        `Warn("Error retriving achievement data from http server '" $ httpHostname $ "'.  Response code= " $ InHttpResponse.GetResponseCode(), true, GetPackageName());
        `Warn(InHttpResponse.GetContentAsString(), true, GetPackageName());
    }
    pendingPacks.Remove(0, 1);
}
