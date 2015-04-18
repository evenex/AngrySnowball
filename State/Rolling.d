module AngrySnowball.State.Rolling;

import Dgame.Math.Rect;

import AngrySnowball.State.State;

final class RollState : State {
private:
    ubyte _rolling;

public:
    @nogc
    final override void enter() pure nothrow {
        _rolling = 0;
    }

    @nogc
    override State handleInput(ref const Event) pure nothrow {
        return null;
    }

    override State execute(ref Actor actor, ref LevelMap map) nothrow {
        if (_rolling >= MOVE_DIV)
            return State.Standing;

        _rolling++;

        actor.sprite.move(MOVE * _direction, 0);
        actor.sprite.rotate(ROTATION * _direction);

        const Rect clip = actor.sprite.getClipRect();
        // is the next-bottom tile walkable?
        Vector2f pos = clip.getEdgePosition(Rect.Edge.BottomLeft);
        pos.x = roundCoord(pos.x, _direction);

        Tile* tile = map.getTileAt(pos);
        if (!tile) {
            roundPosition(actor, _direction);

            return State.Droping;
        }
        
        if (brokeTile(tile)) {
            roundPosition(actor, _direction);

            return State.Droping;
        }

        immutable float rest = ((MOVE_DIV - _rolling) * MOVE) * _direction;
        // is there a barrier?
        Vector2f pos2 = clip.getEdgePosition(Rect.Edge.TopLeft);
        pos2.x += rest;

        tile = map.getTileAt(pos2);
        if (tile) {
            // Undo Move
            actor.sprite.move(MOVE * _direction * -1, 0);

            return State.Standing;
        }

        return null;
    }
}