using UnityEngine;
using System.Collections;

public class TakeScreenshot : MonoBehaviour
{
    public Camera[] _Cam;

    public bool m_takeScreen;
    int count = 0;
    bool needScreen;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F7))
        {
            needScreen = true;
            StartCoroutine(ShotEveryCamera());


        }

    }
    IEnumerator ShotEveryCamera()
    {
      
            foreach (Camera cam in _Cam)
            {
                cam.gameObject.SetActive(true);
                cam.depth = 100;
                count++;
                ScreenCapture.CaptureScreenshot(Application.dataPath + "/Screenshots/Screenshot" + count + ".png", 4);
                Debug.Log(Application.dataPath + "/Screenshots/Screenshot_" + System.DateTime.Now.ToString() + ".png");
                m_takeScreen = false;
                yield return null;
                cam.depth = 0;
            }

        
        
    }
}
