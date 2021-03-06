module AngrySnowball.Tile;

import Dgame.Graphic.Sprite;
import Dgame.Math.Rect;

enum ubyte TILE_SIZE = 32;

struct Tile {
    enum : ushort {
        Solid = 0x1,
        Left = 0x2,
        Right = 0x4,
        Top = 0x8,
        Bottom = 0x10,
        Edge = Left | Right,
        Gras = 0x20,
        Snow = 0x40,
        Stone = 0x80,
        Ice = 0x100,
        Brittle = 0x200,
        Few = 0x400,
        Many = 0x800,
        Charge = Snow | Ice
    }

    Sprite sprite;
    ushort mask;
    ubyte id;
    ubyte access;

    @nogc
    this(Sprite sprite, ubyte id) pure nothrow {
        this.sprite = sprite;
        this.id = id;

        this.reset();
    }

    @nogc
    void reset() pure nothrow {
        this.mask = TileMasks[this.id];
        this.access = 0;
        this.sprite.setTextureRect(Rect(this.id * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE));
    }

    @nogc
    void refresh() pure nothrow {
        uint index = 0;
        foreach (uint idx, ushort mask; TileMasks) {
            if (mask == this.mask) {
                index = idx;
                break;
            }
        }

        this.sprite.setTextureRect(Rect(index * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE));
    }
}

private immutable ushort[15] TileMasks = [
    Tile.Gras | Tile.Left,
    Tile.Gras,
    Tile.Gras | Tile.Right,
    Tile.Ice,
    Tile.Ice | Tile.Brittle,
    Tile.Snow | Tile.Left,
    Tile.Snow,
    Tile.Snow | Tile.Right,
    Tile.Solid | Tile.Bottom,
    Tile.Solid | Tile.Left,
    Tile.Solid | Tile.Right,
    Tile.Solid,
    Tile.Solid | Tile.Top,
    Tile.Stone | Tile.Few,
    Tile.Stone | Tile.Many
];