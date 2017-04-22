package;

import starling.display.Quad;
import starling.utils.Color;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Max;

import nape.space.Space;
import nape.space.Broadphase;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.geom.GeomPoly;
import nape.shape.Edge;
import nape.shape.Polygon;
import nape.geom.Vec2;

import openfl.Lib;
import openfl.geom.Point;

class Battle extends Sprite
{
	public static inline var VEL_ITERATIONS:Int = 10;
  public static inline var POS_ITERATIONS:Int = 10;

	private var space:Space;
	private var prevTime:Int;
  private var cells:Array<Cell>;

	public function new()
  {
    super();

    addEventListener(Event.ADDED_TO_STAGE, start);
  }

  private function start(e:Event):Void
  {
  	removeEventListener(Event.ADDED_TO_STAGE, start);

  	var gravity = Vec2.weak(0, 0);
    space = new Space(gravity);

    prevTime = Lib.getTimer();

    var w = stage.stageWidth;
    var h = stage.stageHeight;

    var floor = new Body(BodyType.STATIC);
    floor.shapes.add(new Polygon(Polygon.rect(50, (h - 50), (w - 100), 1)));
    floor.space = space;

    cells = [];

    for (i in 0...5)
    {
      var cell:Cell = new Cell(Math.round(Math.random() * w), Math.round(Math.random() * h)
        , 20 + Math.round(Math.random() * 10), Math.random() > .5 ? 1 : 2, space);
      cells.push(cell);
    }

    addEventListener(Event.ENTER_FRAME, onEnterFrame);
    addEventListener(TouchEvent.TOUCH, onTouch);

    var touchQuad:Quad = new Quad(w, h);
    touchQuad.alpha = 0; // only used to get touch events
    addChildAt(touchQuad, 0);
  }

  private function onTouch(event:TouchEvent):Void
  {
    var touch:Touch = event.getTouch(this, TouchPhase.HOVER);
    if (touch == null) touch = event.getTouch(this, TouchPhase.BEGAN);
    if (touch == null) touch = event.getTouch(this, TouchPhase.MOVED);

    if (touch != null)
    {
      var localPos:Point = touch.getLocation(this);
      //cells[0].moveToward(localPos.x, localPos.y);
    }
  }

  private function preStep(deltaTime:Float):Void
  {
    for (body in space.liveBodies)
    {
      body.velocity.x *= 0.95;
      body.velocity.y *= 0.95;
    }

    for (cell in cells)
    {
      var target = getClosestEnemy(cell);
      if (target != null)
      {
        var p = target.getPosition();
        cell.moveToward(p.x, p.y);
      }
    }
  }

  private function postUpdate(deltaTime:Float)
  {

  }

  private function getClosestEnemy(cell:Cell):Cell
  {
    var result = null;
    var d = Max.INT_MAX_VALUE;
    for (c in cells)
    {
      if (c != cell && c.getTeam() != cell.getTeam())
      {
        var dist = Vec2.distance(c.getPosition(), cell.getPosition());
        if (dist < d)
        {
          result = c;
          d = Math.round(dist);
        }
      }
    }
    return result;
  }

  private function onEnterFrame():Void
  {
    var curTime = Lib.getTimer();
    var deltaTime:Float = (curTime - prevTime);
    if (deltaTime == 0)
      return;

    var noStepsNeeded = false;

    if (deltaTime > (1000 / 30))
    {
      deltaTime = (1000 / 30);
    }

    Main.debug.clear();

    preStep(deltaTime * 0.001);
    if (space != null)
    {
      space.step(deltaTime * 0.001, VEL_ITERATIONS, POS_ITERATIONS);
    }
    prevTime = curTime;

    if (space != null && !noStepsNeeded)
    {
      Main.debug.draw(space);
    }
    if (!noStepsNeeded)
    {
      postUpdate(deltaTime * 0.001);
      Main.debug.flush();
    }
  }
}