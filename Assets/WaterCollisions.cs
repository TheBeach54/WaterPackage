using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterCollisions : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
    
    void OnCollisionStay(Collision col)
    {
        foreach (ContactPoint contact in col.contacts)
        {
            Debug.DrawRay(contact.point, contact.normal, Color.white);
        }
    }	
	// Update is called once per frame
	void Update () {
		
	}
}
