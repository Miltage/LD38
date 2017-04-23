package;

import starling.display.Sprite;
import starling.display.Image;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class Chip extends Sprite
{
  private var value:Int;
  private var dragging:Bool;

  public function new(value:Int)
  {
    super();

    this.value = value;
    dragging = false;

    var image1:Image = new Image(Game.assets.getTexture("chip"));
    image1.x = 0;
    image1.y = 0;
    image1.scaleX = image1.scaleY = .5;
    addChild(image1);

    addEventListener(TouchEvent.TOUCH, function(event:TouchEvent)
    {
      if (event.getTouch(this, TouchPhase.BEGAN) != null)
      {
        dragging = true;
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
          dragging = false;
      }
    });
  }

  public function getValue():Int
  {
    return value;
  } 
}