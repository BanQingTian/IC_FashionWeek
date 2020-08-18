using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotSimpleUP : MonoBehaviour {

    public float speed = 20;
	
	// Update is called once per frame
	void Update () {
        this.transform.Rotate(Vector3.up, Time.deltaTime * speed, Space.World);
    }
}
