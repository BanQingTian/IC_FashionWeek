using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Zrime;

public class ZNetworkingManager : MonoBehaviour
{
    public static ZNetworkingManager m_Instance;
    public static ZNetworkingManager Instance
    {
        get
        {
            if (m_Instance == null)
            {
                var net = Resources.Load<ZNetworkingManager>("NetModule/ZNetworkingManager");
                GameObject netGO = Instantiate<GameObject>(net.gameObject);
                DontDestroyOnLoad(netGO);
            }
            return m_Instance;
        }
    }

    public PlayerEntity PlayerEntityPrefab;

    private void Awake()
    {
        m_Instance = this;
    }

    public PlayerEntity GetPrefab()
    {
        return PlayerEntityPrefab;
    }

    public GameObject CreateOwner(string playerid, bool isOwner)
    {
        Player virtualPlayer = new Player
        {
            PlayerId = playerid,
            PlayerName = Global.GetName(),
            IsHouseOwner = isOwner,
            Position = new ZPosition(),
            Rotation = new ZRotation(),
            SecondPosition = new ZPosition(),
            SecondRotation = new ZRotation(),
            ExtraContent = "shelter",
        };

        Debug.Log("createBBBB");

        PlayerEntity pe = GameObject.Instantiate<PlayerEntity>(GetPrefab());
        pe.Init(virtualPlayer);
        pe.UpdatePoseData();

        ZPlayerMe.Instance.AddPlayer(playerid, pe);

        return pe.gameObject;
    }


    private void OnApplicationPause(bool pause)
    {
        if (pause)
        {
            ZClient.Instance.Leave();
        }
    }

    private void OnApplicationQuit()
    {
        Debug.Log("OnApplicationQuit");
        ZClient.Instance.Leave();
    }
}
