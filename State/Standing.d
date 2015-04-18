module AngrySnowball.State.Standing;

import Dgame.Math.Rect;

import AngrySnowball.State.State;

final class StandState : State {
    override State handleInput(ref const Event event) {
        _direction = _inputHandler(event);
        if (_direction == Direction.Left || _direction == Direction.Right) {
            return State.Rolling;
        }

        return null;
    }

    @nogc
    override State execute(ref Actor, ref LevelMap) pure nothrow {
        return null;
    }
}