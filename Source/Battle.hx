package;

import nape.callbacks.CbType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import starling.display.Canvas;
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
import nape.callbacks.PreListener;
import nape.callbacks.InteractionType;

import openfl.Lib;
import openfl.geom.Point;

class Battle extends Sprite
{
	public static inline var VEL_ITERATIONS:Int = 10;
  public static inline var POS_ITERATIONS:Int = 10;
  public static inline var MIN_DISTANCE:Int = 100;

	private var space:Space;
	private var prevTime:Int;
  private var cells:Array<Cell>;
  private var food:Array<Food>;
  private var dirt:Array<Dirt>;

  private var canvas:Canvas;
  private var started:Bool;

	public function new()
  {
    super();

    started = false;

    addEventListener(Event.ADDED_TO_STAGE, start);
  }

  public function begin():Void
  {
    started = true;
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
    floor.shapes.add(new Polygon(Polygon.rect(50, 50, (w - 100), 1)));
    floor.shapes.add(new Polygon(Polygon.rect(50, 50, 1, (h - 100))));
    floor.shapes.add(new Polygon(Polygon.rect((w - 50), 50, 1, (h - 100))));
    floor.space = space;

    cells = [];
    food = [];
    dirt = [];

    var cx;
    var cy;

    for (i in 0...Math.ceil(Math.random() * 3))
    {
      do {
        cx = Math.round(Constants.CenterX - Math.random() * w/2 + w/4);
        cy = Math.round(Constants.CenterY - Math.random() * h/2 + h/4);
      } while (distanceToCell(getClosestCell(cx, cy), cx, cy) < MIN_DISTANCE);
      var cell:Cell = new Cell(cx, cy, 20 + Math.round(Math.random() * 20), 1, space);
      cells.push(cell);
    }

    for (i in 0...Math.ceil(Math.random() * 3))
    {
      do {
        cx = Math.round(Constants.CenterX - Math.random() * w/2 + w/4);
        cy = Math.round(Constants.CenterY - Math.random() * h/2 + h/4);
      } while (distanceToCell(getClosestCell(cx, cy), cx, cy) < MIN_DISTANCE);
      var cell:Cell = new Cell(cx, cy, 20 + Math.round(Math.random() * 20), 2, space);
      cells.push(cell);
    }

    for (i in 0...Math.ceil(Math.random() * 3))
    {
      do {
        cx = Math.round(Constants.CenterX - Math.random() * w/2 + w/4);
        cy = Math.round(Constants.CenterY - Math.random() * h/2 + h/4);
      } while (distanceToCell(getClosestCell(cx, cy), cx, cy) < MIN_DISTANCE);
      var cell:Cell = new Cell(cx, cy, 20 + Math.round(Math.random() * 20), 3, space);
      cells.push(cell);
    }

    for (i in 0...10)
    {
      do {
        cx = Math.round(Constants.CenterX - Math.random() * w/2 + w/4);
        cy = Math.round(Constants.CenterY - Math.random() * h/2 + h/4);
      } while (!farEnough(getClosestCell(cx, cy), cx, cy, MIN_DISTANCE/2));
      var f:Food = new Food(cx, cy, space);
      food.push(f);
    }

    for (i in 0...100)
    {
      do {
        cx = Math.round(Constants.CenterX - Math.random() * w + w/2);
        cy = Math.round(Constants.CenterY - Math.random() * h + h/2);
      } while (!farEnough(getClosestCell(cx, cy), cx, cy, MIN_DISTANCE/4));
      var d:Dirt = new Dirt(cx, cy, space);
      dirt.push(d);
    }

    addEventListener(Event.ENTER_FRAME, onEnterFrame);
    addEventListener(TouchEvent.TOUCH, onTouch);

    var touchQuad:Quad = new Quad(w, h);
    touchQuad.alpha = 0; // only used to get touch events
    addChildAt(touchQuad, 0);

    canvas = new Canvas();
    //canvas.filter = new starling.filters.BlurFilter();
    addChild(canvas);

    space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_COMPOUND, CbType.ANY_COMPOUND, handleCollision));
    space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_COMPOUND, CbType.ANY_BODY, handleItemCollision));
  }

  private function handleCollision(cb:InteractionCallback):Void
  {
    if (Std.is(cb.int1.castCompound, Cell.SoftBody) && Std.is(cb.int2.castCompound, Cell.SoftBody))
    {
      var cell1:Cell = cb.int1.castCompound.userData.cell;
      var cell2:Cell = cb.int2.castCompound.userData.cell;
      if (cell1 == null || cell2 == null)
        return;

      if (cell1.getSize() > cell2.getSize())
      {
        cell1.grow();
        cell2.shrink();
      }
      else
      {
        cell1.shrink();
        cell2.grow();
      }

      var p1 = cell1.getPosition().sub(cell2.getPosition());
      var p2 = cell2.getPosition().sub(cell1.getPosition());
      cell1.push(p1.x * 0.5 / cell1.getSize(), p1.y * 0.5 / cell1.getSize());
      cell2.push(p2.x * 0.5 / cell2.getSize(), p2.y * 0.5 / cell2.getSize());
    }
  }

  private function handleItemCollision(cb:InteractionCallback):Void
  {
    if (Std.is(cb.int1.castCompound, Cell.SoftBody) && Std.is(cb.int2.castBody.userData.item, Food))
    {
      cb.int1.castCompound.userData.cell.grow();
      cb.int2.castBody.space = null;
      food.remove(cast(cb.int2.castBody.userData.item, Food));
    }
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
    
    if (!started)
      return;

    var remainingTeams = calcTeamsLeft();
    if (remainingTeams.length == 1)
    {
      dispatchEvent(new Event("end", true, remainingTeams));
      started = false;
    }

    for (cell in cells)
    {
      var target = getClosestEnemy(cell);
      if (target != null && (target.getSize() < cell.getSize() || food.length == 0))
      {
        var p = target.getPosition();
        cell.moveToward(p.x, p.y);
      }
      else
      {
        var food = getClosestFood(cell);
        if (food != null)
        {
          var p = food.getPosition();
          cell.moveToward(p.x, p.y);
        }
      }
    }

    for (f in food)
    {
      f.moveRandomly();
    }
  }

  private function postUpdate(deltaTime:Float)
  {

  }

  private function calcNumAlive():Int
  {
    var num = 0;
    for (c in cells)
      if (c.isAlive())
        num++;
    return num;
  }

  private function calcTeamsLeft():Array<Int>
  {
    var teams = [];
    for (c in cells)
      if (c.isAlive())
        if (teams.indexOf(c.getTeam()) < 0)
          teams.push(c.getTeam());
    return teams;
  }

  private function distanceToCell(cell:Cell, x:Int, y:Int):Float
  {
    if (cell == null)
      return MIN_DISTANCE;
    return Vec2.distance(cell.getPosition(), Vec2.weak(x, y));
  }

  private function farEnough(cell:Cell, x:Int, y:Int, dist:Float):Bool
  {
    return distanceToCell(cell, x, y) - cell.getSize() >= dist;
  }

  private function getClosestCell(x:Int, y:Int):Cell
  {
    var p = Vec2.get(x, y);
    var result = null;
    var d = Max.INT_MAX_VALUE;
    for (c in cells)
    {
      var dist = Vec2.distance(p, c.getPosition());
      if (dist < d)
      {
        result = c;
        d = Math.round(dist);
      }
    }
    return result;
  }

  private function getClosestEnemy(cell:Cell):Cell
  {
    var result = null;
    var d = Max.INT_MAX_VALUE;
    for (c in cells)
    {
      if (c != cell && c.getTeam() != cell.getTeam() && c.isAlive())
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

  private function getClosestFood(cell:Cell):Food
  {
    var result = null;
    var d = Max.INT_MAX_VALUE;
    for (f in food)
    {
      var dist = Vec2.distance(f.getPosition(), cell.getPosition());
      if (dist < d)
      {
        result = f;
        d = Math.round(dist);
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
      //Main.debug.draw(space);
    }
    if (!noStepsNeeded)
    {
      postUpdate(deltaTime * 0.001);
      Main.debug.flush();
    }

    canvas.clear();
    for (cell in cells)
    {
      if (!cell.isAlive()) continue;

      canvas.beginFill(Constants.getColor(cell.getTeam()));
      canvas.drawPolygon(cell.getDisplayPolygon());
      canvas.endFill();
    }

    for (f in food)
    {
      canvas.beginFill(0xABCB89);
      var p = f.getPosition();
      canvas.drawCircle(p.x, p.y, 10);
      canvas.endFill();
    }

    for (d in dirt)
    {
      canvas.beginFill(0x000000, 0.5);
      var p = d.getPosition();
      canvas.drawCircle(p.x, p.y, 4);
      canvas.endFill();
    }
  }
}