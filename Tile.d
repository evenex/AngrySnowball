module AngrySnowball.Tile;

import Dgame.Graphic.Sprite;

struct Tile {
    enum {
        Solid = 0x1,
        Left = 0x2,
        Right = 0x4,
        Top = 0x8,
        Bottom = 0x10,
        Edge = Left | Right,
        Brittle = 0x20,
        Gras = 0x40,
        Snow = 0x80,
        Stone = 0x100,
        Ice = 0x200,
        Crystal = 0x400,
        Charge = Snow | Ice | Crystal,
        Fragile = Ice | Crystal
    }

    Sprite sprite;
    uint mask;
    ubyte access;

    @nogc
    this(Sprite sprite, uint mask) pure nothrow {
        this.sprite = sprite;
        this.mask = mask;
    }
}

immutable uint[15] TileMasks = [
    Tile.Gras | Tile.Left,
    Tile.Gras,
    Tile.Gras | Tile.Right,
    Tile.Snow | Tile.Left,
    Tile.Snow,
    Tile.Snow | Tile.Right,
    Tile.Gras | Tile.Brittle,
    Tile.Stone,
    Tile.Solid,
    Tile.Solid | Tile.Left,
    Tile.Solid | Tile.Top,
    Tile.Solid | Tile.Right,
    Tile.Solid | Tile.Bottom,
    Tile.Ice,
    Tile.Crystal
];