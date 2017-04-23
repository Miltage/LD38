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
import starling.events.Event;

import openfl.display.Bitmap;
import openfl.geom.Point;
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

  private var betBox1:Quad;
  private var betBox2:Quad;
  private var betBox3:Quad;

  private var chips:Array<Chip>;
  private var chips1:Array<Chip>;
  private var chips2:Array<Chip>;
  private var chips3:Array<Chip>;

  public function new()
  {
    super();
  }

  public function start(assets:AssetManager):Void
  {
    Game.assets = assets;

    var bg:Quad = new Quad(stage.stageWidth, stage.stageHeight, 0xECF0F1);
    addChild(bg);

    player = new Player();
    opponent1 = new Player();
    opponent2 = new Player();

    var battle:Battle = new Battle();
    addChild(battle);
    battle.addEventListener("end", onBattleEnd);

    overlay = new Canvas();
    addChild(overlay);
    drawOverlay();

    startButton = new Button(Game.assets.getTexture("button_idle.png"), "Start", Game.assets.getTexture("button_down.png"), Game.assets.getTexture("button_hover.png"));
    addChild(startButton);
    startButton.fontSize = 24;
    startButton.x = Constants.CenterX - startButton.width/2;

    startButton.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent)
    {
      if (event.getTouch(startButton, TouchPhase.BEGAN) != null)
      {
        if (!playerHasBet())
          return;

        battle.begin();
        startButton.visible = false;
        for (chip in chips)
          chip.setDraggable(false);
      }
    });

    chips = [];
    chips1 = [];
    chips2 = [];
    chips3 = [];
    
    addChips();
    updateAmounts();

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

  private function onBattleEnd(e:Event):Void
  {
    var winner = e.data[0];
    var winningChips = [];
    switch(winner)
    {
      case 1 : winningChips = chips1.copy(); chips1 = [];
      case 2 : winningChips = chips2.copy(); chips2 = [];
      case 3 : winningChips = chips3.copy(); chips3 = [];
    }

    for (chip in winningChips)
    {
      var newChip = new Chip(chip.getValue(), chip.getOwner(), chip.getOwner() == player, placeBet);
      newChip.x = chip.x;
      newChip.y = chip.y;
      addChild(newChip);
      chip.moveTo(chip.x, 550);
      newChip.moveTo(chip.x + chip.width * (Math.random() > .5 ? -0.8 : 0.8), 550);
    }

    for (chip in chips1.concat(chips2).concat(chips3))
    {
      chip.discard();
      chips.remove(chip);
    }

    updateAmounts();
  }

  private function playerHasBet():Bool
  {
    for (chip in chips1.concat(chips2).concat(chips3))
      if (chip.getOwner() == player)
        return true;
    return false;
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

    betBox1 = new Quad(140, 140, Constants.getColor(1));
    betBox1.alpha = 0.8;
    betBox1.x = 15;
    betBox1.y = 190;
    addChild(betBox1);

    betBox2 = new Quad(140, 140, Constants.getColor(2));
    betBox2.alpha = 0.8;
    betBox2.x = 15;
    betBox2.y = 340;
    addChild(betBox2);

    betBox3 = new Quad(140, 140, Constants.getColor(3));
    betBox3.alpha = 0.8;
    betBox3.x = w - betBox3.width - 15;
    betBox3.y = 190;
    addChild(betBox3);
  }

  private function addChips():Void
  {
    for (i in 0...4)
    {
      var chip = new Chip(5, player, true, placeBet);
      chip.x = 100 + i * chip.width;
      chip.y = 550;
      addChild(chip);
      chips.push(chip);
    }

    for (i in 0...4)
    {
      var chip = new Chip(10, player, true, placeBet);
      chip.x = 300 + i * chip.width;
      chip.y = 550;
      addChild(chip);
      chips.push(chip);
    }

    for (i in 0...4)
    {
      var chip = new Chip(20, player, true, placeBet);
      chip.x = 500 + i * chip.width;
      chip.y = 550;
      addChild(chip);
      chips.push(chip);
    }
  }

  private function placeBet(chip:Chip):Bool
  {
    if(chips1.indexOf(chip) + chips2.indexOf(chip) + chips3.indexOf(chip) >= 0)
      return true;

    var chipPos = new Point(chip.x, chip.y);
    if (chipPos.x > betBox1.x && chipPos.x < betBox1.x + betBox1.width
      && chipPos.y > betBox1.y && chipPos.y < betBox1.y + betBox1.height)
    {
      chips1.push(chip);
      return true;
    }
    else if (chipPos.x > betBox2.x && chipPos.x < betBox2.x + betBox2.width
      && chipPos.y > betBox2.y && chipPos.y < betBox2.y + betBox2.height)
    {
      chips2.push(chip);
      return true;
    }
    else if (chipPos.x > betBox3.x && chipPos.x < betBox3.x + betBox3.width
      && chipPos.y > betBox3.y && chipPos.y < betBox3.y + betBox3.height)
    {
      chips3.push(chip);
      return true;
    }
    return false;
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