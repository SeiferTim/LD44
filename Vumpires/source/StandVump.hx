package;
import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;


class StandVump extends FlxSprite
{

	private var throwTimer:Float= 3;
	
	public function new() 
	{
		super();
		
		frames = GraphicsCache.loadGraphicFromAtlas("standvump", AssetPaths.standvump__png, AssetPaths.standvump__xml).atlasFrames;
		
		width = 16;
		height = 30;
		offset.x = 13;
		offset.y = 10;
		
		animation.addByNames("wait", ["standvump-1.png"], 8, false);
		animation.addByNames("throw", ["standvump-2.png"], 4, false);
		animation.play("wait");
		
		maxVelocity.set(0, 0);
		
	}
	
	override public function kill():Void 
	{
		alive = false;
		allowCollisions = FlxObject.NONE;
		velocity.x = -300;
		velocity.y = -300;
		FlxFlicker.flicker(this, 0);
		FlxG.sound.play(AssetPaths.VumpireHurt__wav, .5);
		cast(FlxG.state, PlayState).score+= 200;
	}
	
	public function spawn(X:Float, Y:Float):Void 
	{
		reset(X,Y-height);
		FlxFlicker.stopFlickering(this);
		alive = true;
		animation.play("wait");
		allowCollisions = FlxObject.ANY;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (!isOnScreen())
		{
			return;
		}
		super.update(elapsed);
		if (y > 1000)
		{
			alive = exists = false;
			FlxFlicker.stopFlickering(this);
		}
		if (alive)
		{
			throwTimer -= elapsed;
			if (throwTimer <= 0)
			{
				throwTimer += 3;
				cast(FlxG.state, PlayState).throwBall(x - 2, y+8, FlxObject.LEFT, false);
				animation.play("throw");
			}
			if (animation.finished && animation.name != "wait")
				animation.play("wait");
		}
	}
	
}