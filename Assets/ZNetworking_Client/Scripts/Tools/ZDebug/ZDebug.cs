using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ZDebug : MonoBehaviour
{
    public enum ZLogEnum
    {
        Normal = 0,
        Warning,
        Error,
    }

    public bool DebugLog;
    public bool ShowDebugScreen;
    
    [SerializeField]
    private Text extraInfoText;

    private string m_ExtraInfoStr;
    private int m_MaxLine = 20;

    private static ZDebug Instance;

    private void Awake()
    {
        Instance = this;
        if (!DebugLog || !ShowDebugScreen)
        {
            extraInfoText.enabled = false;
        }
    }

    private void Update()
    {
        if (ShowDebugScreen)
            RefreshInfoTexts();
    }

    private void RefreshInfoTexts()
    {
        //mainInfoText.text
        extraInfoText.text = m_ExtraInfoStr;
    }

    private void displayDebugLog(string infoStr,ZLogEnum logType)
    {
        switch (logType)
        {
            case ZLogEnum.Normal:
                infoStr = "[ZLOG] [NORMAL] " + infoStr;
                break;
            case ZLogEnum.Warning:
                infoStr = "[ZLOG] [WARNING] " + infoStr;
                break;
            case ZLogEnum.Error:
                infoStr = "[ZLOG] [ERROR] " + infoStr;
                break;
            default:
                infoStr = "[ZLOG] [NORMAL] " + infoStr;
                break;
        }

        if (string.IsNullOrEmpty(m_ExtraInfoStr))
            m_ExtraInfoStr = infoStr;
        else
            m_ExtraInfoStr = m_ExtraInfoStr + Environment.NewLine + infoStr;
        int count = m_ExtraInfoStr.Split(new string[] { Environment.NewLine }, StringSplitOptions.None).Length;
        if (count > m_MaxLine)
            m_ExtraInfoStr = m_ExtraInfoStr.Substring(m_ExtraInfoStr.IndexOf(Environment.NewLine) + Environment.NewLine.Length);
    }

    private void _Log(string infoStr)
    {
        if (!DebugLog)
            return;
        if (string.IsNullOrEmpty(infoStr))
            return;
        Debug.Log(infoStr);
        if (!ShowDebugScreen)
            return;
        displayDebugLog(infoStr,ZLogEnum.Normal);
    }
    private void _LogWarning(string infoStr)
    {
        if (!DebugLog)
            return;
        if (string.IsNullOrEmpty(infoStr))
            return;
        Debug.LogWarning(infoStr);
        if (!ShowDebugScreen)
            return;
        displayDebugLog(infoStr,ZLogEnum.Warning);
    }
    private void _LogError(string infoStr)
    {
        if (!DebugLog)
            return;
        if (string.IsNullOrEmpty(infoStr))
            return;
        Debug.LogError(infoStr);
        if (!ShowDebugScreen)
            return;
        displayDebugLog(infoStr,ZLogEnum.Error);
    }

    #region Interface

    public static void Log(string infoStr)
    {
        Instance._Log(infoStr);
    }
    public static void LogWarning(string infoStr)
    {
        Instance._LogWarning(infoStr);
    }
    public static void LogError(string infoStr)
    {
        Instance._LogError(infoStr);
    }

    #endregion
}
