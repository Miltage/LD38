package;

class Player
{
	private var money:Int;
	private var chips:Array<Chip>;

	public function new()
	{
		chips = [];
	}

	public function getTotalChips():Int
	{
		return chips.length;
	}

	public function addChip(chip:Chip):Void
	{
		chips.push(chip);
	}

	public function removeChip(chip:Chip):Void
	{
		chips.remove(chip);
	}

	public function getMoney():Int
	{
		var money = 0;
		for (chip in chips)
		{
			money += chip.getValue();
		}
		return money;
	}
}