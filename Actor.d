module AngrySnowball.Actor;

import Dgame.Graphic.Spritesheet;
import Dgame.Window.Event;

import AngrySnowball.State;

enum ubyte MOVE = 32;
enum ubyte ROTATION = 45;

enum Direction : byte {
    None = 0,
    Left = -1,
    Right = 1
}

struct Actor {
    State state;
    Spritesheet sprite;
    Direction direction;

    @nogc
    this(Spritesheet sprite) {
        this.state = State.Standing;
        this.sprite = sprite;
    }

    @disable
    this(this);

    @nogc
    void handleInput(ref const Event event) {
        State state = this.state.handleInput(event);
        if (state !is null)
            this.state = state;
    }

    @nogc
    void execute() {
        State state = this.state.execute(this);
        if (state !is null)
            this.state = state;
    }

    @nogc
    void move() pure nothrow {
        this.sprite.move(MOVE * this.direction, 0);
        this.sprite.rotate(ROTATION * this.direction);
    }
}