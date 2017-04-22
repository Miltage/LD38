package;

import haxe.Timer;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl.errors.Error;
import openfl.display.StageScaleMode;
import openfl.system.Capabilities;

import starling.core.Starling;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.textures.RenderTexture;
import starling.utils.Max;
import starling.utils.AssetManager;
import starling.utils.RectangleUtil;

class Main extends Sprite {
  
  private var starling:Starling;

  public function new () {
    
    super();
    if (stage != null) start();
    else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  private function onAddedToStage(event:Dynamic):Void
  {
    removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    stage.scaleMode = StageScaleMode.NO_SCALE;
    start();
  }

  private function start():Void
  {
    Starling.multitouchEnabled = true;
    Starling.handleLostContext = true;

    starling = new Starling(Game, stage);
    starling.stage.stageWidth = Constants.GameWidth;
    starling.stage.stageHeight = Constants.GameHeight;
    starling.showStats = true;
    starling.enableErrorChecking = Capabilities.isDebugger;
    starling.addEventListener(Event.ROOT_CREATED, function()
    {
      loadAssets(startGame);
    });

    this.stage.addEventListener(Event.RESIZE, onResize, false, Max.INT_MAX_VALUE, true);
    starling.start();
  }

  private function loadAssets(onComplete:AssetManager->Void):Void
  {
    var assets:AssetManager = new AssetManager();
    assets.verbose = Capabilities.isDebugger;
    RenderTexture.optimizePersistentBuffers = true;

    Timer.delay(function()
    {
      assets.addTexture("run", Texture.fromBitmapData(Assets.getBitmapData("assets/run.png")));
      var runTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/sprites.png"));
      var runAtlas:Xml = Xml.parse(Assets.getText("assets/sprites.xml")).firstElement();
      assets.addTextureAtlas("run", new TextureAtlas(runTexture, runAtlas));

      onComplete(assets);
    }, 0);
  }

  private function startGame(assets:AssetManager):Void
  {
    var game:Game = cast(starling.root, Game);
    game.start(assets);
  }

  private function onResize(e:Event):Void
  {
    var viewPort:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, Constants.GameWidth, Constants.GameHeight), new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));
    try
    {
        this.starling.viewPort = viewPort;
    }
    catch(error:Error) {}
  }
  
  
}