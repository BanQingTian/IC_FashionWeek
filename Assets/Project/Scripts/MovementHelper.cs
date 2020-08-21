using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NRKernal;

public class MovementHelper : MonoBehaviour
{
    [HideInInspector]
    public Vector3 ResultPos = Vector3.zero;
    [HideInInspector]
    public string BelongId;
    [HideInInspector]
    public Transform Target;


    [Header("地面高度")] //用于判断是否为地面
    public float GroundY = 0;
    [Header("移动时间灵敏度")]
    public float TimeSensitivity = 0.7f;
    [Header("移动位置灵敏度")]
    public float PositionSensitivity = 0.3f;
    [Header("移动速度 (默认走路，跑步*2)")]
    public float m_MoveSpeed = 4f;
    [Space(12)]
    public bool IsWalk = true;

    public float MoveSpeed
    {
        get
        {
            return IsWalk ? m_MoveSpeed : m_MoveSpeed * 2;
        }
    }

    private ModelController controller;
    // 是否可以开始控制移动的接口
    public bool MoveEnable = false;
    // 是否正在移动
    public bool Moving = false;
    private NRPointerRaycaster pointerRaycaster;
    private UnityEngine.EventSystems.RaycastResult result;

    public void Reset()
    {
        Moving = false;
        BelongId = "";
    }

    public void SetMoveEnable(bool b)
    {
        MoveEnable = b;
    }

    public void SetMoveState(AnimStateEnum state)
    {
        switch (state)
        {
            case AnimStateEnum.Idle:

                //SetMoveEnable(false);

                break;
            case AnimStateEnum.Walk:

                IsWalk = true;

                break;
            case AnimStateEnum.Run:

                IsWalk = false;

                break;
            case AnimStateEnum.Jump:

                SetMoveEnable(false);

                break;
            default:
                break;
        }
    }

    public void FixedPointMove(Vector3 end)
    {
        Move(end);
    }

    private NRPointerRaycaster FindRaycaster()
    {
        ControllerAnchorEnum anchorEnum = ControllerAnchorEnum.GazePoseTrackerAnchor;
        if (NRInput.RaycastMode == RaycastModeEnum.Laser)
        {
            anchorEnum = NRInput.DomainHand ==
                ControllerHandEnum.Right ?
                ControllerAnchorEnum.RightLaserAnchor : ControllerAnchorEnum.LeftLaserAnchor;
        }
        return NRInput.AnchorsHelper.GetAnchor(anchorEnum).GetComponentInChildren<NRPointerRaycaster>(true);
    }

    private void RaycastUpdate()
    {
        if (pointerRaycaster == null)
            pointerRaycaster = FindRaycaster();
        if (pointerRaycaster == null)
        {
            ZDebug.LogError("Can't find NRPointerRacaster !!!");
            return;
        }

        result = pointerRaycaster.FirstRaycastResult();
        if (CheckGround())
        {
            ResultPos = result.worldPosition;
            //ZDebug.Log(result.worldPosition + "==" + result.worldNormal);
        }
    }

    private bool CheckGround()
    {
        return result.isValid && result.gameObject.CompareTag("wall");//Mathf.Abs(result.worldPosition.y - GroundY) < 0.05;
    }

    float _timer = 0;
    Vector3 lastPos = Vector3.zero;
    Vector3 lastPos_upup = Vector3.zero;
    // 移动监测
    private void MoveCheck()
    {
        if (CheckGround())
        {
            if (lastPos != Vector3.zero)
            {
                if (Vector3.Distance(result.worldPosition, lastPos) < PositionSensitivity)
                {
                    if (_timer > TimeSensitivity)
                    {
                        _timer = 0;
                        //Move(result.worldPosition);
                        if (Mathf.Abs(Vector3.Distance(lastPos_upup, result.worldPosition)) > PositionSensitivity / 2)
                        {
                            ZMessageManager.Instance.SendMsg(MsgId.__MOVE_MSG_, string.Format("{0},{1},{2},{3}",
                               BelongId, result.worldPosition.x, result.worldPosition.y, result.worldPosition.z));
                            lastPos_upup = result.worldPosition;
                        }


                        lastPos = Vector3.zero;

                    }
                    _timer += Time.deltaTime;
                }
                else
                {
                    lastPos = Vector3.zero;
                    _timer = 0;
                }
            }
            lastPos = result.worldPosition;
        }
        else
        {
            lastPos = Vector3.zero;
            _timer = 0;
        }
    }


    Vector3 lastEnd = Vector3.zero;
    private void Move(Vector3 end)
    {
        //Debug.Log(end + "==" + lastEnd + gameObject.name);
        //if (Vector3.Distance(end, lastEnd) > PositionSensitivity / 2)
        {
            Moving = true;
            if (IsWalk)
            {
                controller.UpdateAnim(AnimStateEnum.Walk);
            }
            else
            {
                controller.UpdateAnim(AnimStateEnum.Run);
            }
            lastEnd = end;
        }

    }

    private void MoveUpdate(Vector3 end)
    {
        if (Moving)
        {
            controller.Rig.isKinematic = false;
            Vector3 dir = (end - Target.position).normalized * Time.deltaTime * MoveSpeed;
            Target.forward = dir;

            if (Vector3.Distance(Target.position, end) > Time.deltaTime * MoveSpeed * 2)
            {
                Target.eulerAngles = new Vector3(0, Target.eulerAngles.y, 0);
                Target.position += dir;
            }
            else
            {
                Target.position = end;
                Target.eulerAngles = new Vector3(0, Target.eulerAngles.y, 0);
                controller.Rig.isKinematic = true;
                controller.UpdateAnim(AnimStateEnum.Idle);
                Moving = false;
            }

            if (Target.position.x > 3.2 || Target.position.x < -3.38f || Target.position.z > 6.3f || Target.position.z < -0.76f)
            {
                Moving = false;
                //Target.forward = controller. EndTarget.forward;
                if (Global.DeviceType != DeviceTypeEnum.Pad)
                    ZMessageManager.Instance.SendMsg(MsgId.__BLAST_WALLS_MSG_, "");

                controller.UpdateAnim(AnimStateEnum.Jump);
                controller.finish = true;
                ZMessageManager.Instance.SendMsg(MsgId.__MUSTER_MSG_, "");
            }

        }
    }

    public void InjectTarget(Transform t, ModelController mc)
    {
        Target = t;
        controller = mc;
    }

    void Update()
    {
        if (ZClient.Instance.PlayerID == BelongId)
        {
            if (MoveEnable)
            {
                if (Global.DeviceType == DeviceTypeEnum.NRLight)
                {
                    RaycastUpdate();
                    MoveCheck();
                }

            }
        }

        MoveUpdate(lastEnd);

    }
}
