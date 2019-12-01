using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;

// See _ReadMe.txt for an overview
[ExecuteInEditMode]
public class WaterRenderer : MonoBehaviour
{
    static int s_blur = 0;
    public bool refreshBuffer = false;
    public bool useBlur = false;
    float blurS = 1;
    private bool oldUseBlur;

    public Shader m_BlurShader;
    private Material m_Material;
    private Material m_WaterMaterial;
    private MeshRenderer m_Renderer;

    public WaterSimulation waterSimulation;

    private Camera m_Cam;

    [System.Serializable]
    public class GrestnerWaves
    {
        public float m_amplitude;
        public float m_wavelength;
        public float m_phase;
        public float m_direction;
        public bool m_useCircular;
        public Vector2 m_position;

    }


    public GrestnerWaves[] gWaves;
    private Vector4[] gWavesVector;
    private Vector4[] gWavesPos;


    public bool updatePostEffect;

    // We'll want to add a command buffer on any camera that renders us,
    // so have a dictionary of them.
    private Dictionary<Camera, CommandBuffer> m_Cameras = new Dictionary<Camera, CommandBuffer>();


    void OnTriggerEnter(Collider col)
    {
        WaterPostEffect currentPE = col.gameObject.GetComponent<WaterPostEffect>();

        if (currentPE != null)
        {
            Shader currentS = currentPE.material.shader;
            currentPE.ChangeMaterial(m_WaterMaterial, currentS);
            currentPE.material.SetVector("_WaterPosition", transform.position);
           Shader.SetGlobalVector("_WaterPosition", transform.position);

        }
    }


    void OnTriggerStay(Collider col)
    {
        if(updatePostEffect)
        {
            WaterPostEffect currentPE = col.gameObject.GetComponent<WaterPostEffect>();

            if (currentPE != null)
            {
                Shader currentS = currentPE.material.shader;
                currentPE.ChangeMaterial(m_WaterMaterial, currentS);
                currentPE.material.SetVector("_WaterPosition", transform.position);
            }
        }

    }


    void Start()
    {
        // Debug.Log("start");


        m_BlurShader = Shader.Find("Hidden/SeparableGlassBlur");

        oldUseBlur = useBlur;
        m_Renderer = GetComponent<MeshRenderer>();
        if (Application.isEditor)
        {
            m_WaterMaterial = m_Renderer.sharedMaterial;

        }
        else
        {
            m_WaterMaterial = m_Renderer.material;

        }

        if (useBlur)
        {
            s_blur++;
            m_WaterMaterial.EnableKeyword("_BLUR_REFRACTION");
        }
        else
        {
            s_blur--;
            m_WaterMaterial.DisableKeyword("_BLUR_REFRACTION");

        }


        gWavesVector = new Vector4[gWaves.Length];
        gWavesPos = new Vector4[gWaves.Length];

        UpdateGWaves();

    }

    private void UpdateGWaves()
    {
        
        for(int i = 0; i < gWaves.Length; i++)
        {

            gWaves[i].m_amplitude = Mathf.Max(gWaves[i].m_amplitude, 0.001f);
            gWaves[i].m_wavelength = Mathf.Max(gWaves[i].m_wavelength, 0.005f);

            



            if(gWaves[i].m_useCircular)
            {
                gWavesVector[i] = new Vector4(gWaves[i].m_amplitude,
                                            gWaves[i].m_wavelength,
                                            gWaves[i].m_phase,
                                            500.0f);

                gWavesPos[i] = new Vector4(gWaves[i].m_position.x, gWaves[i].m_position.y,0.0f,0.0f);

            }
            else
            {

                gWavesVector[i] = new Vector4(gWaves[i].m_amplitude,
                                                gWaves[i].m_wavelength,
                                                gWaves[i].m_phase,
                                                gWaves[i].m_direction);

                gWavesPos[i] = Vector4.zero;
            }



        }



        if (gWavesVector.Length != 0)
            Shader.SetGlobalVectorArray("_GWaves", gWavesVector);

        if (gWavesPos.Length != 0)
            Shader.SetGlobalVectorArray("_GWavesPos", gWavesPos);
    }

    // Remove command buffers from all cameras we added into
    private void Cleanup()
    {
        foreach (var cam in m_Cameras)
        {
            if (cam.Key)
            {
                cam.Key.RemoveCommandBuffer(CameraEvent.BeforeForwardAlpha, cam.Value);
            }
        }
        m_Cameras.Clear();
        Object.DestroyImmediate(m_Material);
    }

    void Update()
    {

        UpdateGWaves();

        if (waterSimulation != null)
            m_WaterMaterial.SetVector("_SimulationPosition", new Vector4(waterSimulation.transform.position.x, waterSimulation.transform.position.y, waterSimulation.transform.position.z, waterSimulation.transform.lossyScale.x));

        

        m_WaterMaterial.SetVector("_WaterPosition", transform.position);
        Shader.SetGlobalFloat("_WaveTime", Time.time);

        if (oldUseBlur != useBlur)
        {
            if (useBlur)
            {
                s_blur++;
                m_WaterMaterial.EnableKeyword("_BLUR_REFRACTION");
            }
            else
            {
                s_blur--;
                m_WaterMaterial.DisableKeyword("_BLUR_REFRACTION");

            }

            

            oldUseBlur = useBlur;

        }

        if (refreshBuffer)
        {

            Cleanup();
            refreshBuffer = false;
        }
    }


    public void OnEnable()
    {
        if (useBlur)
            s_blur++;

        Cleanup();
    }

    public void OnDisable()
    {
        if (useBlur)
            s_blur--;

        Cleanup();
    }


    // Whenever any camera will render us, add a command buffer to do the work on it
    public void OnWillRenderObject()
    {


        var act = gameObject.activeInHierarchy && enabled;
        if (!act)
        {
            Cleanup();
            return;
        }

        var cam = Camera.current;
        if (!cam)
            return;

        if (cam != null)
        {

                Shader.SetGlobalMatrix("_ProjectInverse", cam.projectionMatrix.inverse);
                Shader.SetGlobalMatrix("_ViewInverse", cam.worldToCameraMatrix.inverse);
                

        }


        if (s_blur <= 0 && oldUseBlur == useBlur)
        {
            Cleanup();
            return;
        }

        


            CommandBuffer buf = null;
        // Did we already add the command buffer on this camera? Nothing to do then.
        if (m_Cameras.ContainsKey(cam))
            return;

        if (cam.commandBufferCount >= 1)
            return;

        if (!m_Material)
        {
            
            m_Material = new Material(m_BlurShader);

         
            m_Material.hideFlags = HideFlags.HideAndDontSave;
        }

        buf = new CommandBuffer();
        buf.name = "Grab screen and blur";
        m_Cameras[cam] = buf;

        // copy screen into temporary RT
        int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        buf.GetTemporaryRT(screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        buf.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);

        int blurredID = Shader.PropertyToID("_Temp1");
        int blurredID2 = Shader.PropertyToID("_Temp2");
        buf.GetTemporaryRT(blurredID, -1, -1, 0, FilterMode.Bilinear);
        buf.GetTemporaryRT(blurredID2, -1, -1, 0, FilterMode.Bilinear);

        // downsample screen copy into smaller RT, release screen RT
        buf.Blit(screenCopyID, blurredID);
        buf.ReleaseTemporaryRT(screenCopyID);

        // horizontal blur
        buf.SetGlobalVector("offsets", new Vector4(2.0f / Screen.width, 0, 0, 0)* blurS);
        buf.Blit(blurredID, blurredID2, m_Material);
        // vertical blur
        buf.SetGlobalVector("offsets", new Vector4(0, 2.0f / Screen.height, 0, 0) * blurS);
        buf.Blit(blurredID2, blurredID, m_Material);
        // horizontal blur
        buf.SetGlobalVector("offsets", new Vector4(4.0f / Screen.width, 0, 0, 0) * blurS);
        buf.Blit(blurredID, blurredID2, m_Material);
        // vertical blur
        buf.SetGlobalVector("offsets", new Vector4(0, 4.0f / Screen.height, 0, 0) * blurS);
        buf.Blit(blurredID2, blurredID, m_Material);



        
        buf.SetGlobalTexture("_GrabBlurTexture", blurredID);

        cam.AddCommandBuffer(CameraEvent.BeforeForwardAlpha, buf);
    }
}
