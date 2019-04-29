package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTile;

class PlayState extends FlxTransitionableState
{
	
	
	public var ballCount:Int = 9;
	public var livesCount:Int = 5;
	public var score:Int = 0;
	public var vumpCount:Int = 0;
	
	private var moon:FlxSprite;
	private var map:TiledLevel;
	
	private var txtBalls:ScoreboardText;
	private var txtLives:ScoreboardText;
	
	private var txtScore:ScoreboardText;
	private var txtVumps:ScoreboardText;
	
	public var player:Player;
	
	public var enemies:FlxGroup;
	public var playerBalls:FlxTypedGroup<Ball>;
	public var enemyBalls:FlxTypedGroup<Ball>;
	public var ballDrops:FlxTypedGroup<BallDrop>;
	
	public var leaving:Bool = false;
	
	override public function create():Void
	{
		
		FlxG.mouse.visible = false;
		
		setupLevel();
		
		spawnEnemies();

		#if flash
		FlxG.sound.playMusic(AssetPaths.CreepySong__mp3);
		#else
		FlxG.sound.playMusic(AssetPaths.CreepySong__ogg);
		#end
		
		super.create();
		
		
	}

	override public function update(elapsed:Float):Void
	{
		
		super.update(elapsed);
		
		txtBalls.text = StringTools.lpad(Std.string(ballCount), "0", 2);
		txtLives.text = StringTools.lpad(Std.string(livesCount), "0", 2);
		txtScore.text = StringTools.lpad(Std.string(score), "0", 7);
		txtVumps.text = StringTools.lpad(Std.string(vumpCount), "0", 7);
		
		if (vumpCount <= 0 && !leaving)
		{
			// win!
			leaving = true;
			FlxG.sound.music.stop();
			FlxG.inputs.remove(Player.actions);
			FlxG.switchState(new GameOverState(false));
			
		}
		
		map.collideWithLevel(player);
		map.collideWithLevel(enemies);
		map.collideWithLevel(ballDrops);
		if (!leaving)
		
		{		
			FlxG.overlap(enemies, player.attack, playerAttackHitVumpire, checkPlayerAttackHitVumpire);
			FlxG.overlap(enemyBalls, player.attack, playerAttackHitEnemyBall, checkPlayerAttackHitEnemyBall);
			FlxG.overlap(enemies, playerBalls, playerBallHitVumpire, checkPlayerBallHitVumpire);
			FlxG.overlap(enemies, player, vumpireHitPlayer, checkVumpireHitPlayer);
			FlxG.overlap(enemyBalls, player, enemyBallHitPlayer, checkEnemyBallHitPlayer);
			FlxG.overlap(ballDrops, player, getBallDrop, checkGetBallDrop);
		}
		
		
	}
	
	
	private function getBallDrop(B:BallDrop, P:Player):Void
	{
		B.kill();
		ballCount++;
		FlxG.sound.play(AssetPaths.BallGet__wav);
	}
	
	private function checkGetBallDrop(B:BallDrop, P:Player):Bool
	{
		return B.alive && B.exists && P.alive && P.exists && ballCount < 9;
	}
	
	private function spawnEnemies():Void
	{
		for (e in map.enemies)
		{
			switch (Type.getClass(e)) 
			{
				case Vumpire:
					spawnVumpire(e.x, e.y, e.facing);
				case BallBat:
					spawnBallBat(e.x, e.y, e.facing);
				case StandVump:
					spawnStandVump(e.x, e.y, e.facing);
				default:
					
			}
			vumpCount++;
		}
		
	}
	
	
	
	private function enemyBallHitPlayer(V:FlxSprite, P:Player):Void
	{
		P.kill();
		
	}
	
	private function checkEnemyBallHitPlayer(V:FlxSprite, P:Player):Bool
	{
		if (P.alive && V.alive && P.exists && V.exists)
			return FlxG.pixelPerfectOverlap(V, P);
		return false;
	}
	
	private function vumpireHitPlayer(V:FlxSprite, P:Player):Void
	{
		P.kill();
	}
	
	private function checkVumpireHitPlayer(V:FlxSprite, P:Player):Bool
	{
		if (P.alive && V.alive && P.exists && V.exists && !FlxFlicker.isFlickering(P))
			return FlxG.pixelPerfectOverlap(V, P);
		return false;
	}
	
	private function playerBallHitVumpire(V:FlxSprite, B:Ball):Void
	{
		var m:FlxPoint = V.getMidpoint();
		V.kill();
		B.kill();
		vumpCount--;
		for (i in 0...3)
		{
			if (FlxG.random.bool(30))
			{
				spawnBallDrop(m.x, m.y);
			}
		}
	}
	
	private function checkPlayerBallHitVumpire(V:FlxSprite, B:Ball):Bool
	{
		if (B.alive && V.alive && B.exists && V.exists && B.isOnScreen() && V.isOnScreen())
			return FlxG.pixelPerfectOverlap(V, B);
		return false;
	}
	
	
	private function playerAttackHitEnemyBall(V:FlxSprite, A:FlxSprite):Void
	{
		FlxG.sound.play(AssetPaths.BallHit__wav);
		throwBall(V.x, V.y, player.facing, true);
		V.kill();
		
	}
	
	private function checkPlayerAttackHitEnemyBall(V:FlxSprite, A:FlxSprite):Bool
	{
		if (A.alive && V.alive && V.exists && A.exists)
			return FlxG.pixelPerfectOverlap(A, V);
		return false;
			
	}
	
	private function playerAttackHitVumpire(V:FlxSprite, A:FlxSprite):Void
	{
		if (Type.getClass(V) == BallBat)
		{
			cast(V, BallBat).killedByBat = true;
			
		}
		else
		{
			var m:FlxPoint = V.getMidpoint();
			for (i in 0...3)
			{
				if (FlxG.random.bool(30))
				{
					spawnBallDrop(m.x, m.y);
				}
			}
		}
		V.kill();
		vumpCount--;
	}
	
	private function checkPlayerAttackHitVumpire(V:FlxSprite, A:FlxSprite):Bool
	{
		if (A.alive && V.alive && V.exists && A.exists)
			return FlxG.pixelPerfectOverlap(A, V);
		return false;
			
	}
	
	public function spawnBallBat(X:Float, Y:Float, Facing:Int):BallBat
	{
		var b = new BallBat();
		b.spawn(X, Y, Facing);
		enemies.add(b);
		return b;
	}
	
	public function spawnVumpire(X:Float, Y:Float, Facing:Int):Vumpire
	{
		var v = new Vumpire();
		v.spawn(X, Y, Facing);
		enemies.add(v);
		return v;
	}
	
	public function spawnStandVump(X:Float, Y:Float, Facing:Int):StandVump
	{
		var v = new StandVump();
		v.spawn(X, Y, Facing);
		enemies.add(v);
		return v;
	}
	
	public function spawnBallDrop(X:Float, Y:Float):BallDrop
	{
		var b:BallDrop = ballDrops.recycle(BallDrop);
		if (b == null)
			b = new BallDrop();
		b.spawn(X + FlxG.random.int( -10, 10), Y + FlxG.random.int( -15, 0));
		ballDrops.add(b);
		return b;
	}
	
	private function setupLevel():Void
	{
		var s:FlxSprite = new FlxSprite(0, 0, AssetPaths.skyline__png);
		s.scrollFactor.set();
		add(s);
		
		moon = new FlxSprite(-60, -24, AssetPaths.moon__png);
		moon.scrollFactor.set(-.1,.025);
		add(moon);
		
		map = new TiledLevel(AssetPaths.map__tmx, "assets/data/");
		
		add(map.background);
		add(map.wallsLayer);
		//add(map.foreground);
		
		enemies = new FlxGroup();
		add(enemies);
		
		playerBalls = new FlxTypedGroup<Ball>(20);
		add(playerBalls);
		
		ballDrops = new FlxTypedGroup<BallDrop>(50);
		add(ballDrops);
		
		
		player = new Player();
		player.x = map.playerStart.x - (player.width/2);
		player.y = map.playerStart.y - player.height;
		FlxG.camera.follow(player);
		add(player);
		
		enemyBalls = new FlxTypedGroup<Ball>(20);
		add(enemyBalls);
		
		s = new FlxSprite(0, FlxG.height - 64, AssetPaths.score_back__png);
		s.scrollFactor.set();
		add(s);
		
		txtBalls = new ScoreboardText("00");
		txtBalls.x = 16;
		txtBalls.y = s.y + 27;
		
		add(txtBalls);
		
		txtLives = new ScoreboardText("00");
		txtLives.x = 273;
		txtLives.y = s.y + 27;
		
		add(txtLives);
		
		txtScore = new ScoreboardText("0000000");
		txtScore.letterSpacing = 3;
		txtScore.x = 133;
		txtScore.y = s.y + 35;
		
		add(txtScore);
		
		txtVumps = new ScoreboardText("0000000");
		txtVumps.letterSpacing = 3;
		txtVumps.x = 133;
		txtVumps.y = s.y + 6;
		
		add(txtVumps);
		
		
		
	}
	
	public function throwBall(X:Float, Y:Float, Facing:Int, ?FromPlayer:Bool = false):Ball
	{
		var g:FlxTypedGroup<Ball> = FromPlayer ? playerBalls : enemyBalls;
		var b:Ball = g.recycle(Ball);
		if (b == null)
		{
			b = new Ball();
		}
		b.spawn(X, Y, Facing);
		g.add(b);
		return b;
	}
}

