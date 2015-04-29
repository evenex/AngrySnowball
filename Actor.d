module AngrySnowball.Actor;

import Dgame.Graphic.Sprite;
import Dgame.Graphic.Spritesheet;
import Dgame.Window.Event;

import AngrySnowball.LevelMap;
import AngrySnowball.State.State;

enum float CHARGE_FREEZE = 0.001f;
enum float CONSUME_FREEZE = 0.002f;

struct Actor {
private:
    Spritesheet _sprite;
    State _state;

    uint _stoneAmount;

public:
    @nogc
    this(Spritesheet sprite) nothrow {
        _sprite = sprite;
        _state = State.Standing;
        _stoneAmount = 0;
    }

    @disable
    this(this);

    @property
    @nogc
    inout(Sprite) sprite() inout pure nothrow {
        return _sprite;
    }

    @nogc
    void handleEvent(ref const Event event) {
        State state = _state.handleEvent(event);
        if (state !is null) {
            state.wakeup(this);
            _state = state;
        }
    }

    void execute(ref LevelMap map) {
        State state = _state.execute(this, map);
        if (state !is null) {
            state.wakeup(this);
            _state = state;
        }
    }

    @nogc
    void setDirection(Direction dir) pure nothrow {
        ubyte frame = dir == Direction.Left ? 1 : 0;
        if (_stoneAmount > 0 && _stoneAmount < 10)
            frame += 2;
        else if (_stoneAmount >= 10)
            frame += 4;

        _sprite.selectFrame(frame);
    }

    @nogc
    void incStoneAmount(ubyte amount) pure nothrow {
        _stoneAmount += amount;
    }

    @nogc
    bool decStoneAmount(ubyte amount) pure nothrow {
        if (_stoneAmount >= amount) {
            _stoneAmount -= amount;
            return true;
        }
        return false;
    }

    @nogc
    void doCharge() pure nothrow {
        if (_sprite.getScale() < 1f) 
            _sprite.scale(CHARGE_FREEZE);
    }

    @property
    @nogc
    float charge() const pure nothrow {
        return _sprite.getScale();
    }

    @nogc
    void consume() pure nothrow {
        if (_sprite.getScale() > 0) 
            _sprite.scale(CONSUME_FREEZE * -1);
    }
}