using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetRigidBody : MonoBehaviour {

    Transform originalT;
    Rigidbody rb;
    Vector3 rbPos;
    Quaternion rbRot;
    

    // Use this for initialization
    void Start () {
        rb = GetComponent<Rigidbody>();
        rbPos = rb.position;
        rbRot = rb.rotation;
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetButtonDown("Jump"))
        {
            Debug.Log("Pos" + rbPos + "Rot" + rbRot);
            rb.transform.position = rbPos;
            rb.transform.rotation = rbRot;
        }
            
	}
}
