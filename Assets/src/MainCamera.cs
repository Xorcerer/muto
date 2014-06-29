using UnityEngine;
using System.Collections;
using System;

public class MainCamera : MonoBehaviour
{
	public GameObject Heroine; 
	public GameObject Camera;
	public float CameraHeight;
	public float FollowSpeed;

	void Start ()
	{
	}

	void FixedUpdate ()
	{
		var projectionCamera = new Vector2 (Camera.transform.position.x, Camera.transform.position.y);
		var projectionPlayer = new Vector2 (Heroine.transform.position.x, Heroine.transform.position.y);
		var distance = Vector2.Distance (projectionCamera, projectionPlayer);
		var closeEnough = - float.Epsilon < distance && distance < float.Epsilon;

		if (!closeEnough)
		{
			var newPosition = Vector2.Lerp (
				projectionCamera,
				projectionPlayer,
				System.Math.Min(1.0f, FollowSpeed * Time.fixedDeltaTime));

			Camera.transform.position = new Vector3(newPosition.x, newPosition.y, CameraHeight);
		}
		else
		{
			if(CameraHeight - float.Epsilon < Camera.transform.position.z && Camera.transform.position.z < CameraHeight + float.Epsilon)
			{
			}
			else
			{
				Camera.transform.position = new Vector3(Camera.transform.position.x, Camera.transform.position.y, CameraHeight);
			}
		}

		Camera.transform.LookAt (Heroine.transform.position);
	}
}
