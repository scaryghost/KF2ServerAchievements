class HttpDataConnection extends DataConnection;

var private array<AchievementPack> pendingPacks;

function retrieveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local array<string> queryParts;
    local string query;
    local AchievementPack it;
    local HttpRequestInterface httpRequest;
    local Guid packId;

    foreach packs(it) {
        pendingPacks.AddItem(it);

        packId= it.attrId();
        queryParts.Length= 0;
        queryParts.AddItem("action=get");
        queryParts.AddItem("steamid=" $ class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId));
        queryParts.AddItem("packguid=" $ Locs(GetStringFromGuid(packId)));

        JoinArray(queryParts, query, "&");

        httpRequest= class'HttpFactory'.static.CreateRequest();
        httpRequest.SetVerb("POST")
            .SetHeader("Content-Type", "application/x-www-form-urlencoded")
            .SetContentAsString(query)
            .SetURL("http://192.168.0.201:8000")
            .SetProcessRequestCompleteDelegate(getRequestComplete)
            .ProcessRequest();
    }
}

function saveAchievementState(UniqueNetId ownerSteamId, out array<AchievementPack> packs) {
    local array<string> queryParts;
    local string query;
    local AchievementPack it;
    local HttpRequestInterface httpRequest;
    local Guid packId;

    foreach packs(it) {
        packId= it.attrId();

        queryParts.Length= 0;
        queryParts.AddItem("steamid=" $ class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(ownerSteamId));
        queryParts.AddItem("action=save");
        queryParts.AddItem("packguid=" $ Locs(GetStringFromGuid(packId)));
        queryParts.AddItem("state=" $ it.serializeAchievements());

        JoinArray(queryParts, query, "&");

        httpRequest= class'HttpFactory'.static.CreateRequest();
        httpRequest.SetVerb("POST")
                .SetHeader("Content-Type", "application/x-www-form-urlencoded")
                .SetContentAsString(query)
                .SetURL("http://192.168.0.201:8000")
                .ProcessRequest();
    }
}

function getRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) {
    `Log("Result? " $ bDidSucceed);
    `Log("State: " $ InHttpResponse.GetContentAsString());
    if (bDidSucceed) {
        pendingPacks[0].deserializeAchievements(InHttpResponse.GetContentAsString());
        pendingPacks.Remove(0, 1);
    }
}
