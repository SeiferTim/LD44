package;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.effects.FlxFlicker;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;


class Player extends FlxSprite 
{
	
	public static var actions:FlxActionManager;
	
	public var left:FlxActionDigital;
	public var right:FlxActionDigital;
	public var jump:FlxActionDigital;
	public var swing:FlxActionDigital;
	public var ball:FlxActionDigital;
	
	public var swingCooldown:Float = 0;
	public var ballCooldown:Float = 0;
	
	public var fsm:FlxFSM<Player>;
	
	public static inline var GRAVITY:Int = 600;
	public static inline var WALK_SPEED:Int = 80;
	
	public var attack:FlxObject;
	
	public var swinging(get, null):Bool;
	
	public var dead:Bool = false;
	
	public function new() 
	{
		super();
		
		frames = GraphicsCache.loadGraphicFromAtlas("player", AssetPaths.player__png, AssetPaths.player__xml).atlasFrames;
		
		width = 10;
		height = 24;
		offset.x = 2;
		
		attack = new FlxObject(0, 0, 10, 9);
		attack.alive = false;
		
		animation.addByPrefix("walk", "player-walk-", 8, true, false, false);
		animation.addByNames("swing", ["player-swing.png"], 4, false, false, false);
		animation.addByNames("hurt", ["player-hurt.png","player-hurt.png","player-hurt.png","player-hurt.png", "player-dead.png"], 8, false, false, false);
		animation.addByNames("jump", ["player-walk-1.png"], 8, false, false, false);
		
		acceleration.y = GRAVITY;
		maxVelocity.set(120, GRAVITY);
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		facing = FlxObject.RIGHT;
		
		fsm = new FlxFSM<Player>(this);
		fsm.transitions
				.add(Idle, Jump, Conditions.jump)
				.add(Jump, Idle,  Conditions.grounded)
				.addGlobal(Dead, Conditions.dead)
				.start(Idle);
		
		addInputs();
		
	}
	
	
	
	private function addInputs():Void
	{
		left = new FlxActionDigital();
		right = new FlxActionDigital();
		jump = new FlxActionDigital();
		swing = new FlxActionDigital();
		ball = new FlxActionDigital();
		
		if (actions == null)
		{
			actions = FlxG.inputs.add(new FlxActionManager());
		}
		
		actions.addActions([left, right, jump, swing, ball]);
		
		left.addKey(LEFT, PRESSED);
		left.addKey(S, PRESSED);
		right.addKey(D, PRESSED);
		right.addKey(RIGHT, PRESSED);
		jump.addKey(X, PRESSED);
		jump.addKey(SPACE, PRESSED);
		left.addGamepad(DPAD_LEFT, PRESSED);
		right.addGamepad(DPAD_RIGHT, PRESSED);
		jump.addGamepad(A, PRESSED);
		jump.addGamepad(B, PRESSED);
		swing.addKey(Z, PRESSED);
		swing.addGamepad(X, PRESSED);
		ball.addKey(C, PRESSED);
		ball.addGamepad(Y, PRESSED);
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (swingCooldown > 0)
			swingCooldown -= elapsed;
		
		if (ballCooldown > 0)
			ballCooldown -= elapsed;
		
		fsm.update(elapsed);
		
		
		attack.y = y + 10;
		attack.x = x + (facing == FlxObject.LEFT ? width - 26 : 16);
		
		attack.alive = swinging;
		
		super.update(elapsed);
	}
	
	override public function destroy():Void 
	{
		fsm.destroy();
		fsm = null;
		
		actions.destroy();
		actions = null;
		
		super.destroy();
	}
	
	override function set_facing(Value:Int):Int
	{
		if (Value == FlxObject.LEFT)
		{
			offset.x = 12;
			
		}
		else
		{
			offset.x = 2;
			
		}
		return super.set_facing(Value);
	}
	
	
	public function doThrow():Void
	{
		var s:PlayState = cast(FlxG.state, PlayState);
		if (s.ballCount > 0)
		{
			FlxG.sound.play(AssetPaths.BallThrow__wav);
			s.throwBall(facing == FlxObject.LEFT ? x - 2 : x + width - 5, y + 9, facing, true);
			s.ballCount--;
			ballCooldown = 2;
		}
	}
	
	public function doSwing():Void
	{
		animation.play("swing", true);
		animation.finishCallback = finishAnim;
		
	}
	
	private function get_swinging():Bool
	{
		return (animation.name == "swing" && !animation.finished);
	}
	
	private function finishAnim(S:String):Void
	{
		if (S == "swing")
		{
			swingCooldown = .1;
		}
	}
	
	override public function kill():Void 
	{
		dead = true;
	}
	
	
	public function respawn():Void
	{
		dead = false;
		revive();
		swingCooldown = ballCooldown = 0;
		FlxFlicker.flicker(this, 3);
		fsm.state = new Idle();
		
	}
	
}

class Conditions
{
	public static function jump(Owner:Player):Bool
	{
		return (Owner.jump.triggered && grounded(Owner));
	}
	
	public static function grounded(Owner:Player):Bool
	{
		return Owner.isTouching(FlxObject.DOWN);
	}
	
	public static function dead(Owner:Player):Bool
	{
		return Owner.dead && Owner.alive;
	}
	
}

class Idle extends FlxFSMState<Player>
{
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		owner.animation.play("walk", true);
		owner.animation.pause();
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		var inputLeft:Bool = owner.left.triggered;
		var inputRight:Bool = owner.right.triggered;
		var inputSwing:Bool = owner.swing.triggered;
		var inputBall:Bool = owner.ball.triggered;
		
		if (inputLeft && inputRight)
			inputLeft = inputRight = false;
		
		if (inputSwing && owner.swingCooldown <= 0 && !owner.swinging)
		{
			owner.doSwing();
		}
		
		if (owner.swinging)
		{
			owner.velocity.x = 0;
		}
		else
		{
			
			if (inputBall && owner.ballCooldown <= 0)
				owner.doThrow();
			
			var walking:Bool = inputLeft || inputRight;
			if (walking)
			{
				owner.velocity.x = (inputLeft ? -1 : 1) * Player.WALK_SPEED;
				if (owner.animation.name == "walk")
					owner.animation.resume();
				else
				{
					if (owner.animation.name != "swing" || owner.animation.finished)
						owner.animation.play("walk");
				}
				
					
				owner.facing = inputLeft ? FlxObject.LEFT : FlxObject.RIGHT;
			}
			else
			{
				owner.velocity.x = 0;
				if (owner.animation.name == "walk")
					owner.animation.pause();
				else if (owner.animation.finished)
				{
					owner.animation.play("walk");
					owner.animation.pause();
				}
			}
		}
	}
	
}

class Jump extends FlxFSMState<Player>
{
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void 
	{
		owner.animation.play("jump");
		owner.velocity.y = -250;
		FlxG.sound.play(AssetPaths.Jump__wav, .5);
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		var inputLeft:Bool = owner.left.triggered;
		var inputRight:Bool = owner.right.triggered;
		var inputSwing:Bool = owner.swing.triggered;
		var inputBall:Bool = owner.ball.triggered;
		
		if (inputLeft && inputRight)
			inputLeft = inputRight = false;
		
		if (inputSwing && owner.swingCooldown <= 0 && !owner.swinging)
		{
			owner.doSwing();
		}
		
		if (owner.swinging)
		{
			owner.velocity.x = 0;
		}
		else
		{
			
			if (inputBall && owner.ballCooldown <= 0)
				owner.doThrow();
				
			var walking:Bool = inputLeft || inputRight;
			if (walking)
			{
				owner.velocity.x = (inputLeft ? -1 : 1) * Player.WALK_SPEED;
				
				owner.facing = inputLeft ? FlxObject.LEFT : FlxObject.RIGHT;
			}
			else
			{
				owner.velocity.x = 0;
				
		}
		
		}
	}
}


class Dead extends FlxFSMState<Player>
{
	private var respawnTimer:Float = -1000;
	
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void 
	{
		owner.velocity.x = 0;
		owner.animation.play("hurt", true);
		FlxG.sound.play(AssetPaths.PlayerDeath__wav, .5);
		owner.alive = false;
		owner.exists = true;
		
		respawnTimer = 3;
		
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		if (respawnTimer > -1000)
		{
			if (respawnTimer > 0)
			{
				respawnTimer -= elapsed;
			}
			else
			{
				respawnTimer = -1000;
				
				var p:PlayState = cast FlxG.state;
				if (p.livesCount > 0)
				{
					p.livesCount--;
					owner.respawn();
				}
				else if (!p.leaving)
				{
					p.leaving = true;
					FlxG.sound.music.stop();
					FlxG.inputs.remove(Player.actions);
					FlxG.switchState(new GameOverState());
				}			
			}
		}
		
	}
	
}