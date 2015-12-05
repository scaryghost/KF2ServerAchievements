class HttpDataSource extends DataSource
    Config(ServerAchievements);

var() config string httpHostname;
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
            .SetURL("http://" $ httpHostname)
            .SetProcessRequestCompleteDelegate(retrieveRequestComplete)
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
                .SetURL("http://" $ httpHostname)
                .SetProcessRequestCompleteDelegate(saveRequestComplete)
                .ProcessRequest();
    }
}

function saveRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) {
    if (!bDidSucceed) {
        `Warn("Error saving achievement to from http server '" $ httpHostname $ "'");
    }
}

function retrieveRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) {
    if (bDidSucceed) {
        pendingPacks[0].deserializeAchievements(InHttpResponse.GetContentAsString());
    } else {
        `Warn("Error retriving achievement data from http server '" $ httpHostname $ "'");
    }
    pendingPacks.Remove(0, 1);
}
