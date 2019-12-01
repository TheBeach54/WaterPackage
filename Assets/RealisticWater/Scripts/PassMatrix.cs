using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PassMatrix : MonoBehaviour {

    private Camera cam;
    private MeshRenderer mR;
	// Use this for initialization
	void Start () {
        cam = Camera.current;
        mR = GetComponent<MeshRenderer>();
    }
	
	// Update is called once per frame
	void OnWillRenderObject () {

            cam = Camera.current;


        //matrix = cam.projectionMatrix.inverse;
        //matrix2 = cam.worldToCameraMatrix.inverse;
        if(cam != null)
        {
            if(Application.isEditor && cam != null && mR != null)
            {
                mR.sharedMaterial.SetMatrix("_ProjectInverse", cam.projectionMatrix.inverse);
                mR.sharedMaterial.SetMatrix("_ViewInverse", cam.worldToCameraMatrix.inverse);
            }
            else if (cam != null && mR != null)
            {
                mR.material.SetMatrix("_ProjectInverse", cam.projectionMatrix.inverse);
                mR.material.SetMatrix("_ViewInverse", cam.worldToCameraMatrix.inverse);
            }
            //Shader.SetGlobalMatrix("_ProjectInverse", cam.projectionMatrix.inverse);
            //Shader.SetGlobalMatrix("_ViewInverse", cam.worldToCameraMatrix.inverse);

        }
    }
}
