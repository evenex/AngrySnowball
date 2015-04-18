module AngrySnowball.State.State;

package:

import Dgame.Math.Vector2;
import Dgame.Window.Event;

import AngrySnowball.InputHandler;
import AngrySnowball.Direction;
import AngrySnowball.LevelMap;
import AngrySnowball.Tile;
import AngrySnowball.Actor;

enum ubyte MOVE_DIV = 16;
enum ubyte ROT_DIV = 32;

enum float MOVE = TILE_SIZE / MOVE_DIV;
enum float ROTATION = 360 / ROT_DIV;

enum ubyte GRAVITY = 8;

@nogc
float roundCoord(float cx, Direction dir) pure nothrow {
    import std.math : ceil, floor;

    if (dir == Direction.Left)
        return ceil(cx / TILE_SIZE) * TILE_SIZE;
    
    return floor(cx / TILE_SIZE) * TILE_SIZE;
}

@nogc
bool brokeTile(Tile* tile) pure nothrow {
    if (tile && tile.mask & Tile.Ice) {
        tile.access++;

        if (tile.mask & Tile.Brittle) {
            if (tile.access > MOVE_DIV) {
                tile.mask = 0;
                
                return true;
            }
        } else {
            tile.mask |= Tile.Brittle;
            tile.load();
        }
    }

    return false;
}

@nogc
void roundPosition(ref Actor actor, Direction dir) pure nothrow {
    const Vector2f pos = actor.sprite.getPosition();
    actor.sprite.setPosition(roundCoord(pos.x, dir), pos.y);
}

public:

abstract class State {
private:
    static InputHandler _inputHandler;
    static Direction _direction;

public:
    static State Standing;
    static State Rolling;
    static State Droping;
    static State Charging;
    static State Melting;

    @nogc
    static void setInputHandler(InputHandler handler) nothrow {
        _inputHandler = handler;
    }

    @nogc
    void enter(ref Actor) pure nothrow { }

    @nogc
    abstract State handleInput(ref const Event) nothrow;
    abstract State execute(ref Actor, ref LevelMap);
}

static this() {
    import AngrySnowball.State.Standing;
    import AngrySnowball.State.Rolling;
    import AngrySnowball.State.Droping;
    import AngrySnowball.State.Charging;
    import AngrySnowball.State.Melting;

    State.Standing = new StandState();
    State.Rolling = new RollState();
    State.Droping = new DropState();
    State.Charging = new ChargeState();
    State.Melting = new MeltState();
}