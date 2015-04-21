module AngrySnowball.State.Droping;

import Dgame.Math.Rect;

import AngrySnowball.State.State;

final class DropState : State {
public:
    @nogc
    override State handleInput(ref const Event) pure nothrow {
        return null;
    }

    override State execute(ref Actor actor, ref LevelMap map) {
        actor.sprite.move(0, GRAVITY);
        const Vector2f pos = actor.sprite.getClipRect().getEdgePosition(Rect.Edge.BottomLeft);

        Tile* tile = map.getTileAt(pos);
        if (tile) {
            if (brokeTile(tile))
                return null;
            return State.Standing;
        } else if (actor.sprite.getPosition().y > 1000) {
            map.reset(actor.sprite);

            return State.Standing;
        }

        return null;
    }
}