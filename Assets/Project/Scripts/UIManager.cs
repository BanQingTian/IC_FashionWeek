using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum BtnEnum
{
    READY,
    PLAY,
}

public class UIManager : MonoBehaviour
{

    public static UIManager Instance;

    public Button ReadyBtn;
    public Button PlayBtn;

    private void Awake()
    {
        Instance = this;
    }

    public void AddListener(BtnEnum type, UnityEngine.Events.UnityAction action)
    {
        switch (type)
        {
            case BtnEnum.READY:
                ReadyBtn.onClick.AddListener(action);
                break;
            case BtnEnum.PLAY:
                PlayBtn.onClick.AddListener(action);
                break;
        }
    }

    public void SetReadyBtn(bool show)
    {
        ReadyBtn.gameObject.SetActive(show);
    }
    public void SetPlayBtn(bool show)
    {
        PlayBtn.gameObject.SetActive(show);
    }
}
