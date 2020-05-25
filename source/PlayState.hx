package;

import en.Blocks;
import en.Cursor;
import flixel.FlxState;
import flixel.math.FlxRandom;

class PlayState extends FlxState
{
	var blocks:Blocks;
	var cursor:Cursor;
	var random:FlxRandom = new FlxRandom();

	override public function create()
	{
		super.create();

		blocks = new Blocks(random);
		add(blocks);
		blocks.SpawnInitalBlocks();

		cursor = new Cursor(0, 0, blocks);
		add(cursor);
	}

	override public function update(elapsed:Float)
	{
		blocks.update(elapsed);
		cursor.update(elapsed);
		super.update(elapsed);
	}
}
