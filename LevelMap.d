module AngrySnowball.LevelMap;

import Dgame.Graphic.Sprite;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Surface;
import Dgame.Window.Window;
import Dgame.Math.Vector2;

import AngrySnowball.Actor;
import AngrySnowball.Tile;

immutable string TilesetFile = "stuff/images/Tileset.png";
immutable string LevelFile = "stuff/map/Level_%d.tmx";

enum ubyte MAP_WIDTH = 20;

private immutable Vector2f[1] StartPositions = [
    Vector2f(2 * TILE_SIZE, 1 * TILE_SIZE)
];

struct LevelMap {
private:
    Tile[] _tiles;

    Texture _tileTex;

    ubyte _number;

public:
    @disable
    this(this);

    @property
    @nogc
    ubyte getLevelNr() const pure nothrow {
        return _number;
    }

    bool loadNext(Sprite sprite) {
        return this.load(++_number, sprite);
    }

    bool reload(Sprite sprite) {
        return this.load(_number, sprite);
    }

    bool load(ubyte lvlNr, Sprite sprite) {
        import std.file : read, exists;
        import std.string : format, split, strip;
        import std.conv : to;
        import arsd.dom : Document;

        if (_tileTex.width == 0)
            _tileTex = Texture(Surface(TilesetFile));

        _number = lvlNr;

        immutable string level_file = format(LevelFile, _number);
        if (!exists(level_file))
            return false;

        auto document = new Document(cast(string) read(level_file), true, true);
        auto data = document.requireSelector("data");

        if (_tiles.length != 0) {
            _tiles.length = 0;
            _tiles.assumeSafeAppend();
        }

        ubyte x, y;
        foreach (string s; data.innerHTML.split(',')) {
            immutable ubyte id = to!(ubyte)(s.strip);
            if (id > 0 && id < 255) {
                Sprite tile_sprite = new Sprite(_tileTex, Vector2f(x * TILE_SIZE, y * TILE_SIZE));

                _tiles ~= Tile(tile_sprite, TileMasks[id - 1]);
            }

            x++;
            if (x >= MAP_WIDTH) {
                x = 0;
                y++;
            }
        }

        sprite.setPosition(StartPositions[_number - 1]);

        return true;
    }

    void renderOn(ref const Window wnd) {
        foreach (ref Tile tile; _tiles) {
            if (tile.mask == 0)
                continue;
            wnd.draw(tile.sprite);
        }
    }

    @nogc
    inout(Tile)* getTileAt()(auto ref const Vector2i pos, uint* idx = null) inout pure nothrow {
        return this.getTileAt(Vector2f(pos), idx);
    }

    @nogc
    inout(Tile)* getTileAt()(auto ref const Vector2f pos, uint* idx = null) inout pure nothrow {
        foreach (uint index, ref inout Tile tile; _tiles) {
            if (tile.mask == 0)
                continue;
            
            if (tile.sprite.getPosition() == pos) {
                if (idx)
                    *idx = index;
                return &tile;
            }
        }

        return null;
    }
}