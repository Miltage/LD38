package;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.space.Space;

class Food 
{
	private var space:Space;

	public function new(x:Int, y:Int, space:Space)
	{
		this.space = space;

		var body = new Body(BodyType.DYNAMIC);
		body.shapes.add(new Circle(10));
		body.position.setxy(x, y);
		body.space = space;
		body.userData.item = this;
	}
}