using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PosSimpleUpDown : MonoBehaviour {

    public float upDownSpeed = 1f;
    public float rotSpeed = 0.6f;
    public float rotStep = 0.3f;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        this.transform.localPosition += new Vector3(0, Mathf.Sin(Time.time* upDownSpeed) *0.02f, 0);
        this.transform.Rotate(Vector3.forward, Mathf.Sin(Time.time * rotSpeed) * rotStep, Space.World);
    }
}
