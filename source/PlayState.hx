package;

import en.Blocks;
import en.Cursor;
import flixel.FlxState;
import flixel.math.FlxRandom;
import ui.GameOver;
import ui.Stats;

class PlayState extends FlxState
{
	var blocks:Blocks;
	var cursor:Cursor;
	var stats:Stats;
	var gameOver:GameOver;
	var score:Score = new Score();
	var random:FlxRandom = new FlxRandom();

	override public function create()
	{
		super.create();

		blocks = new Blocks(random, score);
		add(blocks);

		cursor = new Cursor(0, 0, blocks);
		blocks.SetCursor(cursor);
		add(cursor);

		stats = new Stats();
		add(stats);

		gameOver = new GameOver(score, blocks, cursor);
		add(gameOver);

		blocks.SetStatsSignals(stats);
		blocks.SetGameOverSignal(gameOver);
		blocks.StartGame();
	}

	override public function update(elapsed:Float)
	{
		blocks.update(elapsed);
		cursor.update(elapsed);
		super.update(elapsed);
	}
}
