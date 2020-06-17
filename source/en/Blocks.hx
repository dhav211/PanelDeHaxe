package en;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import ui.Stats;

class Blocks extends FlxTypedGroup<Block>
{
	public var grid:Array<Array<Block>> = [];

	public final GRID_WIDTH:Int = 6;
	public final GRID_HEIGHT:Int = 14;

	final INITIAL_SPEED:Int = 100;
	var speed:Float = 100;
	var speedLevel:Int = 1;
	var currentSpeedIncrement:Int = 0;
	var chain:Int = 0;

	public var currentIncrement(default, null):Int = 0;

	final MAX_SPEED_INCREMENT:Int = 5;
	final MAX_INCREMENT:Int = 16;
	final SPEED_INCREASE_AMOUNT = 30;

	var timer:FlxTimer = new FlxTimer();
	var tween:FlxTween;
	var random:FlxRandom;
	var score:Score;

	var moveCursorUp:FlxSignal = new FlxSignal();
	var increaseCursorRow:FlxSignal = new FlxSignal();
	var updateLevel:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public function new(_random:FlxRandom, _score:Score)
	{
		super();

		random = _random;
		score = _score;
		grid = CreateEmptyGrid();
		timer.start(60 / speed);
	}

	public override function update(elapsed:Float)
	{
		if (timer.finished)
		{
			MoveBlocksUp();
			timer.start(60 / speed);

			currentIncrement++;
			if (currentIncrement == MAX_INCREMENT)
			{
				IncreaseBlocksRowCount();
				SpawnRow();
				CheckForColumnsInDanger();
				increaseCursorRow.dispatch();
				currentIncrement = 0;
				currentSpeedIncrement++;

				if (currentSpeedIncrement == MAX_SPEED_INCREMENT)
				{
					speed += SPEED_INCREASE_AMOUNT;
					speedLevel++;
					updateLevel.dispatch(speedLevel);
					trace("speed has increased");
				}
			}
		}

		super.update(elapsed);
	}

	public function SetBlockInGrid(_col:Int, _row:Int, _block:Block)
	{
		grid[_col][_row] = _block;
	}

	public function RemoveBlockInGrid(_col:Int, _row:Int)
	{
		grid[_col][_row] = null;
	}

	public function CheckForMatches(_originBlock:Block)
	{
		var horizonalMatches:Array<Block> = [];
		var verticalMatches:Array<Block> = [];

		for (i in 0...4)
		{
			if (i == 0) // Check Up
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 0, 1);
				while (matches.length > 0)
					verticalMatches.push(matches.pop());
			}

			if (i == 1) // Check Down
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 0, -1);
				while (matches.length > 0)
					verticalMatches.push(matches.pop());
			}

			if (i == 2) // Check Right
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 1, 0);
				while (matches.length > 0)
					horizonalMatches.push(matches.pop());
			}

			if (i == 3) // Check Left
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, -1, 0);
				while (matches.length > 0)
					horizonalMatches.push(matches.pop());
			}
		}

		if (verticalMatches.length > 1 || horizonalMatches.length > 1)
		{
			var blocksMatched:Int = 0;
			_originBlock.kill();
			blocksMatched++;

			if (verticalMatches.length > 1)
			{
				for (match in verticalMatches)
				{
					match.kill();
					blocksMatched++;
				}
			}

			if (horizonalMatches.length > 1)
			{
				for (match in horizonalMatches)
				{
					match.kill();
					blocksMatched++;
				}
			}

			// The score from this match will be added
			score.CalculateScore(blocksMatched, chain);
			chain++;

			if (chain > 1)
				trace("the current chain is " + chain);
		}
		else
		{
			// No matches were found, so break the chain
			chain = 0;
		}
	}

	function IsBlockAMatch(_match:Block, _originBlock:Block, _horizontalMatches:Array<Block>, _verticalMatches:Array<Block>):Bool
	{
		if (_match == _originBlock)
			return true;

		for (hMatch in _horizontalMatches)
		{
			if (_match == hMatch)
				return true;
		}

		for (vMatch in _verticalMatches)
		{
			if (_match == vMatch)
				return true;
		}

		return false;
	}

	function CheckInDirectionForMatches(_originBlock:Block, _colDirection:Int, _rowDirection):Array<Block>
	{
		var distanceToCheck = 1;
		var isCheckingForMatches = true;
		var blocksFound:Array<Block> = [];

		while (isCheckingForMatches)
		{
			var blockToCheck:Block = null;
			if (IsInGridBounds(_originBlock, _colDirection, _rowDirection, distanceToCheck)
				&& grid[_originBlock.col + (distanceToCheck * _colDirection)][_originBlock.row + (distanceToCheck * _rowDirection)] != null)
				blockToCheck = grid[_originBlock.col + (distanceToCheck * _colDirection)][_originBlock.row + (distanceToCheck * _rowDirection)];

			if (blockToCheck != null && blockToCheck.selectedColor == _originBlock.selectedColor && blockToCheck.row > 0)
			{
				blocksFound.push(blockToCheck);
				distanceToCheck++;
			}
			else if (blockToCheck == null || blockToCheck.selectedColor != _originBlock.selectedColor || blockToCheck.row > 0)
			{
				isCheckingForMatches = false;
			}
		}

		return blocksFound;
	}

	function IsInGridBounds(_originBlock:Block, _colDirection:Int, _rowDirection, _distanceToCheck):Bool
	{
		if (_originBlock.col + (_distanceToCheck * _colDirection) >= GRID_WIDTH)
			return false;
		if (_originBlock.col + (_distanceToCheck * _colDirection) < 0)
			return false;
		if (_originBlock.row + (_distanceToCheck * _rowDirection) > GRID_HEIGHT)
			return false;
		if (_originBlock.row + (_distanceToCheck * _rowDirection) <= 0)
			return false;

		return true;
	}

	function MoveBlocksUp()
	{
		for (block in this)
		{
			block.y -= 1;
		}

		moveCursorUp.dispatch();
	}

	function IncreaseBlocksRowCount()
	{
		var increasedRowGrid:Array<Array<Block>> = CreateEmptyGrid();

		for (x in 0...GRID_WIDTH)
		{
			for (y in 0...GRID_HEIGHT)
			{
				if (grid[x][y] != null)
				{
					grid[x][y].IncreaseRow();
					increasedRowGrid[x][y + 1] = grid[x][y];
				}
			}
		}

		grid = increasedRowGrid;

		// The previously nulled out 0 row is now 1, so check for matches on it the moment it is possible.
		for (i in 0...GRID_WIDTH)
		{
			CheckForMatches(grid[i][1]);
		}
	}

	public function SpawnRow()
	{
		var yPosition:Float = FlxG.height;
		var xStartingPosition:Float = 16;

		for (i in 0...6)
		{
			var block:Block = new Block(xStartingPosition + (16 * i), yPosition, 0, i, random, this);

			// Within here it will make sure no matches are being formed
			if (i > 1)
			{
				var isCheckingForMatch:Bool = true;

				while (isCheckingForMatch)
				{
					// Compare the color of the two blocks to the left of current block
					var numberOfMatches:Int = 0;
					for (j in 1...3)
					{
						if (grid[i - j][0].selectedColor == block.selectedColor)
						{
							numberOfMatches++;
						}
					}

					if (numberOfMatches > 1) // if there was a match, change the color and the process will begin again
					{
						block.selectedColor = block.SetColor(random.int(0, 6));
						block.SetGraphicAndAnimations();
					}
					else
					{
						isCheckingForMatch = false;
					}
				}
			}

			grid[i][0] = block;
			add(block);
		}
	}

	public function SpawnInitalBlocks()
	{
		grid = GridBuilder.GetInitialBricks(grid, this, random);

		for (i in 0...GRID_WIDTH)
		{
			for (j in 0...GRID_HEIGHT)
			{
				if (grid[i][j] != null)
					add(grid[i][j]);
			}
		}
	}

	public function CheckForColumnsInDanger()
	{
		var dangerRowHeight:Int = 10;
		for (col in 0...GRID_WIDTH)
		{
			var colIsInDanger:Bool = false;

			for (row in 0...GRID_HEIGHT)
			{
				if (row == dangerRowHeight && grid[col][row] != null)
					colIsInDanger = true;
			}

			if (colIsInDanger)
			{
				for (row in 0...GRID_HEIGHT)
				{
					if (grid[col][row] != null)
						if (grid[col][row].alive)
						{
							grid[col][row].animation.play("danger_bounce");
						}
				}
			}
			else
			{
				for (row in 0...GRID_HEIGHT)
				{
					if (grid[col][row] != null)
					{
						if (row > 0 && grid[col][row].alive)
							grid[col][row].animation.play("still");
						else if (row == 0 && grid[col][row].alive)
							grid[col][row].animation.play("null");
					}
				}
			}
		}
	}

	function CreateEmptyGrid():Array<Array<Block>>
	{
		var emptyBlock:Block = null;
		var tempGrid:Array<Array<Block>> = [for (x in 0...GRID_WIDTH) [for (y in 0...GRID_HEIGHT) emptyBlock]];
		return tempGrid;
	}

	public function SetStatsSignals(_stats:Stats)
	{
		score.updateScore.add(_stats._onUpdateScore);
		updateLevel.add(_stats._onUpdateLevel);
	}

	public function SetCursor(_cursor:Cursor)
	{
		moveCursorUp.add(_cursor._onMoveCursorUp);
		increaseCursorRow.add(_cursor._onIncreaseCursorRow);
	}
}
