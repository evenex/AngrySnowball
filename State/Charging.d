module AngrySnowball.State.Charging;

import Dgame.Math.Rect;

import AngrySnowball.State.State;

final class ChargeState : State {
public:
    @nogc
    final override void enter(ref Actor) pure nothrow {
        
    }

    @nogc
    override State handleInput(ref const Event event) nothrow {
        _direction = _inputHandler(event);
        if (_direction == Direction.Up) {
            return State.Standing;
        }

        return null;
    }

    override State execute(ref Actor actor, ref LevelMap) {
        actor.doCharge();

        return null;
    }
}