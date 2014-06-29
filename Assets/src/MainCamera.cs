using UnityEngine;
using System.Collections;

public class MainCamera : MonoBehaviour
{
	public GameObject Heroine; 
	public GameObject Camera;
	public float DISTANCE_TO_HEROINE_MIN;

	void Start ()
	{
	
	}

	void FixedUpdate ()
	{
		var distance = Vector3.Distance (Camera.transform.position, Heroine.transform.position);
		var closeEnough = 
			DISTANCE_TO_HEROINE_MIN - float.Epsilon < distance &&
				distance < DISTANCE_TO_HEROINE_MIN + float.Epsilon;

		if (!closeEnough)
		{
			var h2c = Camera.transform.position - Heroine.transform.position;
			h2c.Normalize();
			var delta = h2c * DISTANCE_TO_HEROINE_MIN;
			var dest = Heroine.transform.position - Camera.transform.position + h2c;

			Camera.transform.position = Vector3.Lerp (
				Camera.transform.position,
				dest,
				0.5f * Time.fixedDeltaTime);
		}

		Camera.transform.LookAt (Heroine.transform);
	}
}
