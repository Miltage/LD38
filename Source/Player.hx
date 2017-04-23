package;

class Player
{
	private var money:Int;

	public function new()
	{
		money = 100;
	}

	public function getMoney():Int
	{
		return money;
	}

	public function addMoney(d:Int):Void
	{
		money += d;
		if (money < 0)
			money = 0;
	}
}