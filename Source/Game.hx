package;

import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.MovieClip;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.AssetManager;
import starling.display.Image;
import starling.events.Event;

import openfl.display.Bitmap;
import openfl.Vector;

class Game extends Sprite
{
  public static var assets:AssetManager;

  public function new()
  {
    super();

    var quad:Quad = new Quad(200, 200, Color.RED);
    quad.x = 100;
    quad.y = 50;
    addChild(quad);
  }

  public function start(assets:AssetManager):Void
  {
    Game.assets = assets;

    trace("started");

    var image1:Image = new Image(Game.assets.getTexture("run"));
    image1.x = 0;
    image1.y = 0;
    addChild(image1);

    var frames:Vector<Texture> = Game.assets.getTextures("frame");
    var runner:MovieClip = new MovieClip(frames, 24);
    runner.x = 400;
    runner.y = 200;
    addChild(runner);
    Starling.current.juggler.add(runner);
  }
}