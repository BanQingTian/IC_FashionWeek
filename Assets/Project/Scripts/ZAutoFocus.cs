using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZAutoFocus : MonoBehaviour {

    private bool autoFocusSet;
    void Awake()
    {
        autoFocusSet = false;
    }
    public static bool enableAutoFocus()
    {
        AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject currentActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
        AndroidJavaClass metaioSDKAndroid = new AndroidJavaClass("com.metaio.sdk.jni.IMetaioSDKAndroid");
        object[] args = { currentActivity };
        AndroidJavaObject camera = metaioSDKAndroid.CallStatic<AndroidJavaObject>("getCamera", args);

        if (camera != null)
        {
            AndroidJavaObject cameraParameters = camera.Call<AndroidJavaObject>("getParameters");
            object[] focusMode = { cameraParameters.GetStatic<string>("FOCUS_MODE_CONTINUOUS_PICTURE") };
            cameraParameters.Call("setFocusMode", focusMode);
            object[] newParameters = { cameraParameters };
            camera.Call("setParameters", newParameters);
            return true;
        }
        else
        {
            Debug.LogError("metaioSDK.enableAutoFocus:Camera not available");
            return false;
        }
    }

    bool clkOnce = false;
    float _time = 0;
    void Update()
    {
        //if (Input.GetKeyDown(KeyCode.Escape) || Input.GetKeyDown(KeyCode.Home))
        //{
        //    Application.Quit();
        //}

        if(Global.DeviceType == DeviceTypeEnum.Pad)
        {
            if(Input.touchCount == 1 && !clkOnce)
            {
                clkOnce = true;
            }
            if (_time < 0.7f)
            {
                if(Input.touchCount == 1)
                {
                    autoFocusSet = enableAutoFocus();
                    _time = 0;
                    clkOnce = false;
                }
            }
            else
            {
                _time = 0;
                clkOnce = false;
            }
            _time += Time.deltaTime;
        }

        if (Global.DeviceType == DeviceTypeEnum.Pad &&  Input.touchCount == 2)
        {
            if (Input.touches[0].phase == TouchPhase.Began
                && Input.touches[1].phase == TouchPhase.Began)
            {
                
            }
        }
    }
}
