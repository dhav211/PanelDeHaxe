package;

import en.Blocks;
import en.Cursor;
import flixel.FlxState;
import flixel.math.FlxRandom;
import ui.Stats;

class PlayState extends FlxState
{
	var blocks:Blocks;
	var cursor:Cursor;
	var stats:Stats;
	var score:Score = new Score();
	var random:FlxRandom = new FlxRandom();

	override public function create()
	{
		super.create();

		blocks = new Blocks(random, score);
		add(blocks);
		blocks.SpawnInitalBlocks();

		cursor = new Cursor(0, 0, blocks);
		blocks.SetCursor(cursor);
		add(cursor);

		stats = new Stats();
		add(stats);

		blocks.SetStatsSignals(stats);
	}

	override public function update(elapsed:Float)
	{
		blocks.update(elapsed);
		cursor.update(elapsed);
		super.update(elapsed);
	}
}
