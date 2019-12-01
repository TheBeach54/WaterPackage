using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterImageEffect : MonoBehaviour {

    public Material mat;
	// Use this for initialization
	void Start () {
		
	}
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(mat != null)
        {
            mat.SetPass(0);
        Graphics.Blit(src, dest, mat, 0);
        }
    }
}
