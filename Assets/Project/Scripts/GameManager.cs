using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class GameManager : MonoBehaviour
{

    public static GameManager Instance;

    public ModelController[] Models = new ModelController[3];
    public Dictionary<string, ModelController> ModelDic = new Dictionary<string, ModelController>();


    public bool Playing = false;

    #region Scene data

    public GameObject MainScene;
    public PlayableDirector FirstPart; // 第一段播放动画
    public PlayableDirector SecondPart; // 第二段播放动画
    public Animator HandEffGO_L; // 手部渐变出现
    public Animator HandEffGO_R; // 手部渐变出现

    public GameObject Static_Wall;

    private const float displayHandTime = 2013f;
    private const float disappearHandTime = 240;
    private const float modelPoseReadyTime = 1622;

    #endregion




    private bool blastWalls = false;

    private ZMain m_ZMain;




    #region Unity_Internal

    private void Awake()
    {
        Instance = this;

    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            Time.timeScale = 5;
        }
        if(Input.GetKeyUp(KeyCode.R))
        {
            Time.timeScale = 1;
        }

        if (m_ZMain.IS_MATCH && Playing == false)
        {
            m_ZMain.IS_MATCH = false;
            UIManager.Instance.SetReadyBtn(true);
        }
    }

    #endregion


    #region Scene Part

    public void ShowMainScene()
    {
        FirstPart.gameObject.SetActive(true);
        MainScene.SetActive(true);
        Static_Wall.SetActive(true);
        StartCoroutine(handEffCor());
    }
    private IEnumerator handEffCor()
    {
        yield return new WaitForSeconds((displayHandTime - 1) / 60);
        HandEffGO_L.gameObject.SetActive(true);
        HandEffGO_L.Play("display");
        HandEffGO_R.gameObject.SetActive(true);
        HandEffGO_R.Play("display");
    }

    public void ShowSecondLogic()
    {
        StartCoroutine(secondCor());
    }
    private IEnumerator secondCor()
    {
        SecondPart.gameObject.SetActive(true);
        Static_Wall.SetActive(false);

        yield return new WaitForSeconds((disappearHandTime - 1) / 60);

        HandEffGO_L.Play("disappear");
        HandEffGO_R.Play("disappear");
    }

    public void ResetModelControllers(bool show)
    {
        for (int i = 0; i < Models.Length; i++)
        {
            Models[i].gameObject.SetActive(show);
            Models[i].Reset();
        }
    }

    // 重置场景的状态
    public void ResetScenePart()
    {
        MainScene.SetActive(false);
        FirstPart.gameObject.SetActive(false);
        SecondPart.gameObject.SetActive(false);
        ResetModelControllers(false);
    }

    #endregion


    public void Init(ZMain main)
    {
        m_ZMain = main;

        UIManager.Instance.AddListener(BtnEnum.READY, SendReadMsg);
        UIManager.Instance.AddListener(BtnEnum.PLAY, SendPlayMsg);

        ResetModelControllers(false);
    }

    public void SendReadMsg()
    {
        ZMessageManager.Instance.SendMsg(MsgId.__READY_PLAY_MSG_, string.Format("{0},{1}", ZClient.Instance.PlayerID, "1"));
    }
    public void SendPlayMsg()
    {
        ZMessageManager.Instance.SendMsg(MsgId.__PLAY_GAME_MSG_, "");
    }


    #region server response call

    public void __Func_Ready(string playerId, string ready)
    {
        bool allready = ZPlayerMe.Instance.SetPlayerReady(playerId, ready);
        if (allready && ZClient.Instance.IsHouseOwner)
        {
            UIManager.Instance.SetPlayBtn(true);
        }
        else
        {
            UIManager.Instance.SetPlayBtn(false);
        }
    }

    // play timeline
    public void __Func_PlayGame()
    {
        Playing = true; // playing == true, can't add new player;

        UIManager.Instance.SetReadyBtn(false);
        UIManager.Instance.SetPlayBtn(false);

        StartCoroutine(playGameCor());
    }
    private IEnumerator playGameCor()
    {
        ShowMainScene();
        yield return new WaitForSeconds(modelPoseReadyTime / 60);
        ZMessageManager.Instance.SendMsg(MsgId.__HOUSEOWNER_ALLOCATE_MSG_, "");
        ZMessageManager.Instance.SendMsg(MsgId.__BEGIN_MOVE_MSG, "");
    }

    // 房主统一分配模型
    public void __Func_HouseOwnerAllocateModel()
    {
        int index = 0;
        foreach (var item in ZPlayerMe.Instance.PlayerMap)
        {
            if (item.Value.PlayerInfo.PlayerName != "arcore") // nrlight用户每人分配一个模型
            {
                ZMessageManager.Instance.SendMsg(MsgId.__SINGLE_ALLOCATE_MSG_, string.Format("{0},{1}", index, item.Key));
                index++;
            }
        }
    }

    // 
    public void __Func_SingleAllocateModel(int index, string playerId)
    {
        Debug.Log("index : " + index);
        if (!ModelDic.ContainsKey(playerId))
            ModelDic.Add(playerId, Models[index]);
        Models[index].BelongID = playerId;
        Models[index].MoveHelper.BelongId = playerId;
        Models[index].UITip.SetActive(true);
        Models[index].Init();
    }

    public void __Func_BeginMove()
    {
        for (int i = 0; i < Models.Length; i++)
        {
            Models[i].SetMoveEnable(true);
            Models[i].gameObject.SetActive(true);
        }
    }

    public void __Func_Move(string modelBelongId, Vector3 endpos)
    {
        ModelDic[modelBelongId].Move(endpos);
    }

    public void __Func_Muster()
    {
        for (int i = 0; i < Models.Length; i++)
        {
            Models[i].Init();
            Models[i].Muster();
        }
    }

    public void __Func_Jumped(string playerId)
    {
        ModelController mc;
        if (ModelDic.TryGetValue(playerId, out mc))
        {
            mc.finish = true;
        }
    }

    public void __Func_BlastWalls()
    {
        if (!blastWalls)
        {
            blastWalls = true;
            ZDebug.Log("Boom");

            // todo play boom timeline
            ShowSecondLogic();
        }
    }

    public void __Func_Reset()
    {
        Playing = false;
    }

    #endregion


}
