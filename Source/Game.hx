package;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Canvas;
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.MovieClip;
import starling.textures.Texture;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.utils.Color;
import starling.utils.AssetManager;
import starling.display.Image;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.geom.Polygon;

import openfl.display.Bitmap;
import openfl.Vector;

class Game extends Sprite
{
  public static var assets:AssetManager;

  private var startButton:Button;
  private var overlay:Canvas;

  private var player:Player;
  private var opponent1:Player;
  private var opponent2:Player;

  private var playerCash:TextField;
  private var opponent1Cash:TextField;
  private var opponent2Cash:TextField;

  public function new()
  {
    super();
  }

  public function start(assets:AssetManager):Void
  {
    Game.assets = assets;

    player = new Player();
    opponent1 = new Player();
    opponent2 = new Player();

    var battle:Battle = new Battle();
    addChild(battle);

    overlay = new Canvas();
    addChild(overlay);
    drawOverlay();
    updateAmounts();

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

  private function drawOverlay():Void
  {
    var w = stage.stageWidth;
    var h = stage.stageHeight;

    overlay.beginFill(0x000000, 0.4);
    overlay.drawRectangle(0, h - 100, w, 100);

    overlay.drawPolygon(new Polygon([0, 180, 0, 0, 180, 0]));
    overlay.drawPolygon(new Polygon([w, 180, w, 0, w - 180, 0]));

    playerCash = new TextField(0, 0, "0", "Arial", 30, Color.WHITE);
    playerCash.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
    playerCash.y = h - 50 - playerCash.height / 2;
    addChild(playerCash);

    opponent1Cash = new TextField(0, 0, "0", "Arial", 30, Color.WHITE);
    opponent1Cash.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
    opponent1Cash.y = 10;
    addChild(opponent1Cash);

    opponent2Cash = new TextField(0, 0, "0", "Arial", 30, Color.WHITE);
    opponent2Cash.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
    opponent2Cash.y = 10;
    addChild(opponent2Cash);
  }

  private function updateAmounts():Void
  {
    var w = stage.stageWidth;
    var h = stage.stageHeight;

    playerCash.text = "$" + player.getMoney();
    playerCash.x = w - playerCash.width - 10;

    opponent1Cash.text = "$" + opponent1.getMoney();
    opponent1Cash.x = 10;

    opponent2Cash.text = "$" + opponent2.getMoney();
    opponent2Cash.x = w - opponent2Cash.width - 10;
  }
}