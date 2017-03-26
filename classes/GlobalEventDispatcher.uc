class GlobalEventDispatcher extends Object;

var array<delegate<WaveEvent> > started;
var array<delegate<MatchEvent> > ended;

/**
 * Enumeration of possible match outcomes
 */
enum MatchResult {
    SA_MR_UNKNOWN,          ///< Outcome unknown
    SA_MR_WON,              ///< Match won
    SA_MR_LOST              ///< Match lost
};

/**
 * Tuple holding properties of the current match
 */
struct MatchInfo {
    var string mapName;             ///< Map the match was played on
    var byte difficulty;            ///< Difficulty of the match
    var byte length;                ///< Game length
    var MatchResult result;         ///< Result of the match
};

delegate WaveEvent(byte waveNew, byte waveMax);
delegate MatchEvent(const out MatchInfo info);

function notifyWaveStarted(byte waveNew, byte waveMax) {
    local delegate<WaveEvent> it;

    foreach started(it) {
        it(waveNew, waveMax);
    }
}

function notifyMatchEnded(const out MatchInfo info) {
    local delegate<MatchEvent> it;

    foreach ended(it) {
        it(info);
    }
}
