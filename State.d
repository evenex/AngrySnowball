module AngrySnowball.State;

import Dgame.Graphic.Spritesheet;
import Dgame.Window.Event;

import AngrySnowball.Observer;
import AngrySnowball.Command;
import AngrySnowball.Condition;
import AngrySnowball.Transition;
import AngrySnowball.Actor;

abstract class State : Observer, Condition, Transition {
    static State Standing;
    static State Moving;
    static State Droping;

    static this() {
        Standing = new StandState();
        Moving = new MoveState();
        Droping = new DropState();
    }

private:
    InputHandler _input;
    Observer _observer;
    Condition _cond;
    Transition _trans;

public:
    @nogc
    abstract State handleInput(ref const Event);

    @nogc
    abstract State execute(ref Actor);

final:
    @nogc
    void setInputHandler(InputHandler handler) pure nothrow {
        _input = handler;
    }

    @nogc
    void setCondition(Condition cond) pure nothrow {
        _cond = cond;
    }

    @nogc
    bool verify(ref Actor actor) const /*pure*/ nothrow {
        return _cond is null ? true : _cond.verify(actor);
    }

    @nogc
    void setTransition(Transition trans) pure nothrow {
        _trans = trans;
    }

    @nogc
    State next(ref Actor actor) const nothrow {
        return _trans is null ? null : _trans.next(actor);
    }

    @nogc
    void setObserver(Observer ob) pure nothrow {
        _observer = ob;
    }

    @nogc
    void notify(ref Actor actor) const pure nothrow {
        if (_observer)
            _observer.notify(actor);
    }
}

final class StandState : State {
    @nogc
    override State handleInput(ref const Event event) {
        State state = Moving.handleInput(event);
        if (state is null)
            return Moving;
        return state;
    }

    @nogc
    override State execute(ref Actor) {
        return null;
    }
}

final class MoveState : State {
private:
    Command _cmd;

public:
    @nogc
    override State handleInput(ref const Event event) {
        _cmd = _input.handle(event);
        if (_cmd)
            return null;
        return Standing;
    }

    @nogc
    override State execute(ref Actor actor) {
        if (_cmd) {
            _cmd.execute(actor);
            if (!super.verify(actor))
                _cmd.undo(actor);
            else
                super.notify(actor);

            _cmd = null;

            return super.next(actor);
        }

        return Standing;
    }
}

final class DropState : State {
    enum ubyte GRAVITY = 8;

    @nogc 
    override State handleInput(ref const Event) const {
        return null;
    }

    @nogc
    override State execute(ref Actor actor) {
        actor.sprite.move(0, GRAVITY);
        super.notify(actor);

        return super.next(actor);
    }
}