using UnityEngine;
using System.Collections;

public class GroundManager : MonoBehaviour
{
    public GameObject CellPrefab;
    public int CellWidth = 10;
    public int CellHeight = 10;
    public static int XCellCount = 5;
    public static int YCellCount = 5;

    private GameObject[,] cells = new GameObject[XCellCount, YCellCount];

	void Start ()
	{
		for (int i = -XCellCount / 2; i < XCellCount / 2 + 1; i++)
		{
			for (int j = -YCellCount / 2; j < YCellCount / 2 + 1; j++)
			{
                Vector3 pos = new Vector3(i * CellWidth, j * CellHeight, 0);
                var cell = (GameObject)Instantiate(CellPrefab, pos, CellPrefab.transform.rotation);
                cells[i + YCellCount / 2, j + XCellCount / 2] = cell;
			}
		}
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
