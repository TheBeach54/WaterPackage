using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterEffector : MonoBehaviour {

    Vector3 oldPos;
    Material mat;
	// Update is called once per frame

    void Start()
    {
        oldPos = transform.position;
        mat = GetComponent<MeshRenderer>().material;

    }
	void Update () {

        float speed = (transform.position - oldPos).magnitude/ Time.deltaTime;

        if(mat != null)
        mat.SetFloat("_ObjVelocity", speed);



        oldPos = transform.position;

	}
}
