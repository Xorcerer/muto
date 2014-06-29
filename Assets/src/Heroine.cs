using UnityEngine;
using System;
using System.Collections;
using Muto.Logic;

public class Heroine : MonoBehaviour, GameUnit
{
	public GameObject Player;

	event Action<GameUnit, Position2D> Moved;
	event Action<GameUnit> Destroyed;
	
	public Position2D Position
	{
		get
		{
			return new Position2D(
				(int)Player.transform.position.x,
				(int)Player.transform.position.y);
		}
	}

	event Action<GameUnit, Position2D> GameUnit.Moved
	{
		add
		{
			Moved += value;
		}
		remove
		{
			Moved -= value;
		}
	}

	event Action<GameUnit> GameUnit.Destroyed
	{
		add
		{
			Destroyed += value;
		}
		remove
		{
			Destroyed -= value;
		}
	}
	
	void Start ()
	{
	}
	
	void FixedUpdate()
	{
		DetectInputAndChangePhysicalState ();
	}

	void DetectInputAndChangePhysicalState()
	{
		var velocity = Vector2.zero;
		
		if (Input.GetKey (KeyCode.A) || Input.GetKey (KeyCode.LeftArrow))
		{
			velocity += -Vector2.right;
		}
		if (Input.GetKey (KeyCode.S) || Input.GetKey (KeyCode.DownArrow))
		{
			velocity += -Vector2.up;
		}
		if (Input.GetKey (KeyCode.D) || Input.GetKey (KeyCode.RightArrow))
		{
			velocity += Vector2.right;
		}
		if (Input.GetKey (KeyCode.W) || Input.GetKey (KeyCode.UpArrow))
		{
			velocity += Vector2.up;
		}
		
		Player.rigidbody2D.velocity = velocity;
	}
}
