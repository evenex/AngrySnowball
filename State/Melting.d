module AngrySnowball.State.Melting;

import Dgame.Math.Rect;

import AngrySnowball.State.State;

final class MeltState : State {
public:
    @nogc
    final override void enter(ref Actor) pure nothrow {
        
    }

    @nogc
    override State handleInput(ref const Event) pure nothrow {
        return null;
    }

    override State execute(ref Actor, ref LevelMap) {
        return null;
    }
}