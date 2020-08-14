using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{

    public static GameManager Instance;

    public ModelController[] Models = new ModelController[3];
    public Dictionary<string, ModelController> ModelDic = new Dictionary<string, ModelController>();

    #region Unity_Internal

    private void Awake()
    {
        Instance = this;

    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            ZMessageManager.Instance.SendMsg(MsgId.__HOUSEOWNER_ALLOCATE_MSG_, "");
            ZMessageManager.Instance.SendMsg(MsgId.__BEGIN_MOVE_MSG, "");
        }
    }

    #endregion

    #region server response call

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
        ModelDic.Add(playerId, Models[index]);
        Models[index].BelongID = playerId;
        Models[index].MoveHelper.BelongId = playerId;
        Models[index].Init();
    }

    public void __Func_BeginMove()
    {
        for (int i = 0; i < Models.Length; i++)
        {
            Models[i].SetMoveEnable(true);
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
        if(ModelDic.TryGetValue(playerId,out mc))
        {
            mc.finish = true;
        }
    }

    public void __Func_Reset()
    {

    }

    #endregion


}
