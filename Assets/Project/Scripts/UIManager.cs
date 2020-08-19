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
        if (ZClient.Instance.IsHouseOwner)
        {
            ReadyBtn.GetComponent<RectTransform>().localPosition = new Vector3(101, 0, 0);

        }
        else
        {
            ReadyBtn.GetComponent<RectTransform>().localPosition = new Vector3(0, 0, 0);

        }
        ReadyBtn.gameObject.SetActive(show);
    }
    public void SetPlayBtn(bool show,bool enable)
    {
        PlayBtn.gameObject.SetActive(show);
        PlayBtn.enabled = enable;
    }
}
