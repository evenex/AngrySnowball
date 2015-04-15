module AngrySnowball.LevelMap;

import Dgame.Graphic.Sprite;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Surface;
import Dgame.Window.Window;
import Dgame.Math.Vector2;
import Dgame.Math.Rect;

import AngrySnowball.Actor;
import AngrySnowball.Tile;

immutable string Tileset = "stuff/images/Tileset.png";
immutable string LevelFmt = "stuff/map/Level_%d.tmx";
immutable string StartTag = "<data encoding=\"csv\">";
immutable string EndTag = "</data>";

enum ubyte TILE_SIZE = 32;
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

    bool load(ubyte lvlNr, Sprite sprite) {
        import std.file : read, exists;
        import std.string : indexOf, removechars, format, split;
        import std.conv : to;

        if (_tileTex.width == 0)
            _tileTex = Texture(Surface(Tileset));

        _number = lvlNr;

        immutable string level_file = format(LevelFmt, _number);
        if (!exists(level_file))
            return false;

        immutable string content = cast(string) read(level_file);
        immutable int idx1 = content.indexOf(StartTag);
        immutable int idx2 = content.indexOf(EndTag);

        immutable string map = content[idx1 + StartTag.length .. idx2].removechars("\n");

        if (_tiles.length != 0) {
            _tiles.length = 0;
            _tiles.assumeSafeAppend();
        }

        ubyte x, y;
        Rect rect = Rect(0, 0, TILE_SIZE, TILE_SIZE);
        import std.stdio : writeln;
        foreach (string s; map.split(',')) {
            immutable int id = to!(int)(s);
            if (id > 0 && id < 255) {
                rect.x = (id - 1) * TILE_SIZE;

                Sprite tile_sprite = new Sprite(_tileTex, Vector2f(x * TILE_SIZE, y * TILE_SIZE));
                tile_sprite.setTextureRect(rect);

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
            wnd.draw(tile.sprite);
        }
    }

    @nogc
    inout(Tile)* getTileAt()(auto ref const Vector2i pos) inout pure nothrow {
        return this.getTileAt(Vector2f(pos));
    }

    @nogc
    inout(Tile)* getTileAt()(auto ref const Vector2f pos) inout pure nothrow {
        foreach (ref inout Tile tile; _tiles) {
            if (tile.sprite.getPosition() == pos)
                return &tile;
        }

        return null;
    }
}