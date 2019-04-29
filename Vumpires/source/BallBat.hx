package;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class BallBat extends FlxSprite 
{

	public var killedByBat:Bool = false;
	
	public function new() 
	{
		super();
		
		frames = GraphicsCache.loadGraphicFromAtlas("ballbat", AssetPaths.ballbat__png, AssetPaths.ballbat__xml).atlasFrames;
		
		width = 8;
		height = 8;
		offset.x = 13;
		offset.y = 14;
		
		animation.addByPrefix("ballbat", "ballbat-", 8, true);
		animation.play("ballbat");
		
		maxVelocity.set(160, 0);
		
		
		
	}
	
	override public function kill():Void 
	{
		FlxG.sound.play(AssetPaths.BatThrow__wav, .5);
		cast(FlxG.state, PlayState).score+= 250;
		
		if (killedByBat)
		{
			var p:PlayState = cast FlxG.state;
			p.throwBall(x, y, p.player.facing, true);
			killedByBat = false;
			FlxG.sound.play(AssetPaths.BallHit__wav);
		}
		
		super.kill();
	}
	
	public function spawn(X:Float, Y:Float):Void 
	{
		reset(X,Y);
		
		alive = true;
		animation.play("ballbat");
		velocity.x = -160;
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
			velocity.x = facing == FlxObject.LEFT ? -160 : 160;
			x += velocity.x * elapsed;
			touching = FlxObject.NONE;
		}
		
		super.update(elapsed);
		
		if (x < -width)
		{
			alive = exists = false;
			
		}
	}
}