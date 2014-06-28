using UnityEngine;
using System;
using System.Collections;
using Muto.Logic;

public class Heroine : MonoBehaviour, GameUnit
{
	public GameObject Player;
	public Vector3 PlayerFaceDirection;
	
	public const int MAX_VELOCITY = 5;

	event Action<GameUnit, Position2D> Moved;
	event Action<GameUnit> Destroyed;
	
	public Position2D Position
	{
		get
		{
			return new Position2D((int)Player.rigidbody.position.x, (int)Player.rigidbody.position.z);
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
		PlayerFaceDirection = new Vector3 (0.0f, 0.0f, 1.0f);
	}
	
	void FixedUpdate()
	{
		Vector3 force = Vector3.zero;

		if (Input.GetKey (KeyCode.A) || Input.GetKey (KeyCode.LeftArrow))
		{
			force = Vector3.Cross(PlayerFaceDirection, Vector3.up);
		}
		else if (Input.GetKey (KeyCode.S) || Input.GetKey (KeyCode.DownArrow))
		{
			force = -PlayerFaceDirection;
		}
		else if (Input.GetKey (KeyCode.D) || Input.GetKey (KeyCode.RightArrow))
		{
			force = Vector3.Cross(Vector3.up, PlayerFaceDirection);
		}
		else if (Input.GetKey (KeyCode.W) || Input.GetKey (KeyCode.UpArrow))
		{
			force = PlayerFaceDirection;
		}
		
		Player.rigidbody.AddForce (force);
		if (Player.rigidbody.velocity.magnitude > MAX_VELOCITY)
		{
			Player.rigidbody.velocity.Normalize();
			Player.rigidbody.velocity *= MAX_VELOCITY;
		}
		
		if (Vector3.Dot (PlayerFaceDirection, Player.rigidbody.velocity) < 0)
		{
			PlayerFaceDirection = Player.rigidbody.velocity;
		}
	}
}
