package;

import starling.core.Starling;
import starling.display.Sprite;
import starling.display.Image;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.animation.Tween;
import starling.animation.Transitions;

class Chip extends Sprite
{
  private var value:Int;
  private var dragging:Bool;
  private var draggable:Bool;
  private var owner:Player;

  public function new(value:Int, owner:Player, draggable:Bool=false, place:Chip->Bool)
  {
    super();

    this.value = value;
    this.draggable = draggable;
    this.owner = owner;
    dragging = false;
    owner.addChip(this);

    var image1:Image = new Image(Game.assets.getTexture("chip_" + value));
    image1.scaleX = image1.scaleY = .5;
    image1.x = -image1.width/2;
    image1.y = -image1.height/2;
    addChild(image1);

    addEventListener(TouchEvent.TOUCH, function(event:TouchEvent)
    {
      if (event.getTouch(this, TouchPhase.BEGAN) != null && draggable)
      {
        trace(draggable);
        dragging = draggable;
        this.parent.setChildIndex(this, this.parent.numChildren - 1);
      }
      else if (dragging)
      {
        var touched = event.getTouch(this, TouchPhase.MOVED);
        if (touched != null && draggable)
        {
          var p = touched.getLocation(stage);
          x = p.x;
          y = p.y;
        }
        else
        {
          dragging = false;
          if (y < stage.stageHeight - 100 && !place(this))
          {
            moveTo(x, 550);
          }
        }
      }
    });
  }

  public function moveTo(x:Float, y:Float)
  {
    trace("moveTo");
    draggable = false;
    var tween:Tween = new Tween(this, 1, Transitions.EASE_OUT);
    tween.animate("x", x);
    tween.animate("y", y);
    tween.onComplete = function() draggable = true;
    Starling.current.juggler.add(tween);
  }

  public function discard()
  {
    draggable = false;
    owner.removeChip(this);
    var tween:Tween = new Tween(this, 1, Transitions.EASE_OUT);
    tween.animate("scaleX", 0);
    tween.animate("scaleY", 0);
    //tween.onComplete = function() parent.removeChild(this);
    Starling.current.juggler.add(tween);
  }

  public function getOwner():Player
  {
    return owner;
  }

  public function setOwner(player:Player):Void
  {
    this.owner = player;
  }

  public function getValue():Int
  {
    return value;
  }

  public function setDraggable(draggable:Bool):Void
  {
    this.draggable = draggable;
    trace(draggable + " - " + this.draggable);
  }
}