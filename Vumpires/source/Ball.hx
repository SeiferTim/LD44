package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Ball extends FlxSprite
{

	public function new()
	{
		super();
		loadRotatedGraphic(AssetPaths.Ball__png, 360);
	}

	public function spawn(X:Float, Y:Float, Dir:Int):Void
	{
		reset(X, Y);
		velocity.x = Dir == FlxObject.RIGHT ? 400 : -400;
		angularVelocity = Dir == FlxObject.RIGHT ? 400 : -400;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if ((velocity.x > 0 && x > FlxG.worldBounds.width) || (velocity.x < 0 && x < -width))
			kill();
	}

}