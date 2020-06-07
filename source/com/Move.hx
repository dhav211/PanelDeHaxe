package com;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

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
	var onComplete:FlxTypedSignal<FlxSprite->Void>;
	var objectToMove:FlxSprite;

	public function new(_objectToMove:FlxSprite, _onComplete:FlxTypedSignal<FlxSprite->Void>)
	{
		objectToMove = _objectToMove;
		onComplete = _onComplete;
	}

	public function Move(_elapsed:Float)
	{
		var distanceToMove:Float = moveSpeed * _elapsed;
		currentDistance += distanceToMove;

		if (currentDistance >= distance)
		{
			distanceToMove = (currentDistance - distance) - distanceToMove;
			onComplete.dispatch(objectToMove);
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

	public function StartMove(_direction:Direction, _distance:Int, _duration:Float)
	{
		moveSpeed = 5 / _duration;
		distance = _distance;
		currentDirection = _direction;

		currentDistance = 0;
	}
}
