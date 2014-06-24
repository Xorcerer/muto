using UnityEngine;
using System.Collections;

public class GroundManager : MonoBehaviour
{
    public GameObject cellPrefab;
    public int CellWidth = 10;
    public int CellHeight = 10;
    public static int xCellCount = 5;
    public static int yCellCount = 5;
    private GameObject[,] cells = new GameObject[xCellCount, yCellCount];

	void Start ()
	{
		for (int i = -xCellCount / 2; i < xCellCount / 2 + 1; i++)
		{
			for (int j = -yCellCount / 2; j < yCellCount / 2 + 1; j++)
			{
                Vector3 pos = new Vector3(i * CellWidth, j * CellHeight, 0);
                var cell = (GameObject)Instantiate(cellPrefab, pos, cellPrefab.transform.rotation);
                cells[i + yCellCount / 2, j + xCellCount / 2] = cell;
			}
		}
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
