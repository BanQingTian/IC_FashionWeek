using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Zrime;

public static class MsgId
{
    #region special id

    public const string __READY_PLAY_MSG_ = "ready_play_msg";
    public const string __JOIN_NEW_PLAYER_MSG_ = "join_new_player_msg";
    public const string __LEAVE_A_PLAYER_MSG_ = "leave_a_player_msg";
    public const string __PLAY_GAME_MSG_ = "play_Game_msg";

    public const string __BEGIN_MOVE_MSG = "begin_move_msg";
    public const string __HOUSEOWNER_ALLOCATE_MSG_ = "houseowner_allocate_msg"; //房主统一分配模型
    public const string __SINGLE_ALLOCATE_MSG_ = "single_allocate_msg"; //
    public const string __MOVE_MSG_ = "move_msg";
    public const string __MUSTER_MSG_ = "muster_msg"; // 集合/奔跑
    public const string __JUMPED_MSG_ = "jump_msg";
    public const string __BLAST_WALLS_MSG = "blast_walls_msg";

    public const string __TEST_MSG_ = "test_msg";

    #endregion
}

public class ZMessageManager
{

    public static ZMessageManager m_Instance;
    public static ZMessageManager Instance
    {
        get
        {
            if (m_Instance == null)
            {
                m_Instance = new ZMessageManager();
            }
            return m_Instance;
        }
    }

    public ZClient client;

    private bool m_Initialized = false;

    public void Init()
    {
        if (m_Initialized) return;

        client = ZClient.Instance;
        client.Persist();
        client.AddListener(MsgId.__READY_PLAY_MSG_, _Response_ReadyPlay);
        client.AddListener(MsgId.__PLAY_GAME_MSG_, _Response_PlayGame);
        client.AddListener(MsgId.__JOIN_NEW_PLAYER_MSG_, _Response_JoinNewPlayer);
        //client.AddListener(MsgId.__JOIN_NEW_PLAYER_MSG_, _Response_LeaveAPlayer); // 人物移除 移动到 ZClient

        // DIY Message
        client.AddListener(MsgId.__BEGIN_MOVE_MSG, _Response_BeginMove);
        client.AddListener(MsgId.__HOUSEOWNER_ALLOCATE_MSG_, _Response_HouseOnwerAllocateModel);
        client.AddListener(MsgId.__SINGLE_ALLOCATE_MSG_, _Response_SingleAllocalteModel);
        client.AddListener(MsgId.__MOVE_MSG_, _Respose_Move);
        client.AddListener(MsgId.__MUSTER_MSG_, _Response_Muster);
        client.AddListener(MsgId.__JUMPED_MSG_, _Response_Jumped);
        client.AddListener(MsgId.__BLAST_WALLS_MSG, _Response_BlastWalls);

        m_Initialized = true;
    }

    #region C2SFunc

    public void SendConnectAndJoinRoom(string serverIp, string port)
    {
        client.Connect(serverIp, port);
    }

    public void SendMsg(string msdId, string msgContent)
    {
        client.SendMsg(msdId, msgContent);
    }

    #endregion


    #region ResponseFunc

    public void _Response_BeginMove(object msg)
    {
        GameManager.Instance.__Func_BeginMove();
    }

    public void _Response_JoinNewPlayer(object msg)
    {
        Player player = msg as Player;

        Debug.Log("createAAAAAA");
        PlayerEntity pe = GameObject.Instantiate<PlayerEntity>(ZNetworkingManager.Instance.GetPrefab());
        pe.Init(player);
        pe.UpdatePoseData();

        ZPlayerMe.Instance.AddPlayer(player.PlayerId, pe);

        UIManager.Instance.SetReadyBtn(true);
    }

    public void _Response_ReadyPlay(object msg)
    {
        // msg.content = playerid,true
        Message m = msg as Message;
        Debug.Log(m.Content);
        var arrs = m.Content.Split(',');
        GameManager.Instance.__Func_Ready(arrs[0], arrs[1]);
    }

    public void _Response_PlayGame(object msg)
    {
        GameManager.Instance.__Func_PlayGame();
    }

    public void _Response_HouseOnwerAllocateModel(object msg)
    {
        GameManager.Instance.__Func_HouseOwnerAllocateModel();
    }

    public void _Response_SingleAllocalteModel(object msg)
    {
        Message m = msg as Message;
        var arrs = m.Content.Split(',');
        GameManager.Instance.__Func_SingleAllocateModel(int.Parse(arrs[0]), arrs[1]);
    }

    public void _Respose_Move(object msg)
    {
        Message m = msg as Message;
        var arrs = m.Content.Split(',');
        GameManager.Instance.__Func_Move(arrs[0], new Vector3(float.Parse(arrs[1]), float.Parse(arrs[2]), float.Parse(arrs[3])));
    }

    public void _Response_Muster(object msg)
    {
        //Message m = msg as Message;
        GameManager.Instance.__Func_Muster();
    }

    public void _Response_BlastWalls(object msg)
    {
        GameManager.Instance.__Func_BlastWalls();
    }

    public void _Response_Jumped(object msg)
    {
        Message m = msg as Message;
        GameManager.Instance.__Func_Jumped(m.Content);
    }

    #endregion
}
