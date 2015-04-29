import Dgame.Graphic;
import Dgame.Window;
import Dgame.Math.Rect;
import Dgame.System.Font;
import Dgame.System.StopWatch;
import Dgame.System.Keyboard;

import AngrySnowball.Actor;
import AngrySnowball.LevelMap;

import AngrySnowball.State.State;

enum ubyte MAX_FPS = 60;
enum ubyte TICKS_PER_FRAME = 1000 / MAX_FPS;

void main() {
    Window wnd = Window(640, 480, "Dgame Test");
    wnd.setClearColor(Color4b(230, 230, 230));

    Texture player_tex = Texture(Surface("stuff/images/snowball-spritesheet.png"));
    Spritesheet player = new Spritesheet(player_tex, Rect(0, 0, 32, 32));
    player.setCenter(16, 16);

    Actor actor = Actor(player);

    LevelMap lvlMap;
    lvlMap.loadNext(actor.sprite);

    Font fnt = Font("stuff/font/arial.ttf", 12);
    Text fps = new Text(fnt);
    fps.setPosition(wnd.getSize().width - 96, 4);
    fps.foreground = Color4b.White;
    fps.mode = Font.Mode.Blended;

    StopWatch sw, sw_fps;

    bool running = true;

    Event event;
    while (running) {
        wnd.clear();

        fps.format("FPS: %d", sw_fps.getCurrentFPS());

        if (sw.getElapsedTicks() > TICKS_PER_FRAME) {
            sw.reset();
            
            while (wnd.poll(&event)) {
                if (event.type == Event.Type.Quit)
                    running = false;
                else if (event.type == Event.Type.KeyDown && 
                         event.keyboard.key == Keyboard.Key.Esc)
                {
                    running = false;
                }
                else
                    actor.handleEvent(event);
            }

            actor.execute(lvlMap);
        }

        lvlMap.renderOn(wnd);
        wnd.draw(actor.sprite);
        wnd.draw(fps);

        wnd.display();
    }
}