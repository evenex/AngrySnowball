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

private:

enum ubyte MAP_WIDTH = 20;
enum ubyte MAP_HEIGHT = 15;

immutable Vector2f[1] StartPositions = [
    Vector2f(2 * TILE_SIZE, 1 * TILE_SIZE)
];

ref T reinitialize(T, Args...)(ref T obj, auto ref Args args) if (is(T == class)) {
    if (obj is null)
        throw new Exception("Object is null and cannot be reinitialized");

    static if (__traits(hasMember, obj, "__dtor"))
        obj.__dtor();

    void* addr = cast(void*) obj;
    enum ClassSize = __traits(classInstanceSize, T);
    addr[0 .. ClassSize] = obj.classinfo.init[];

    static if (__traits(hasMember, obj, "__ctor"))
         obj.__ctor(args);
    else
        static assert(args.length == 0, "No CTor to initialize object with arguments");

    return obj;
}

public:

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
        ++_number;
        return this.load(sprite);
    }

    bool load(Sprite sprite) {
        import std.file : read, exists;
        import std.string : format, split, strip;
        import std.conv : to;
        import arsd.dom : Document;

        if (_tileTex.width == 0)
            _tileTex = Texture(Surface(TilesetFile));

        immutable string level_file = format(LevelFile, _number);
        if (!exists(level_file))
            return false;

        auto document = new Document(cast(string) read(level_file), true, true);
        auto data = document.requireSelector("data");

        immutable size_t len = _tiles.length;
        if (_tiles.length != 0) {
            _tiles.length = 0;
            _tiles.assumeSafeAppend();
        }

        ubyte x, y;
        size_t index = 0;
        foreach (string s; data.innerHTML.split(',')) {
            immutable ubyte id = to!(ubyte)(s.strip);
            if (id > 0 && id < 255) {
                const Vector2f pos = Vector2f(x * TILE_SIZE, y * TILE_SIZE);

                Sprite tile_sprite;
                if (index < len)
                    tile_sprite = _tiles.ptr[index].sprite.reinitialize(_tileTex, pos);
                else 
                    tile_sprite = new Sprite(_tileTex, pos);

                _tiles ~= Tile(tile_sprite, cast(ubyte)(id - 1));

                index++;
            }

            x++;
            if (x >= MAP_WIDTH) {
                x = 0;
                y++;
            }
        }
        
        sprite.setRotation(0);
        sprite.setPosition(StartPositions[_number - 1]);

        return true;
    }

    @nogc
    bool reset(Sprite sprite) {
        foreach (ref Tile tile; _tiles) {
            tile.reset();
        }

        sprite.setRotation(0);
        sprite.setPosition(StartPositions[_number - 1]);

        return true;
    }

    @nogc
    void renderOn(ref const Window wnd) {
        foreach (ref Tile tile; _tiles) {
            if (tile.mask == 0)
                continue;
            wnd.draw(tile.sprite);
        }
    }

    @nogc
    inout(Tile)* getTileAt()(auto ref const Vector2i pos) inout pure nothrow {
        return this.getTileAt(Vector2f(pos), idx);
    }

    @nogc
    inout(Tile)* getTileAt()(auto ref const Vector2f pos) inout pure nothrow {
        foreach (uint index, ref inout Tile tile; _tiles) {
            if (tile.mask == 0)
                continue;
            if (tile.sprite.getPosition() == pos)
                return &tile;
        }

        return null;
    }
}