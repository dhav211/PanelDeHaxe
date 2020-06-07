package en;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

class Blocks extends FlxTypedGroup<Block>
{
	public var grid:Array<Array<Block>> = [];

	public final GRID_WIDTH:Int = 6;
	public final GRID_HEIGHT:Int = 14;

	var speed:Float = 100;

	var currentIncrement:Int = 0;
	final MAX_INCREMENT:Int = 16;

	var timer:FlxTimer = new FlxTimer();
	var tween:FlxTween;
	var random:FlxRandom;

	var moveCursorUp:FlxSignal = new FlxSignal();
	var increaseCursorRow:FlxSignal = new FlxSignal();

	public function new(_random:FlxRandom)
	{
		super();

		random = _random;
		grid = CreateEmptyGrid();
		// timer.start(60 / speed);
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
				increaseCursorRow.dispatch();
				currentIncrement = 0;
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
			_originBlock.kill();

			if (verticalMatches.length > 1)
			{
				for (match in verticalMatches)
				{
					match.kill();
				}
			}

			if (horizonalMatches.length > 1)
			{
				for (match in horizonalMatches)
				{
					match.kill();
				}
			}
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
					grid[x][y].row++;
					increasedRowGrid[x][y + 1] = grid[x][y];
				}
			}
		}

		grid = increasedRowGrid;
	}

	public function SpawnRow()
	{
		var yPosition:Float = FlxG.height;
		var xStartingPosition:Float = 16;

		for (i in 0...6)
		{
			var block:Block = new Block(xStartingPosition + (16 * i), yPosition, 0, i, random, this);
			grid[i][0] = block;
			add(block);
		}
	}

	public function SpawnInitalBlocks()
	{
		var random:FlxRandom = new FlxRandom();
		var yStartingPosition:Float = FlxG.height;
		var xStartingPosition:Float = 16;

		for (i in 0...6)
		{
			var rowHeight:Int = random.int(4, 8);

			for (j in 0...rowHeight)
			{
				var block:Block = new Block(xStartingPosition + (16 * i), yStartingPosition - (16 * j), j, i, random, this);
				grid[i][j] = block;
				add(block);
			}
		}
	}

	function CreateEmptyGrid():Array<Array<Block>>
	{
		var emptyBlock:Block = null;
		var tempGrid:Array<Array<Block>> = [for (x in 0...GRID_WIDTH) [for (y in 0...GRID_HEIGHT) emptyBlock]];
		return tempGrid;
	}

	public function SetCursor(_cursor:Cursor)
	{
		moveCursorUp.add(_cursor._onMoveCursorUp);
		increaseCursorRow.add(_cursor._onIncreaseCursorRow);
	}
}
