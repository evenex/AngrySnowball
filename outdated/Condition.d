module AngrySnowball.Condition;

import Dgame.Math.Rect;

import AngrySnowball.Actor;
import AngrySnowball.LevelMap;
import AngrySnowball.Tile;

interface Condition {
    @nogc
    bool verify(ref Actor) const /*pure*/ nothrow;
}

final class MoveCondition : Condition {
    LevelMap* _map;

    @nogc
    this(ref LevelMap map) pure nothrow {
        _map = &map;
    }

    @nogc
    bool verify(ref Actor actor) const/* pure */nothrow {
        const(Tile)* tile = _map.getTile(actor);
        if (tile && (tile.mask & Tile.Gras) == 0)
            return false;

        tile = _map.getTile(actor, Rect.Edge.TopLeft);
        if (tile) {
            import core.stdc.stdio : printf;
            printf("Tile mask: %d\n", tile.mask);
            return (tile.mask & Tile.Gras) != 0;
        }

        return true;
    }
}

