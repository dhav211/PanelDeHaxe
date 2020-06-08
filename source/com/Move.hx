package com;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import haxe.Constraints.Function;

enum Direction
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

class MoveCommand
{
	var moveSpeed:Float = 0;
	var distance:Float = 0;
	var currentDistance:Float = 0;
	var currentDirection:Direction = UP;
	var onComplete:Function;
	var objectToMove:FlxSprite;

	public function new(_objectToMove:FlxSprite)
	{
		objectToMove = _objectToMove;
	}

	public function Move(_elapsed:Float)
	{
		var distanceToMove:Float = moveSpeed * _elapsed;
		currentDistance += distanceToMove;

		if (currentDistance >= distance)
		{
			distanceToMove = distanceToMove - (currentDistance - distance);
			onComplete();
		}

		switch (currentDirection)
		{
			case UP:
				objectToMove.y -= distanceToMove;
			case DOWN:
				objectToMove.y += distanceToMove;
			case LEFT:
				objectToMove.x -= distanceToMove;
			case RIGHT:
				objectToMove.x += distanceToMove;
		}
	}

	public function StartMove(_direction:Direction, _distance:Int, _duration:Float, _onComplete:Function)
	{
		moveSpeed = 10 / _duration;
		distance = _distance;
		currentDirection = _direction;
		onComplete = _onComplete;

		currentDistance = 0;
	}
}
