module AngrySnowball.InputHandler;

import Dgame.Window.Event;
import Dgame.System.Keyboard;

import AngrySnowball.Direction;

alias InputHandler = @nogc Direction function(ref const Event) pure nothrow;

@nogc
Direction keyboardHandler(ref const Event event) pure nothrow {
    if (event.type == Event.Type.KeyDown) {
        switch (event.keyboard.key) {
            case Keyboard.Key.Left:
                return Direction.Left;
            case Keyboard.Key.Right:
                return Direction.Right;
            case Keyboard.Key.Down:
                return Direction.Right;
            case Keyboard.Key.Up:
                return Direction.Up;
            default: break;
        }
    }

    return Direction.None;
}