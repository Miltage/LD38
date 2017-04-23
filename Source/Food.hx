package;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.space.Space;

class Food 
{
  private var space:Space;
  private var body:Body;

  public function new(x:Int, y:Int, space:Space)
  {
    this.space = space;

    body = new Body(BodyType.DYNAMIC);
    body.shapes.add(new Circle(10));
    body.position.setxy(x, y);
    body.space = space;
    body.userData.item = this;
  }

  public function moveRandomly():Void
  {
    body.applyImpulse(Vec2.weak(Math.random() - 0.5, Math.random() - 0.5).mul(10));
  }

  public function getPosition():Vec2
  {
    return body.position;
  }
}