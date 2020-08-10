using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Global
{

    public static LanguageEnum Languge = LanguageEnum.EN;

    public static DeviceTypeEnum DeviceType = DeviceTypeEnum.NRLight;

    public const float FrameRate = 30;


    public static string GetName()
    {
        return DeviceType == DeviceTypeEnum.Pad ? "arcore" : "nreal";
    }

}

public enum LanguageEnum
{
    EN = 0,
    CH = 1,
    KR = 2,
}

public enum DeviceTypeEnum
{
    Pad = 0,
    NRLight = 1,
}
