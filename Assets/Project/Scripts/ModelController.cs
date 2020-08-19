using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AnimStateEnum
{
    Idle = 0,
    Walk = 1,
    Run = 2,
    Jump = 3,
}

public class ModelController : MonoBehaviour
{


    public string BelongID { set; get; } // 所属player的id

    public BoxCollider Collider;

    public Rigidbody Rig;

    public Animator Anim; // 动画机

    public AnimStateEnum CurState; // 当前状态

    public MovementHelper MoveHelper; // 移动控制类

    public Transform StartTarget; // 起始点

    public Transform EndTarget; // 终点

    public GameObject UITip;

    public bool finish = false;

    private bool m_Initialized = false;

    public void Init()
    {
        if (m_Initialized) return;

        if (Anim == null)
        {
            Anim = GetComponent<Animator>();
            if (Anim == null)
            {
                ZDebug.Log("Animator is null !!!");
                return;
            }
        }

        if (Collider == null)
        {
            Collider = GetComponent<BoxCollider>();
        }

        if (MoveHelper == null)
        {
            MoveHelper = GetComponent<MovementHelper>();
            if (MoveHelper == null)
            {
                ZDebug.Log("MovementHelper is null");
                return;
            }
        }

        MoveHelper.InjectTarget(gameObject.transform, this);

        gameObject.SetActive(true);
        gameObject.transform.position = StartTarget.position;
        gameObject.transform.rotation = StartTarget.rotation;

        m_Initialized = true;
    }

    public void SetMoveEnable(bool b)
    {
        MoveHelper.SetMoveEnable(b);
    }

    public void UpdateAnim(AnimStateEnum state)
    {
        CurState = state;
        MoveHelper.SetMoveState(state);
        switch (state)
        {
            case AnimStateEnum.Idle:
                Anim.Play("idle");
                break;
            case AnimStateEnum.Walk:
                Anim.Play("walk");
                break;
            case AnimStateEnum.Run:
                Anim.Play("run");
                break;
            case AnimStateEnum.Jump:
                //Anim.Play("jump");
                Anim.SetTrigger("jump");
                break;
            default:
                break;
        }
    }

    public void Move(Vector3 end)
    {
        MoveHelper.FixedPointMove(end);
    }

    public void Muster()
    {
        MoveHelper.SetMoveEnable(false);

        if (!finish)
        {
            MoveHelper.FixedPointMove(EndTarget.position);
            UpdateAnim(AnimStateEnum.Run);
        }
    }

    public void Reset()
    {
        finish = false;
        UITip.SetActive(false);
        UpdateAnim(AnimStateEnum.Idle);
        transform.position = StartTarget.position;
        transform.rotation = StartTarget.rotation;
    }

    public void JumpEnd()
    {
        StartCoroutine(JumpEndCor());
    }
    public IEnumerator JumpEndCor()
    {
        float t = 0;
        while (t < 0.5f)
        {
            t += Time.deltaTime;
            gameObject.transform.localPosition += -Vector3.up * Time.deltaTime * 2;
            yield return null;
        }

        gameObject.SetActive(false);
    }

}
