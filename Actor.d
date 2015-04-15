module AngrySnowball.Actor;

import Dgame.Graphic.Sprite;
import Dgame.Graphic.Spritesheet;
import Dgame.Math.Vector2;
import Dgame.Math.Rect;
import Dgame.Window.Event;

import AngrySnowball.InputHandler;
import AngrySnowball.Direction;
import AngrySnowball.State;
import AngrySnowball.LevelMap;
import AngrySnowball.Tile;

enum ubyte MOVE_DIV = 16;
enum ubyte ROT_DIV = 32;

enum float MOVE = TILE_SIZE / MOVE_DIV;
enum float ROTATION = 360 / ROT_DIV;

enum ubyte GRAVITY = 8;

struct Actor {
private:
    State _state;
    InputHandler _inputHandler;
    Direction _direction;
    Spritesheet _sprite;

    ubyte _rolling;

public:
    @nogc
    this(Spritesheet sprite, InputHandler inputHandler) {
        _state = State.Standing;
        _inputHandler = inputHandler;
        _sprite = sprite;
    }

    @disable
    this(this);

    @property
    @nogc
    Direction direction() const pure nothrow {
        return _direction;
    }

    @property
    @nogc
    inout(Sprite) sprite() inout pure nothrow {
        return _sprite;
    }

    @nogc
    void handleInput(ref const Event event) {
        const Direction dir = _inputHandler(event);
        switch (_state) {
            case State.Standing:
                if (dir == Direction.Left || dir == Direction.Right) {
                    _state = State.Rolling;
                    _direction = dir;
                    _rolling = 0;
                }
            break;
            default: break;
        }
    }

    @nogc
    void execute(ref LevelMap map) pure nothrow {
        switch (_state) {
            case State.Rolling:
                if (_rolling >= MOVE_DIV) {
                    _state = State.Standing;
                    break;
                }

                _rolling++;

                _sprite.move(MOVE * _direction, 0);
                _sprite.rotate(ROTATION * _direction);

                import std.math : ceil, floor;

                Vector2f pos = _sprite.getClipRect().getEdgePosition(Rect.Edge.BottomLeft);
                if (_direction == Direction.Left)
                    pos.x = ceil(pos.x / TILE_SIZE) * TILE_SIZE;
                else
                    pos.x = floor(pos.x / TILE_SIZE) * TILE_SIZE;

                Tile* tile = map.getTileAt(pos);
                if (!tile) {
                    _state = State.Droping;
                    break;
                }

                immutable float rest = ((MOVE_DIV - _rolling) * MOVE) * _direction;

                Vector2f pos2 = _sprite.getClipRect().getEdgePosition(Rect.Edge.TopLeft);
                pos2.x += rest;

                tile = map.getTileAt(pos2);
                if (tile) {
                    _state = State.Standing;
                    _sprite.move(MOVE * _direction * -1, 0);
                }
            break;

            case State.Droping:
                _sprite.move(0, GRAVITY);
                const(Tile)* tile = map.getTileAt(_sprite.getClipRect().getEdgePosition(Rect.Edge.BottomLeft));
                if (tile)
                    _state = State.Standing;
                else if (_sprite.getPosition().y > 1000)
                    _state = State.Lose;
            break;

            default: break;
        }
    }
}