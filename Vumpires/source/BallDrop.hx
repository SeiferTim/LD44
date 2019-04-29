package;

import flixel.FlxSprite;

class BallDrop extends FlxSprite 
{

	public function new() 
	{
		super();
		loadGraphic(AssetPaths.Ball__png);
		maxVelocity.x = 0;
		acceleration.y = Player.GRAVITY;
		elasticity = .5;
		
	}
	
	public function spawn(X:Float, Y:Float):Void
	{
		reset(X - (width / 2), Y - (height / 2));
		
	}
	
}