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
import nape.phys.Compound;
import nape.geom.GeomPoly;
import nape.shape.Edge;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.util.Debug;
import nape.util.BitmapDebug;
import nape.util.ShapeDebug;
import nape.constraint.PivotJoint;

import openfl.Lib;

typedef SoftBody = Compound;

class Battle extends Sprite
{
	public static inline var VEL_ITERATIONS:Int = 10;
  public static inline var POS_ITERATIONS:Int = 10;

	private var space:Space;
	private var prevTime:Int;
  private var softBodies:Array<SoftBody>;

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

    softBodies = [];

    var poly = new GeomPoly(Polygon.regular(30, 30, 20));
    var x = 0;
    var y = 5;
        var body = polygonalBody(
            Vec2.get(w/2 + x * 60, h - (y + 0.5) * 60),
            /*thickness*/ 10, /*discretisation*/ 15,
            /*frequency*/ 30, /*damping*/ 10,
            poly
        );
        softBodies.push(body);
        body.space = space;

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

  function polygonalBody(position:Vec2, thickness:Float, discretisation:Float, frequency:Float, damping:Float, poly:GeomPoly):SoftBody
  {
    var body = new SoftBody();

    var segments = [];
    var outerPoints = [];
    var innerPoints = [];
    var refEdges = [];
    body.userData.refEdges = refEdges;

    var inner = poly.inflate(-thickness);

    var start = poly.current();
    do 
    {
      var current = poly.current();
      poly.skipForward(1);
      var next = poly.current();

      var iCurrent = inner.current();
      inner.skipForward(1);
      var iNext = inner.current();

      var delta = next.sub(current);
      var iDelta = iNext.sub(iCurrent);

      var length = Math.max(delta.length, iDelta.length);
      var numSegments = Math.ceil(length / discretisation);
      var gap = (1 / numSegments);

      for (i in 0...numSegments)
      {
        var segment = new Body();

        var outerPoint = current.addMul(delta, gap * i);
        var innerPoint = iCurrent.addMul(iDelta, gap * i);
        var polygon = new Polygon([
            outerPoint,
            current.addMul(delta, gap * (i + 1), true),
            iCurrent.addMul(iDelta, gap * (i + 1), true),
            innerPoint
        ]);
        polygon.body = segment;
        segment.compound = body;
        segment.align();

        segments.push(segment);
        outerPoints.push(outerPoint);
        innerPoints.push(innerPoint);

        refEdges.push(polygon.edges.at(0));
      }

      delta.dispose();
      iDelta.dispose();
    }
    while (poly.current() != start);

    for (i in 0...segments.length)
    {
      var leftSegment = segments[(i - 1 + segments.length) % segments.length];
      var rightSegment = segments[i];

      var current = outerPoints[i];
      var pivot = new PivotJoint(
        leftSegment, rightSegment,
        leftSegment.worldPointToLocal(current, true),
        rightSegment.worldPointToLocal(current, true)
      );
      current.dispose();
      pivot.compound = body;

      current = innerPoints[i];
      pivot = new PivotJoint(
        leftSegment, rightSegment,
        leftSegment.worldPointToLocal(current, true),
        rightSegment.worldPointToLocal(current, true)
      );
      current.dispose();
      pivot.compound = body;
      pivot.stiff = false;
      pivot.frequency = frequency;
      pivot.damping = damping;

      pivot.ignore = true;
    }

    inner.clear();

    for (s in segments)
    {
      s.position.addeq(position);
    }

    body.userData.area = polygonalArea(body);

    return body;
  }

  static var areaPoly = new GeomPoly();
  static function polygonalArea(s:SoftBody):Float
  {
    var refEdges:Array<Edge> = s.userData.refEdges;
    for (edge in refEdges)
    {
        areaPoly.push(edge.worldVertex1);
    }
    var ret = areaPoly.area();
    areaPoly.clear();

    return ret;
  }
}