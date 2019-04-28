package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	
	
	public var ballCount:Int = 9;
	public var livesCount:Int = 5;
	public var score:Int = 0;
	
	private var moon:FlxSprite;
	private var map:TiledLevel;
	
	private var txtBalls:ScoreboardText;
	private var txtLives:ScoreboardText;
	
	private var txtScore:ScoreboardText;
	
	public var player:Player;
	
	public var vumpires:FlxTypedGroup<Vumpire>;
	public var playerBalls:FlxTypedGroup<Ball>;
	public var enemyBalls:FlxTypedGroup<Ball>;
	
	override public function create():Void
	{
		
		FlxG.mouse.visible = false;
		
		setupLevel();

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
		
		map.collideWithLevel(player);
		map.collideWithLevel(vumpires);
		FlxG.overlap(vumpires, player.attack, playerAttackHitVumpire, checkPlayerAttackHitVumpire);
		FlxG.overlap(vumpires, playerBalls, playerBallHitVumpire, checkPlayerBallHitVumpire);
		FlxG.overlap(vumpires, player, vumpireHitPlayer, checkVumpireHitPlayer);
		
		
	}
	
	
	private function vumpireHitPlayer(V:Vumpire, P:Player):Void
	{
		P.kill();
	}
	
	private function checkVumpireHitPlayer(V:Vumpire, P:Player):Bool
	{
		if (P.alive && V.alive && P.exists && V.exists && !FlxFlicker.isFlickering(P))
			return FlxG.pixelPerfectOverlap(V, P);
		return false;
	}
	
	private function playerBallHitVumpire(V:Vumpire, B:Ball):Void
	{
		V.kill();
		B.kill();
	}
	
	private function checkPlayerBallHitVumpire(V:Vumpire, B:Ball):Bool
	{
		if (B.alive && V.alive && B.exists && V.exists)
			return FlxG.pixelPerfectOverlap(V, B);
		return false;
	}
	
	private function playerAttackHitVumpire(V:Vumpire, A:FlxObject):Void
	{
		V.kill();
	}
	
	private function checkPlayerAttackHitVumpire(V:Vumpire, A:FlxObject):Bool
	{
		return A.alive && V.alive && V.exists;
			
	}
	
	
	public function spawnVumpire(X, Y):Vumpire
	{
		var v = vumpires.recycle(Vumpire);
		if (v == null)
			v = new Vumpire();
		v.reset(X, Y);
		vumpires.add(v);
		return v;
	}
	
	private function setupLevel():Void
	{
		var s:FlxSprite = new FlxSprite(0, 0, AssetPaths.skyline__png);
		s.scrollFactor.set();
		add(s);
		
		moon = new FlxSprite(FlxG.width - 80, -12, AssetPaths.moon__png);
		moon.scrollFactor.set();
		add(moon);
		
		map = new TiledLevel(AssetPaths.map__tmx, "assets/data/");
		
		add(map.background);
		add(map.wallsLayer);
		
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
		
		
		vumpires = new FlxTypedGroup<Vumpire>(10);
		add(vumpires);
		
		playerBalls = new FlxTypedGroup<Ball>(20);
		add(playerBalls);
		
		
		player = new Player();
		player.x = 16;
		player.y = s.y - 16-player.height;
		add(player);
		
		
		enemyBalls = new FlxTypedGroup<Ball>(20);
		add(enemyBalls);
		
		spawnVumpire(FlxG.width - 2, s.y - 16);
		
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

