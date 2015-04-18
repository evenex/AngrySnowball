module AngrySnowball.Actor;

import Dgame.Graphic.Sprite;
import Dgame.Graphic.Spritesheet;
import Dgame.Window.Event;

import AngrySnowball.LevelMap;
import AngrySnowball.State.State;

struct Actor {
private:
    Spritesheet _sprite;
    State _state;

public:
    @nogc
    this(Spritesheet sprite) nothrow {
        _sprite = sprite;
        _state = State.Standing;
    }

    @disable
    this(this);

    @property
    @nogc
    inout(Sprite) sprite() inout pure nothrow {
        return _sprite;
    }

    @nogc
    void handleInput(ref const Event event) {
        State state = _state.handleInput(event);
        if (state !is null) {
            state.enter();
            _state = state;
        }
    }

    void execute(ref LevelMap map) {
        State state = _state.execute(this, map);
        if (state !is null) {
            state.enter();
            _state = state;
        }
    }
}