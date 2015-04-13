module AngrySnowball.Transition;

import AngrySnowball.Actor;
import AngrySnowball.LevelMap;
import AngrySnowball.Tile;
import AngrySnowball.State;

interface Transition {
    @nogc
    State next(ref Actor) const nothrow;
}

final class MoveTransition : Transition {
    LevelMap* _map;

    @nogc
    this(ref LevelMap map) pure nothrow {
        _map = &map;
    }

    @nogc
    State next(ref Actor actor) const nothrow {
        const Tile* tile = _map.getTile(actor);
        if (!tile)
            return State.Droping;
        return null;
    }
}

final class DropTransition : Transition {
    LevelMap* _map;

    @nogc
    this(ref LevelMap map) pure nothrow {
        _map = &map;
    }

    @nogc
    State next(ref Actor actor) const nothrow {
        const Tile* tile = _map.getTile(actor);
        if (tile)
            return State.Standing;
        return null;
    }
}