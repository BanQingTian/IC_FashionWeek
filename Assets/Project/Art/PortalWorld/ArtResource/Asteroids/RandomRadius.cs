using UnityEngine;  
using System.Collections;  

public class RandomRadius : MonoBehaviour {  
	public GameObject prefabs;  
	public Transform m_Root;
	public float r = 100;
	// Use this for initialization  
	void Start () {  
		for (int i = 0; i < 200; i++) {  
			Vector2 p = Random.insideUnitCircle*r;  
			Vector2 pos = p.normalized*(2+p.magnitude);  
			Vector3 pos2 = new Vector3(pos.x,0,pos.y);  
			Instantiate(prefabs,pos2,Quaternion.identity);  

			//Vector3 pos3 = Random.insideUnitSphere * r;
			//Instantiate (prefabs, pos3, Quaternion.identity);
		}  
	}  

	// Update is called once per frame  
	void Update () {  

	}  
}  