module AngrySnowball.Observer;

import AngrySnowball.Actor;

interface Observer {
    @nogc
    void notify(ref Actor) const pure nothrow;
}