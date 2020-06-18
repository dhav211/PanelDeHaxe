package ui;

import en.Blocks;
import en.Cursor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;

class GameOver extends FlxText
{
	var score:Score;
	var blocks:Blocks;
	var cursor:Cursor;

	var isGameOver:Bool = false;

	public function new(_score:Score, _blocks:Blocks, _cursor:Cursor)
	{
		score = _score;
		blocks = _blocks;
		cursor = _cursor;

		super(0, 0, 0, "Restart", 32);
		screenCenter(FlxAxes.X);
		y = 32;

		visible = false;
	}

	public override function update(elapsed:Float)
	{
		// Pressed enter to restart game
	}

	public function _onStartGameOver()
	{
		isGameOver = true;
		visible = true;
		cursor.visible = false;
		blocks.StopGame();

		PlayDeathAnimation();
	}

	function RemoveAllBlocks()
	{
		for (block in blocks)
			blocks.remove(block);

		blocks.grid = blocks.CreateEmptyGrid();
	}

	function PlayDeathAnimation()
	{
		for (col in 0...6)
		{
			for (row in 0...14)
			{
				if (blocks.grid[col][row] != null)
				{
					blocks.grid[col][row].alive = false;
					blocks.grid[col][row].animation.play("die");
				}
			}
		}
	}
}
