using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NRKernal;

public class ZMain : MonoBehaviour
{
    [Space(12)]
    public DeviceTypeEnum DeviceType;

    [Space(12)]
    public LanguageEnum LanguageType;

    [Space(12)]
    public ZScanMarker MarkerHelper;

    [Space(12)]
    public string IPAdress = "127.0.0.1";

    [HideInInspector]
    public bool IS_MATCH = false;

    void Start()
    {
        Begin();
    }

    void Update()
    {
#if UNITY_EDITOR
        if (Input.GetKeyDown(KeyCode.R))
        {
            Time.timeScale = 5;
        }
        if (Input.GetKeyUp(KeyCode.R))
        {
            Time.timeScale = 1;
        }

#endif

        if (!IS_MATCH)
        {
            if (MarkerHelper.MarkerTrackingUpdate())
            {
                IS_MATCH = true;
            }
        }
    }

    private void Begin()
    {
        deviceCheck();

        LoadManager();
        LoadLocalization();
        LoadNetworkingModule();
    }

    private void deviceCheck()
    {
        Global.DeviceType = DeviceType;

        if (DeviceType == DeviceTypeEnum.NRLight)
        {
            var nrCam = GameObject.Find("NRCameraRig");
            var nrInput = NRInput.AnchorsHelper.GetAnchor(ControllerAnchorEnum.RightModelAnchor);
            ZClient.Instance.Model = nrCam;
            ZClient.Instance.Controller = nrInput;
            ZClient.Instance.extraContent = "";

        }
        else if (DeviceType == DeviceTypeEnum.Pad)
        {
            var arCam = GameObject.Find("First Person Camera");
            ZClient.Instance.Model = arCam;
        }
    }

    public void LoadManager()
    {
        GameManager.Instance.Init(this);
    }

    public void LoadLocalization()
    {
        Global.Languge = LanguageType;
        // ZLocalizationHelper.Instance.Switch(LanguageType);
    }



    // 网络所需组件，实例化网络组件
    public void LoadNetworkingModule()
    {
        ZMessageManager.Instance.Init();
        ZMessageManager.Instance.SendConnectAndJoinRoom(IPAdress, "50010"); //192.168.0.33 //192.168.69.39
    }


}
