using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PassSun : MonoBehaviour {

    public Light _directional;


	
	// Update is called once per frame
	void Update () {
        if(_directional != null)
        {
        Shader.SetGlobalVector("_SunDir", -_directional.transform.forward);
        Shader.SetGlobalVector("_SunColor", _directional.color * _directional.intensity);

        }
    }
}
