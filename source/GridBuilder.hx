import en.Block;
import en.Blocks;
import flixel.FlxG;
import flixel.math.FlxRandom;

class GridBuilder
{
	static public function GetInitialBricks(_grid:Array<Array<Block>>, _blocks:Blocks, _random:FlxRandom):Array<Array<Block>>
	{
		var yStartingPosition:Float = FlxG.height;
		var xStartingPosition:Float = 16;
		var blocks:Array<Block> = [];

		for (i in 0...6)
		{
			var rowHeight:Int = _random.int(4, 8);

			for (j in 0...rowHeight)
			{
				var block:Block = new Block(xStartingPosition + (16 * i), yStartingPosition - (16 * j), j, i, _random, _blocks);
				// _grid[i][j] = block;
				blocks.unshift(block);
			}
		}

		var isCheckingForNoMatchings:Bool = true;

		while (isCheckingForNoMatchings)
		{
			for (i in 0...blocks.length)
			{
				if (CheckForMatches(blocks[i], _grid))
				{
					blocks[i].selectedColor = blocks[i].SetColor(_random.int(0, 6));
					break;
				}
				else if (!CheckForMatches(blocks[i], _grid))
				{
					blocks[i].SetGraphicAndAnimations();
					_grid[blocks[i].col][blocks[i].row] = blocks[i];

					if (i == blocks.length - 1)
						isCheckingForNoMatchings = false;
				}
			}
		}

		return _grid;
	}

	static function CheckForMatches(_originBlock:Block, _grid:Array<Array<Block>>):Bool
	{
		var horizonalMatches:Array<Block> = [];
		var verticalMatches:Array<Block> = [];

		for (i in 0...4)
		{
			if (i == 0) // Check Up
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 0, 1, _grid);
				while (matches.length > 0)
					verticalMatches.push(matches.pop());
			}

			if (i == 1) // Check Down
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 0, -1, _grid);
				while (matches.length > 0)
					verticalMatches.push(matches.pop());
			}

			if (i == 2) // Check Right
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 1, 0, _grid);
				while (matches.length > 0)
					horizonalMatches.push(matches.pop());
			}

			if (i == 3) // Check Left
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, -1, 0, _grid);
				while (matches.length > 0)
					horizonalMatches.push(matches.pop());
			}
		}

		if (verticalMatches.length > 1 || horizonalMatches.length > 1)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	static function IsBlockAMatch(_match:Block, _originBlock:Block, _horizontalMatches:Array<Block>, _verticalMatches:Array<Block>):Bool
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

	static function CheckInDirectionForMatches(_originBlock:Block, _colDirection:Int, _rowDirection, _grid:Array<Array<Block>>):Array<Block>
	{
		var distanceToCheck = 1;
		var isCheckingForMatches = true;
		var blocksFound:Array<Block> = [];

		while (isCheckingForMatches)
		{
			var blockToCheck:Block = null;
			if (IsInGridBounds(_originBlock, _colDirection, _rowDirection, distanceToCheck)
				&& _grid[_originBlock.col + (distanceToCheck * _colDirection)][_originBlock.row + (distanceToCheck * _rowDirection)] != null)
				blockToCheck = _grid[_originBlock.col + (distanceToCheck * _colDirection)][_originBlock.row + (distanceToCheck * _rowDirection)];

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

	static function IsInGridBounds(_originBlock:Block, _colDirection:Int, _rowDirection, _distanceToCheck):Bool
	{
		if (_originBlock.col + (_distanceToCheck * _colDirection) >= 6)
			return false;
		if (_originBlock.col + (_distanceToCheck * _colDirection) < 0)
			return false;
		if (_originBlock.row + (_distanceToCheck * _rowDirection) > 14)
			return false;
		if (_originBlock.row + (_distanceToCheck * _rowDirection) <= 0)
			return false;

		return true;
	}
}
