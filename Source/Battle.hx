package;

import starling.display.Quad;
import starling.utils.Color;
import starling.events.Event;
import starling.display.Sprite;

import nape.space.Space;
import nape.space.Broadphase;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.util.Debug;
import nape.util.BitmapDebug;
import nape.util.ShapeDebug;
import nape.constraint.PivotJoint;

import openfl.Lib;

class Battle extends Sprite
{
	public static inline var VEL_ITERATIONS:Int = 10;
  public static inline var POS_ITERATIONS:Int = 10;

	private var space:Space;
	private var prevTime:Int;

	public function new()
  {
    super();

    addEventListener(Event.ADDED_TO_STAGE, start);
  }

  private function start(e:Event):Void
  {
  	removeEventListener(Event.ADDED_TO_STAGE, start);

  	var gravity = Vec2.weak(0, 600);
    space = new Space(gravity);

    prevTime = Lib.getTimer();

    var w = stage.stageWidth;
    var h = stage.stageHeight;

    var floor = new Body(BodyType.STATIC);
    floor.shapes.add(new Polygon(Polygon.rect(50, (h - 50), (w - 100), 1)));
    floor.space = space;

    for (i in 0...16)
    {
      var box = new Body(BodyType.DYNAMIC);
      box.shapes.add(new Polygon(Polygon.box(16, 32)));
      box.position.setxy((w / 2), ((h - 50) - 32 * (i + 0.5)));
      box.space = space;
    }

    addEventListener(Event.ENTER_FRAME, onEnterFrame);
  }

  private function preStep(deltaTime:Float):Void
  {

  }

  private function postUpdate(deltaTime:Float)
  {

  }

  private function onEnterFrame():Void
  {
    var curTime = Lib.getTimer();
    var deltaTime:Float = (curTime - prevTime);
    if (deltaTime == 0)
      return;

    

    var noStepsNeeded = false;

    //if (variableStep) {
      if (deltaTime > (1000 / 30)) {
          deltaTime = (1000 / 30);
      }

      Main.debug.clear();

      preStep(deltaTime * 0.001);
      if (space != null) {
          space.step(deltaTime * 0.001, VEL_ITERATIONS, POS_ITERATIONS);
      }
      prevTime = curTime;
    /*}
    else {
        var stepSize = (1000 / stage.frameRate);
        stepSize = 1000/60;
        var steps = Math.round(deltaTime / stepSize);

        var delta = Math.round(deltaTime - (steps * stepSize));
        prevTime = (curTime - delta);
        if (steps > 4) {
            steps = 4;
        }
        deltaTime = stepSize * steps;

        if (steps == 0) {
            noStepsNeeded = true;
        }
        else {
            debug.clear();
        }

        while (steps-- > 0) {
            preStep(stepSize * 0.001);
            if (space != null) {
                space.step(stepSize * 0.001, velIterations, posIterations);
            }
        }
    }*/

    if (space != null && !noStepsNeeded) {
      Main.debug.draw(space);
    }
    if (!noStepsNeeded) {
      postUpdate(deltaTime * 0.001);
      Main.debug.flush();
    }
  }
}