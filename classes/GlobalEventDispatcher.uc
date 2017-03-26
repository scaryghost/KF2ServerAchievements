class GlobalEventDispatcher extends Object;

var array<delegate<WaveEvent> > started;

delegate WaveEvent(byte waveNew, byte waveMax);

function notifyWaveStarted(byte waveNew, byte waveMax) {
    local delegate<WaveEvent> it;

    foreach started(it) {
        it(waveNew, waveMax);
    }
}
