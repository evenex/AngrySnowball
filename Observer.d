module AngrySnowball.Observer;

import AngrySnowball.State;
import AngrySnowball.Actor;

interface Observer {
    @nogc
    void notify(State.Type, ref Actor) const pure nothrow;
}