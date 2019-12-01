using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class WaterSimulation : MonoBehaviour
{
    struct WaterUnit
    {
        public float relativeHeight;
        public float speed;
        public float foam;
    }

    public RenderTexture albedoWater;
    public RenderTexture normalWater;

    private WaterUnit[] waterArray1;
    private WaterUnit[] waterArray2;

    private bool currentArray;

    public ComputeShader renderWater;
    public ComputeShader simulateWater;

    private ComputeBuffer waterBuffer1;
    private ComputeBuffer waterBuffer2;

    private Vector2 m_noWhere = new Vector2(60000.0f,50000.0f);

    public int width = 1024;
    public int height = 1024;

    public int simulationWidth = 64;
    public int simulationHeight = 64;

    public float springStrength = 0.1f;
    [Range(0,1)]
    public float viscosity = 0.15f;

    public float neighbourSpeedAveraging = 0.2f;
    public float neighbourHeightAveraging = 0.7f;
    public float speedDifferenceToFoam = 2.0f;

    private float[] waveRadius = new float[4];
    public float waveBoost = 5.0f;

    private float[] waveHeight = new float[4];
    Vector3[] wavePosition = new Vector3[4];
    [Range(0, 0.5f)]
    public float borderMaskSize = 0.1f;


    private float waveAverageAmplitude = 0.0f;
    private GameObject m_camereGO;
    private Camera m_orthoCam;

    private CommandBuffer buf;


    public Material waterMaterial;
    private float gSteepness;
    private Vector4[] gWaves;
    private float dDispIntensity;

    public float collisionRenderNearClipBias = 6.0f;
    public float collisionRenderFarClipBias = 6.0f;

    private Rigidbody[] rigidbodies = new Rigidbody[4];

    Dictionary<int, Rigidbody> rbDictionary = new Dictionary<int, Rigidbody>();


    private Vector3 oldWaterPosition;
    private Vector3 newWaterPosition;



    private int numberCollisions = 0;
    private int currentCollision = 0;

    public Transform target;

    public Rigidbody rb;



   
    // Use this for initialization
    void Start()
    {



        if (waterMaterial != null)
        {

            gSteepness = waterMaterial.GetFloat("_GSteepness");
            gWaves = Shader.GetGlobalVectorArray("_GWaves");

            float[] wavesParam = new float[6 * 4];

            for(int i = 0; i < 6; i++ )
            {
                wavesParam[4 * i] = gWaves[i].x;
                waveAverageAmplitude += gWaves[i].x;
                wavesParam[4*i + 1] = gWaves[i].y;
                wavesParam[4*i + 2] = gWaves[i].z;
                wavesParam[4*i + 3] = gWaves[i].w;
            }

            simulateWater.SetFloats("_GWaves", wavesParam);
            waveAverageAmplitude *= (1.0f / (float)6.0f);
        }


        m_camereGO = new GameObject("orthoDepthCam_");

        m_orthoCam = m_camereGO.AddComponent<Camera>();
        m_orthoCam.enabled = false;
        m_orthoCam.orthographic = true;
        m_orthoCam.aspect = 1.0f;
        m_orthoCam.nearClipPlane = 1.0f;
        m_orthoCam.farClipPlane = waveAverageAmplitude*2.0f + collisionRenderFarClipBias + collisionRenderNearClipBias;
        m_orthoCam.orthographicSize = transform.lossyScale.x*0.5f;
        m_orthoCam.SetReplacementShader(Shader.Find("Beach/Replacement_GetDepthFrontFace"), "RenderType");
        m_orthoCam.clearFlags = CameraClearFlags.Color;
        m_orthoCam.backgroundColor = new Color(200.0f, 200.0f,200.0f,200.0f);

        Debug.Log(m_orthoCam.backgroundColor);

        SetupCommandBuffer();

        oldWaterPosition = transform.position;


        for (int i = 0; i < wavePosition.Length; i++)
        {
            wavePosition[i] = m_noWhere;

        }
        for (int i = 0; i < waveRadius.Length; i++)
        {
            waveRadius[i] = 0.0f;

        }


        InitWaterArray(out waterArray1, out waterBuffer1);
        InitWaterArray(out waterArray2, out waterBuffer2);

        albedoWater = new RenderTexture(width, height, 0,
            RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.sRGB);
        albedoWater.enableRandomWrite = true;
        albedoWater.Create();
        normalWater = new RenderTexture(width, height, 0,
            RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
        normalWater.enableRandomWrite = true;
        normalWater.Create();

        MeshRenderer mRenderer = GetComponent<MeshRenderer>();
        mRenderer.sharedMaterial.SetTexture("_DynamicHeight", albedoWater);
        mRenderer.sharedMaterial.SetTexture("_DynamicBump", normalWater);
    }

    void SetupCommandBuffer()
    {
        buf = new CommandBuffer();
        buf.name = "Grab screen for water collision";

        // copy screen into temporary RT
        int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        buf.GetTemporaryRT(screenCopyID, simulationWidth, simulationHeight, 0, FilterMode.Point,RenderTextureFormat.ARGBFloat);
        buf.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);
        buf.SetGlobalTexture("_OrthoCollisionsTex", screenCopyID);

        m_orthoCam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, buf);
    }

    // Update is called once per frame
    void Update()
    {


        //Vector3 offset = target.position - transform.position;
        //offset = new Vector3(Mathf.Round(offset.x * simulationWidth) / simulationWidth, 0.0f, Mathf.Round(offset.z * simulationHeight)/simulationHeight);
        //transform.position = new Vector3(transform.position.x + offset.x, transform.position.y, transform.position.z + offset.z);
        //transform.position = new Vector3(target.position.x, transform.position.y, target.position.z );

        float simW = (float)simulationWidth;
        float simH = (float)simulationHeight;

        Vector3 offset = target.position - transform.position;
        float scale = transform.lossyScale.x;
        float offX = Mathf.Ceil(offset.x * simW / scale);
        float offY = Mathf.Ceil(offset.z * simH / scale);
        float wOffX = offX *scale / simW;
        float wOffY = offY *scale / simW;

        offset = new Vector3(offX, 0.0f, offY);
        Vector3 offsetWorld = new Vector3(wOffX, 0.0f, wOffY);

        Vector3 newWorldPos = new Vector3(transform.position.x + offsetWorld.x, transform.position.y, transform.position.z + offsetWorld.z);

        //        Debug.Log(offset + "sinW : " + simW + "scale : " + scale + "world :" + offsetWorld);

        m_orthoCam.Render();


        if (currentArray)
        {
            simulateWater.SetBuffer(0, "readBuffer", waterBuffer1);
            simulateWater.SetBuffer(0, "writeBuffer", waterBuffer2);
            renderWater.SetBuffer(0, "simulationBuffer", waterBuffer2);
        }
        else
        {
            simulateWater.SetBuffer(0, "readBuffer", waterBuffer2);
            simulateWater.SetBuffer(0, "writeBuffer", waterBuffer1);
            renderWater.SetBuffer(0, "simulationBuffer", waterBuffer1);
        }

        currentArray = !currentArray;

      //  Debug.Log("dT" + Time.deltaTime);
        simulateWater.SetFloat("deltaTime", Time.deltaTime);
        simulateWater.SetFloat("time", Time.time);

        simulateWater.SetInt("simulationWidth", simulationWidth);
        simulateWater.SetInt("simulationHeight", simulationHeight);
        simulateWater.SetFloat("springStrength", springStrength);
        simulateWater.SetFloat("viscosity", viscosity);
        simulateWater.SetFloat("neighbourSpeedAveraging", neighbourSpeedAveraging);
        simulateWater.SetFloat("neighbourHeightAveraging", neighbourHeightAveraging);
        simulateWater.SetFloat("speedDifferenceToFoam", speedDifferenceToFoam);
        
        simulateWater.SetFloat("waveHeight", waveHeight[0]);
        simulateWater.SetFloat("waveHeight2", waveHeight[1]);
        simulateWater.SetFloat("waveHeight3", waveHeight[2]);
        simulateWater.SetFloat("waveHeight4", waveHeight[3]);
        simulateWater.SetFloat("waveRadius", waveRadius[0]);
        simulateWater.SetFloat("waveRadius2", waveRadius[1]);
        simulateWater.SetFloat("waveRadius3", waveRadius[2]);
        simulateWater.SetFloat("waveRadius4", waveRadius[3]);
        simulateWater.SetFloat("borderMaskSize", borderMaskSize);
        
        simulateWater.SetVector("wavePosition", wavePosition[0]);
        simulateWater.SetVector("wavePosition2", wavePosition[1]);
        simulateWater.SetVector("wavePosition3", wavePosition[2]);
        simulateWater.SetVector("wavePosition4", wavePosition[3]);
        simulateWater.SetVector("waterPosition", new Vector4(transform.position.x, 
                                                               transform.position.y,
                                                               transform.position.z, 
                                                               transform.lossyScale.x));


        simulateWater.SetTextureFromGlobal(0,"_OrthoCollisionsTex", "_OrthoCollisionsTex");


        simulateWater.SetVector("offset", offset);
        simulateWater.SetVector("oldWaterPosition", oldWaterPosition);

        simulateWater.Dispatch(0, simulationWidth * simulationHeight / 32, 1, 1);

        renderWater.SetInt("simulationWidth", simulationWidth);
        renderWater.SetInt("simulationHeight", simulationHeight);
        renderWater.SetTexture(0, "albedo", albedoWater);
        renderWater.SetTexture(0, "normal", normalWater);

        renderWater.Dispatch(0, width / 8, height / 8, 1);

        transform.position = newWorldPos;
        m_orthoCam.transform.SetPositionAndRotation(transform.position - Vector3.up * (waveAverageAmplitude + collisionRenderNearClipBias), Quaternion.LookRotation(Vector3.up, Vector3.forward));






        oldWaterPosition = transform.position;


    }
    void LateUpdate()
    {


    }


    void InitWaterArray(out WaterUnit[] array, out ComputeBuffer buffer)
    {
        int unitCount = simulationWidth * simulationHeight;
        array = new WaterUnit[unitCount];
        for (int i = 0; i < unitCount; i++)
        {
            array[i].relativeHeight = 0.0f;
            array[i].speed = 0.0f;
            array[i].foam = 0.0f;
        }

        buffer = new ComputeBuffer(unitCount, 12);
        buffer.SetData(array);
    }

    void FixedUpdate()
    {
        UpdateWavePos();



    }

    void UpdateWavePos()
    {
        int i = 0;
        foreach (KeyValuePair<int, Rigidbody> entry in rbDictionary)
        {
            if (entry.Value != null)
            {

                Vector3 tempPos = entry.Value.position;
                float tempHeight = entry.Value.velocity.magnitude;


                //if (tempHeight < 0.01f)
                //{
                //    tempHeight = 0.0f;
                //    wavePosition[i] = m_noWhere;
                //}
                // else
                wavePosition[i] = tempPos;

                var sphereCol = entry.Value.GetComponent<SphereCollider>();

                Debug.DrawLine(tempPos, tempPos + sphereCol.radius * sphereCol.transform.lossyScale.y * sphereCol.transform.up);
                waveRadius[i] = sphereCol.radius * sphereCol.transform.lossyScale.y;

                // Debug.Log("height : " + tempHeight + " id : " + entry.Key + "radius : " + waveRadius[i]);

                if (entry.Value.isKinematic)
                    waveHeight[i] = waveBoost;
                else
                    waveHeight[i] = Mathf.Max(Mathf.InverseLerp(0.0f, 2.0f, tempHeight), 0.1f) * waveBoost;
                //   waveHeight[i] = waveBoost;


                i++;
                if (i >= wavePosition.Length)
                    break;
            }

        }
    }

    void OnTriggerEnter(Collider col)
    {
        var rb = col.GetComponent<Rigidbody>();
        int id = rb.GetInstanceID();


        if (col as MeshCollider == null)
            if (!rbDictionary.ContainsKey(id))
                rbDictionary.Add(id, rb);







    }
    void OnTriggerExit(Collider col)
    {
        var rb = col.GetComponent<Rigidbody>();
        int id = rb.GetInstanceID();



        if (rbDictionary.ContainsKey(id))
            rbDictionary.Remove(id);


    }

    void OnDestroy()
    {
        albedoWater.Release();
        normalWater.Release();
        waterBuffer1.Dispose();
        waterBuffer2.Dispose();
    }
}
