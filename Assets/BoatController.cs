using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class BoatController : MonoBehaviour {

    Rigidbody rb;
    public Transform camPos;
    public Transform pushPos;
    public Camera cam;
    public float speed = 5.0f;
    public float acceleration = 5.0f;
    public float speedTorque = 1.0f;
    public float speedStabilize = 1.0f;
    
    public bool dontUsePhysics = false;
    public float positionBias = 0.0f;
    public float forceForward = 5.0f;
    public float drag;

    float m_torqueAngle;
    float m_currentSpeed;

    private Vector3 DebugForward;
    private Vector3 DebugNormal;

    private float camH;

    private Buoyancy buoy;

    public float camSpeed;
    void Start()
    {
        rb = GetComponent<Rigidbody>();

        if (rb == null)
            rb = gameObject.AddComponent<Rigidbody>();

        drag = rb.drag;

        buoy = GetComponent<Buoyancy>();

        camH = camPos.position.y;

        if (pushPos == null)
            pushPos = transform;
    }
	// Update is called once per frame
	void Update () {






    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawLine(transform.position, transform.position +DebugForward * 4.0f);
        Gizmos.DrawLine(transform.position, transform.position +DebugNormal * 4.0f);
    }

    void FixedUpdate()
    {
        Vector3 gNormal = buoy.GetAverageGrestnerNormal(transform.position);

        m_torqueAngle += Input.GetAxis("Horizontal") * speedTorque;
        rb.MoveRotation(Quaternion.Lerp(transform.rotation, Quaternion.AngleAxis(m_torqueAngle, gNormal), Time.fixedDeltaTime * speedStabilize));


        if (dontUsePhysics)
        {

            if (buoy.GetInWater())
            {

                Quaternion q = Quaternion.Euler(transform.up);
                Quaternion qq = Quaternion.Euler(gNormal);


                // Vector3 gTangent = Vector3.Cross(gNormal, rb.transform.forward);
                //Vector3 gForward = Vector3.Cross(gNormal, rb.transform.right);
                Vector3 forPos = transform.position + Vector3.ProjectOnPlane(transform.forward, Vector3.up) * 4.0f;
                Vector3 forNewPos = new Vector3(forPos.x, buoy.GetGrestnerWavePos(forPos), forPos.z);
                Vector3 newPos = new Vector3(transform.position.x, buoy.GetGrestnerWavePos(transform.position), transform.position.z);
                Vector3 gForward = (forNewPos - transform.position).normalized;

                if (Vector3.Dot(gForward, Vector3.up) < 0.0f)
                    gForward = transform.forward;

                DebugForward = gForward;
                DebugNormal = gNormal;

                m_currentSpeed += (Time.fixedDeltaTime * Input.GetAxis("Vertical") * acceleration);
                transform.position = (newPos + gForward * m_currentSpeed);
                //rb.AddRelativeTorque(gNormal * speedTorque * Input.GetAxis("Horizontal"), ForceMode.Acceleration);
            }

            m_currentSpeed = Mathf.Lerp(m_currentSpeed, 0.0f, Time.fixedDeltaTime * drag);
            transform.position = transform.position + Physics.gravity * Time.fixedDeltaTime + transform.forward * m_currentSpeed;

            if (Mathf.Abs(m_currentSpeed) > speed)
                m_currentSpeed = speed * Mathf.Sign(m_currentSpeed);

        }
                else
        {

            if (buoy.GetInWater())
            {

                // Vector3 gTangent = Vector3.Cross(gNormal, rb.transform.forward);
                //Vector3 gForward = Vector3.Cross(gNormal, rb.transform.right);
                Vector3 forPos = transform.position + Vector3.ProjectOnPlane(transform.forward, Vector3.up) * 4.0f;
                Vector3 forNewPos = new Vector3(forPos.x, buoy.GetGrestnerWavePos(forPos), forPos.z);
                Vector3 gForward = (forNewPos - transform.position).normalized;

                if (Vector3.Dot(gForward, Vector3.up) < 0.0f)
                    gForward = Vector3.ProjectOnPlane(transform.forward, Vector3.up);

                DebugForward = gForward;
                DebugNormal = gNormal;

                rb.AddForceAtPosition(gForward * forceForward * Input.GetAxis("Vertical"), pushPos.position, ForceMode.Acceleration);
            }
        }




    }

    void LateUpdate()
    {
        if (camPos != null)
        {
            Vector3 toPos = (camPos.transform.position - cam.transform.position);

            float distance = toPos.magnitude;
            if (cam != null)
            {
                
                cam.transform.position = Vector3.Lerp(cam.transform.position,camPos.transform.position,Time.deltaTime * camSpeed);
                cam.transform.position = new Vector3(cam.transform.position.x, camH, cam.transform.position.z);
                Quaternion Q = cam.transform.rotation;
                cam.transform.LookAt(rb.transform.position + transform.forward*20.0f);
                cam.transform.rotation = Quaternion.Lerp(Q, cam.transform.rotation, Time.deltaTime * camSpeed);
            }
        }
    }
}
