package;
class Constants
{
  public static var GameWidth:Int  = 800;
  public static var GameHeight:Int = 600;
  
  public static var CenterX:Int = Std.int(GameWidth / 2);
  public static var CenterY:Int = Std.int(GameHeight / 2);

  public static function getColor(t:Int):UInt
  {
  	return switch(t)
    {
      case 1 : 0x33CCCC;
      case 2 : 0x2980B9;
      case 3 : 0x2C3E50;
      case _ : 0x000000;
    }
  }
}