using System.Collections; 
using System.Collections.Generic;
using UnityEngine;
using UnityMathReference;

public class WaterPostEffect : MonoBehaviour
{
    private new Camera camera;
    private new Transform transform;
    public ComputeShader shadowCompute;
    public RenderTexture shadowTexture;
    [Range(0.0f,1.0f)] public float fogDensity = 0.01f;
    public float fogHeight = 50.0f;
    
    public float fogHeightFalloff = 50.0f;
    public Color fogColor = new Color(0.5f, 0.5f, 0.7f);
    public float fogFreq = 1.0f;
    public Vector3 fogFrequency = new Vector3(1.0f, 1.0f, 1.0f);
    public Vector4 windParam = new Vector4(1.0f, 0.0f, 0.0f, 1.0f);
    public float fogNoiseStrength = 1.0f;
    public float fogNoisePow = 1.0f;
    public float fogScatter = 1.0f;
    public float fogRefract = 1.0f;
    [Range(0.0f, 10.0f)]
    public float fogAbsorbance = 0.1f;
    public float fogTransmittance = 0.1f;
    public int width = 64;
    public int height = 48;
    public int iteration = 64;
  public Material material;

    private void Start()
    {
        camera = GetComponent<Camera>();
        transform = GetComponent<Transform>();
        material = new Material(Shader.Find("Beach/PE_VolumetricFog"));


        shadowTexture = new RenderTexture(width, height, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.sRGB);
        shadowTexture.enableRandomWrite = true;
        shadowTexture.Create();
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // NOTE: VR doesn't seem to work. Why is unity's camera projection matrix so inconsistent?

        //var clipToWorld = (camera.projectionMatrix * camera.worldToCameraMatrix).inverse;// << Is there a way to make this method work indead?

        // NOTE: code was ported from: https://gamedev.stackexchange.com/questions/131978/shader-reconstructing-position-from-depth-in-vr-through-projection-matrix
        // More clerification of whats going on is needed!


        var p = GL.GetGPUProjectionMatrix(camera.projectionMatrix, false);// Unity flips its 'Y' vector depending on if its in VR, Editor view or game view etc... (facepalm)
        p[2, 3] = p[3, 2] = 0.0f;
        p[3, 3] = 1.0f;
        var clipToWorld = Matrix4x4.Inverse(p * camera.worldToCameraMatrix) * Matrix4x4.TRS(new Vector3(0, 0, -p[2, 2]), Quaternion.identity, Vector3.one);
        material.SetMatrix("clipToWorld", clipToWorld);
        Shader.SetGlobalMatrix("clipToWorld", clipToWorld);
        Shader.SetGlobalMatrix("camToWorld", camera.projectionMatrix.inverse );
        Shader.SetGlobalFloat("_FogDensity", Mathf.Pow(fogDensity,3.0f));
        Shader.SetGlobalFloat("_FogHeight", fogHeight); 
        Shader.SetGlobalFloat("_FogHeightFalloff", fogHeightFalloff);
        Shader.SetGlobalFloat("_FogNoisePower", fogNoisePow);
        Shader.SetGlobalVector("_FogColor", new Vector3(fogColor.r, fogColor.g, fogColor.b)); 
        Shader.SetGlobalVector("_FogNoiseFrequency",fogFrequency * fogFreq);
        Shader.SetGlobalFloat("_FogNoiseStrength", fogNoiseStrength); 
        Shader.SetGlobalVector("_WindParam", windParam); 

          Texture map = Shader.GetGlobalTexture("_SunCascadedShadowMap");
        if (shadowTexture != null && map != null)
        {

            Shader.SetGlobalTexture("_VolumetricShadowTex", shadowTexture);


            shadowCompute.SetVector("_CamPos", camera.transform.position);
            shadowCompute.SetTexture(0, "_VolumetricShadowTex", shadowTexture);
            shadowCompute.SetTexture(0, "_SunCascadedShadowMap", map);
            shadowCompute.SetVector("cameraHeading", camera.transform.forward);
            shadowCompute.SetFloat("_FogDensity", Mathf.Pow(fogDensity, 3.0f));
            shadowCompute.SetFloat("_FogAbsorbance", fogAbsorbance);
            shadowCompute.SetFloat("_FogTransmittance", fogTransmittance);
            
            shadowCompute.SetFloat("_FogHeight", fogHeight);
            shadowCompute.SetFloat("_FogScatter", fogScatter);
            shadowCompute.SetFloat("_FogRefract", fogRefract);
            shadowCompute.SetFloat("zFar", camera.farClipPlane);
            shadowCompute.SetFloat("zNear", camera.nearClipPlane);
            shadowCompute.SetInt("_It", iteration);
            shadowCompute.SetInt("width", width);
            shadowCompute.SetInt("height", height);

            shadowCompute.Dispatch(0, width / 32, height / 32, 1);
        }


        Graphics.Blit(source, destination, material);

    }

    void Update()
    {

    }

    public void ChangeMaterial(Material newMat, Shader newS)
    {
        material.CopyPropertiesFromMaterial(newMat);
        material.shader = newS;

    }
}