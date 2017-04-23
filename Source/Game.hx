package;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.MovieClip;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.AssetManager;
import starling.display.Image;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import openfl.display.Bitmap;
import openfl.Vector;

class Game extends Sprite
{
  public static var assets:AssetManager;

  private var startButton:Button;

  public function new()
  {
    super();
  }

  public function start(assets:AssetManager):Void
  {
    Game.assets = assets;

    var battle:Battle = new Battle();
    addChild(battle);

    startButton = new Button(Game.assets.getTexture("button_idle.png"), "Start", Game.assets.getTexture("button_down.png"), Game.assets.getTexture("button_hover.png"));
    addChild(startButton);
    startButton.fontSize = 24;
    startButton.x = Constants.CenterX - startButton.width/2;

    startButton.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent)
    {
      if (event.getTouch(startButton, TouchPhase.BEGAN) != null)
      {
        battle.begin();
        startButton.visible = false;
      }
    });

    /*var image1:Image = new Image(Game.assets.getTexture("run"));
    image1.x = 0;
    image1.y = 0;
    addChild(image1);

    var frames:Vector<Texture> = Game.assets.getTextures("frame");
    var runner:MovieClip = new MovieClip(frames, 24);
    runner.x = 400;
    runner.y = 200;
    addChild(runner);
    Starling.current.juggler.add(runner);*/
  }
}