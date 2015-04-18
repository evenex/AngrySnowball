module AngrySnowball.Command;

import Dgame.Math.Vector2;
import Dgame.System.Keyboard;
import Dgame.Window.Event;

import AngrySnowball.Actor;

enum ubyte FRAME_RIGHT = 0;
enum ubyte FRAME_LEFT = 1;

interface Command {
    @nogc
    void undo(ref Actor) pure nothrow;

    @nogc
    void execute(ref Actor) pure nothrow;
}

abstract class Move : Command {
private:
    Vector2f _position;

protected:
    @nogc
    final void _move(ref Actor actor) pure nothrow {
        _position = actor.sprite.getPosition();

        actor.move();
    }

public:
    @nogc
    void undo(ref Actor actor) const pure nothrow {
        actor.sprite.setPosition(_position);
    }
}

final class MoveLeft : Move {
    @nogc
    void execute(ref Actor actor) pure nothrow {
        actor.sprite.selectFrame(FRAME_LEFT);
        actor.direction = Direction.Left;

        _move(actor);
    }
}

final class MoveRight : Move {
    @nogc
    void execute(ref Actor actor) pure nothrow {
        actor.sprite.selectFrame(FRAME_RIGHT);
        actor.direction = Direction.Right;

        _move(actor);
    }
}

interface InputHandler {
    @nogc
    Command handle(ref const Event) pure nothrow;
}

final class KeyHandler : InputHandler {
    Command left;
    Command right;

    @nogc
    Command handle(ref const Event event) pure nothrow {
        if (event.type == Event.Type.KeyDown) {
            switch (event.keyboard.key) {
                case Keyboard.Key.Left:
                    return this.left;
                case Keyboard.Key.Right:
                    return this.right;
                default: break;
            }
        }

        return null;
    }
}