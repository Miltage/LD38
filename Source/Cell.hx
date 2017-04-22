package;

import nape.phys.Body;
import nape.phys.Compound;
import nape.geom.GeomPoly;
import nape.geom.Vec2;
import nape.shape.Edge;
import nape.shape.Polygon;
import nape.space.Space;
import nape.constraint.PivotJoint;

typedef SoftBody = Compound;

class Cell
{

	private var size:Int;
	private var team:Int;
	private var compound:Compound;
	
	public function new(x:Int, y:Int, size:Int, team:Int, space:Space)
	{
		this.size = size;
		this.team = team;

		var poly = new GeomPoly(Polygon.regular(size, size, Math.round(size/2)));
    compound = polygonalBody(Vec2.get(x, y), 10,  15, 30,  10, poly);
    compound.space = space;
	}

	public function moveToward(x:Float, y:Float):Void
	{
		var m = Vec2.get(x, y);
		for (body in compound.bodies)
		{
			var d = m.sub(body.position);
			var len = Vec2.distance(body.position, m) * 10;
			body.applyImpulse(Vec2.weak(d.x/len, d.y/len));
		}
	}

	private function polygonalBody(position:Vec2, thickness:Float, discretisation:Float, frequency:Float, damping:Float, poly:GeomPoly):SoftBody
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