module AngrySnowball.State.Rolling;

import Dgame.Math.Rect;

import AngrySnowball.State.State;

final class RollState : State {
private:
    ubyte _rolling;

public:
    @nogc
    final override void enter(ref Actor) pure nothrow {
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
        //actor.consume();

        if (actor.charge <= 0) {
            roundPosition(actor, _direction);

            return State.Melting;
        }

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
            if (tile.mask & Tile.Ice) {
                // TODO: Tile zerbrechen, wenn der Spieler Steine hat. Die Anzahl an verfügbaren Steinen reduzieren.
            } else if (tile.mask & Tile.Stone) {
                // TODO: Steine aufsammeln
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