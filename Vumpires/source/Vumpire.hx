package;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;

class Vumpire extends FlxSprite 
{

	public function new() 
	{
		super();
		
		frames = GraphicsCache.loadGraphicFromAtlas("vumpire", AssetPaths.vumpire__png, AssetPaths.vumpire__xml).atlasFrames;
		
		width = 18;
		height = 29;
		offset.x = 4;
		offset.y = 2;
		
		animation.addByPrefix("walk", "vump-walk-", 8, true);
		animation.play("walk");
		
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		facing = FlxObject.LEFT;
		
		acceleration.y = Player.GRAVITY;
		maxVelocity.set(100, Player.GRAVITY);
		
	}
	
	override public function kill():Void 
	{
		alive = false;
		allowCollisions = FlxObject.NONE;
		velocity.x = facing == FlxObject.LEFT ? 300 : -300;
		velocity.y = -300;
		FlxFlicker.flicker(this, 0);
		FlxG.sound.play(AssetPaths.VumpireHurt__wav, .5);
		cast(FlxG.state, PlayState).score+= 100;
	}
	
	public function spawn(X:Float, Y:Float):Void 
	{
		reset(X,Y-height);
		FlxFlicker.stopFlickering(this);
		alive = true;
		animation.play("walk");
		allowCollisions = FlxObject.ANY;
		velocity.x = -100;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (!isOnScreen())
		{
			return;
		}
		
		if (justTouched(FlxObject.WALL))
		{
			facing = facing == FlxObject.LEFT ? FlxObject.RIGHT : FlxObject.LEFT;
			velocity.x = facing == FlxObject.LEFT ? -100 : 100;
			x += velocity.x * elapsed;
			touching = FlxObject.NONE;
		}
		
		if (y > 1000)
		{
			alive = exists = false;
			FlxFlicker.stopFlickering(this);
		}
		super.update(elapsed);
		
	}
	
}