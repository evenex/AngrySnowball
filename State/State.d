module AngrySnowball.State.State;

package:

import Dgame.Math.Vector2;
import Dgame.Math.Rect;
import Dgame.System.Keyboard;
import Dgame.Window.Event;
import Dgame.Window.Window;

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
            tile.refresh();
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
public:
    static State Standing;
    static State Rolling;
    static State Droping;
    static State Charging;
    static State Smashed;
    static State Melted;

    @nogc
    protected void share(ref const Event) { }
    @nogc
    void interact(ref Window) { }
    @nogc
    void wakeup(ref Actor) { }
    @nogc
    void sleep(ref Actor) { }

    @nogc
    abstract State handleEvent(ref const Event);
    @nogc
    abstract State execute(ref Actor, ref LevelMap);
}

static this() {
    State.Standing = new StandState();
    State.Rolling = new RollState();
    State.Droping = new DropState();
    State.Charging = new ChargeState();
    State.Smashed = new SmashedState();
    State.Melted = new MeltedState();
}

final class StandState : State {
    @nogc
    override State handleEvent(ref const Event event) {
        if (event.type == Event.Type.KeyDown) {
            switch (event.keyboard.key) {
                case Keyboard.Key.Left:
                case Keyboard.Key.Right:
                    State.Rolling.share(event);
                    return State.Rolling;
                case Keyboard.Key.Down:
                    return State.Charging;
                default:
                    return null;
            }
        }

        return null;
    }

    @nogc
    override State execute(ref Actor, ref LevelMap) {
        return null;
    }
}

final class RollState : State {
    private ubyte _rolling;
    private Direction _direction;

    @nogc
    protected override void share(ref const Event event) {
        assert(event.type == Event.Type.KeyDown);

        if (event.keyboard.key == Keyboard.Key.Left)
            _direction = Direction.Left;
        else if (event.keyboard.key == Keyboard.Key.Right)
            _direction = Direction.Right;
        else
            assert(0);
    }

    @nogc
    override void wakeup(ref Actor actor) {
        _rolling = 0;
        actor.setDirection(_direction);
    }

    @nogc
    override State handleEvent(ref const Event) {
        return null;
    }

    @nogc
    override State execute(ref Actor actor, ref LevelMap map) {
        if (_rolling >= MOVE_DIV)
            return State.Standing;

        _rolling++;

        actor.sprite.move(MOVE * _direction, 0);
        actor.sprite.rotate(ROTATION * _direction);
        actor.consume();

        if (actor.charge <= 0) {
            roundPosition(actor, _direction);
            return State.Melted;
        }

        const Rect clip = actor.sprite.getClipRect();
        // is the next-bottom tile walkable?
        Vector2f pos = clip.getEdgePosition(Rect.Edge.BottomLeft);
        pos.x = roundCoord(pos.x, _direction);

        Tile* tile = map.getTileAt(pos);
        if (!tile || brokeTile(tile)) {
            roundPosition(actor, _direction);
            return State.Droping;
        }

        immutable float rest = ((MOVE_DIV - _rolling) * MOVE) * _direction;
        // is there a barrier?
        Vector2f pos2 = clip.getEdgePosition(Rect.Edge.TopLeft);
        pos2.x += rest;

        tile = map.getTileAt(pos2);
        if (tile) {
            if (tile.mask & Tile.Ice) {
                // TODO: Tile zerbrechen, wenn der Spieler Steine hat. Die Anzahl an verfügbaren Steinen reduzieren.
            } else if (tile.mask & Tile.Stone) {
                if (tile.mask & Tile.Few)
                    actor.incStoneAmount(5);
                else if (tile.mask & Tile.Many)
                    actor.incStoneAmount(10);

                tile.mask = 0;
                _rolling = 0;

                return null;
            }

            // Undo Move
            //actor.sprite.move(MOVE * _direction * -1, 0);
            roundPosition(actor, _direction);

            return State.Standing;
        }

        return null;
    }
}

final class DropState : State {
    private uint _droping;

    @nogc
    override void wakeup(ref Actor) {
        _droping = 0;
        // TODO: Scream-Sheet for actor?
    }

    @nogc
    override State handleEvent(ref const Event) {
        return null;
    }

    @nogc
    override State execute(ref Actor actor, ref LevelMap map) {
        _droping++;

        actor.sprite.move(0, GRAVITY);
        const Vector2f pos = actor.sprite.getClipRect().getEdgePosition(Rect.Edge.BottomLeft);

        Tile* tile = map.getTileAt(pos);
        if (tile) {
            if (brokeTile(tile))
                return null;
            if (tile.mask & Tile.Stone)
                return State.Smashed;
            return State.Standing;
        } else if (actor.sprite.getPosition().y > 1000) {
            map.reset(actor.sprite);
            return State.Standing;
        }

        return null;
    }
}

final class ChargeState : State {
    private uint _charging;

    @nogc
    override void wakeup(ref Actor) {
        _charging = 0;
        // TODO: Charge Sheet
    }

    @nogc
    override State handleEvent(ref const Event) {
        return null;
    }

    @nogc
    override State execute(ref Actor, ref LevelMap) {
        return null;
    }
}

final class SmashedState : State {
    @nogc
    override void wakeup(ref Actor) {
        // TODO: Set Smash-Sheet
    }

    @nogc
    override State handleEvent(ref const Event) {
        return null;
    }

    @nogc
    override State execute(ref Actor, ref LevelMap) {
        return null;
    }
}

final class MeltedState : State {
    @nogc
    override void wakeup(ref Actor) {
        // TODO: Set Melted-Sheet / set scale to zero
    }

    @nogc
    override State handleEvent(ref const Event) {
        return null;
    }

    @nogc
    override State execute(ref Actor, ref LevelMap) {
        return null;
    }
}