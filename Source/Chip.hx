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

  public function new(value:Int, draggable:Bool=false)
  {
    super();

    this.value = value;
    this.draggable = draggable;
    dragging = false;

    var image1:Image = new Image(Game.assets.getTexture("chip_" + value));
    image1.x = 0;
    image1.y = 0;
    image1.scaleX = image1.scaleY = .5;
    addChild(image1);

    addEventListener(TouchEvent.TOUCH, function(event:TouchEvent)
    {
      if (event.getTouch(this, TouchPhase.BEGAN) != null)
      {
        dragging = draggable;
        this.parent.setChildIndex(this, this.parent.numChildren - 1);
      }
      else if (dragging)
      {
        var touched = event.getTouch(this, TouchPhase.MOVED);
        if (touched != null)
        {
          var p = touched.getLocation(stage);
          x = p.x - width/2;
          y = p.y - height/2;
        }
        else
        {
          dragging = false;
          if (y < stage.stageHeight - 100)
          {
            draggable = false;
            var tween:Tween = new Tween(this, 1, Transitions.EASE_OUT);
            tween.animate("y", 525);
            tween.onComplete = function() draggable = true;
            Starling.current.juggler.add(tween);
          }
        }
      }
    });
  }

  public function getValue():Int
  {
    return value;
  } 
}