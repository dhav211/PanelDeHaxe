package en;

import com.Move.MoveCommand;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal.FlxTypedSignal;

class Cursor extends FlxSprite
{
	public var row:Int = 0;
	public var colLeft:Int = 0;
	public var colRight:Int = 0;

	var canPress:Bool = true;
	var isMoving:Bool = false;

	var blocks:Blocks;
	var move:MoveCommand;

	var moveComplete:FlxTypedSignal<FlxSprite->Void> = new FlxTypedSignal<FlxSprite->Void>();

	public function new(x:Float, y:Float, _blocks:Blocks)
	{
		super(x, y);
		blocks = _blocks;
		loadGraphic(AssetPaths.cursor__png, false, 16, 16);
		SetInitalPosition();

		move = new MoveCommand(this);
	}

	public override function update(elapsed:Float)
	{
		if (visible)
		{
			if (isMoving)
				move.Move(elapsed);

			Move();
			SwapBlocks();
			GetBlockColors();
		}
	}

	function GetBlockColors() // Debug
	{
		if (FlxG.keys.anyJustPressed([C]) && canPress)
		{
			canPress = false;

			if (blocks.grid[colLeft][row] != null)
				trace("Left: " + blocks.grid[colLeft][row].selectedColor + " at " + colLeft + " - " + row + "   x: " + blocks.grid[colLeft][row].x + " y: "
					+ blocks.grid[colLeft][row].y);
			else
				trace("Left: NULL " + " at " + colLeft + " - " + row);

			if (blocks.grid[colRight][row] != null)
				trace("Right: " + blocks.grid[colRight][row].selectedColor + " at " + colRight + " - " + row);
			else
				trace("Right: NULL " + " at " + colRight + " - " + row);
		}

		if (FlxG.keys.anyJustReleased([C]) && !canPress)
			canPress = true;
	}

	function Move()
	{
		var left:Bool = FlxG.keys.anyPressed([LEFT]);
		var right:Bool = FlxG.keys.anyPressed([RIGHT]);
		var up:Bool = FlxG.keys.anyPressed([UP]);
		var down:Bool = FlxG.keys.anyPressed([DOWN]);

		if (left && right)
			left = right = false;
		if (up && down)
			up = down = false;
		if (left && up)
			left = up = false;
		if (left && down)
			left = down = false;
		if (right && up)
			right = up = false;
		if (right && down)
			right = down = false;

		if (left && CanMove(left) && !isMoving)
		{
			move.StartMove(LEFT, 16, 0.2, _onMoveComplete);
			colLeft--;
			colRight--;
			isMoving = true;
		}

		if (right && CanMove(right) && !isMoving)
		{
			move.StartMove(RIGHT, 16, 0.2, _onMoveComplete);
			colLeft++;
			colRight++;
			isMoving = true;
		}

		if (down && CanMove(down) && !isMoving)
		{
			move.StartMove(DOWN, 16, 0.2, _onMoveComplete);
			row--;
			isMoving = true;
		}

		if (up && CanMove(up) && !isMoving)
		{
			move.StartMove(UP, 16, 0.2, _onMoveComplete);
			row++;
			isMoving = true;
		}
	}

	function CanMove(_directionPressed:Bool):Bool // Checks if it's in bounds to move in the given direction
	{
		if (_directionPressed == FlxG.keys.anyPressed([LEFT]))
			if (colLeft > 0)
				return true;
		if (_directionPressed == FlxG.keys.anyPressed([RIGHT]))
			if (colRight < 5)
				return true;
		if (_directionPressed == FlxG.keys.anyPressed([DOWN]))
			if (row > 1)
				return true;

		if (_directionPressed == FlxG.keys.anyPressed([UP]))
		{
			if (row < 13)
				return true;
		}

		return false;
	}

	function SwapBlocks()
	{
		var pressed:Bool = FlxG.keys.anyJustPressed([SPACE]);
		var released:Bool = FlxG.keys.anyJustReleased([SPACE]);
		var leftBlock:Block = null;
		var rightBlock:Block = null;

		if (pressed && canPress)
		{
			leftBlock = blocks.grid[colLeft][row];
			rightBlock = blocks.grid[colRight][row];

			if (leftBlock != null && leftBlock.alive)
			{
				if ((rightBlock != null && rightBlock.alive) || rightBlock == null)
				{
					leftBlock.Swap(1);
					blocks.grid[colRight][row] = leftBlock;
				}
			}
			else if (leftBlock == null)
			{
				blocks.grid[colRight][row] = null;
			}

			if (rightBlock != null && rightBlock.alive)
			{
				if ((leftBlock != null && leftBlock.alive) || leftBlock == null)
				{
					rightBlock.Swap(-1);
					blocks.grid[colLeft][row] = rightBlock;
				}
			}
			else if (rightBlock == null)
			{
				blocks.grid[colLeft][row] = null;
			}

			canPress = false;
		}

		if (released)
			canPress = true;
	}

	public function _onMoveCursorUp()
	{
		y -= 1;
	}

	public function _onIncreaseCursorRow()
	{
		row++;
	}

	public function SetInitalPosition()
	{
		setPosition(46, 174);
		colLeft = 2;
		colRight = 3;
		row = 3;
	}

	function _onMoveComplete()
	{
		isMoving = false;
	}
}
