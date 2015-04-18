module AngrySnowball.Actor;

import Dgame.Graphic.Sprite;
import Dgame.Graphic.Spritesheet;
import Dgame.Window.Event;

import AngrySnowball.LevelMap;
import AngrySnowball.State.State;

enum ubyte CHARGE_FREEZE = 2;
enum ubyte CONSUME_FREEZE = 3;

struct Actor {
private:
    Spritesheet _sprite;
    State _state;

    int _frozenness;

public:
    bool stone;

    @nogc
    this(Spritesheet sprite) nothrow {
        _sprite = sprite;
        _state = State.Standing;
        _frozenness = 255;
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
            state.enter(this);
            _state = state;
        }
    }

    void execute(ref LevelMap map) {
        State state = _state.execute(this, map);
        if (state !is null) {
            state.enter(this);
            _state = state;
        }
    }

    @nogc
    void doCharge() pure nothrow {
        _frozenness += CHARGE_FREEZE;
    }

    @property
    @nogc
    int charge() const pure nothrow {
        return _frozenness;
    }

    @nogc
    void consume() pure nothrow {
        _frozenness -= CONSUME_FREEZE;
    }
}