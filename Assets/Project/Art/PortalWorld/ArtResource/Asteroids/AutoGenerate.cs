using UnityEngine;
using System.Collections;

public class AutoGenerate : MonoBehaviour
{
    [SerializeField]
    GameObject[] m_Stons;
    [Header("陨石圈半径")]
    public float r;
    [Header("陨石圈厚度")]
    public float thickness;
    [Header("陨石数量")]
    public int num;
    [Header("旋转速度")]
    public float rotateSpeed = 2;

    private int currentNum = 0;

    // Use this for initialization
    void OnEnable()
    {
        StartCoroutine(GenerateStones());
    }

    private IEnumerator GenerateStones()
    {
        while (currentNum < num)
        {
            Vector2 pos_circle = Random.insideUnitCircle * r;
            Vector3 pos_disk = new Vector3(pos_circle.x, Random.Range(-thickness, thickness), pos_circle.y);
            GameObject go = Instantiate(m_Stons[Random.Range(0, m_Stons.Length)], transform);
            go.transform.localPosition = pos_disk;
            go.SetActive(true);
            go.layer = gameObject.layer;
            currentNum++;

            for (int j = 0; j < go.transform.childCount; j++)
            {
                go.transform.GetChild(j).gameObject.layer = gameObject.layer;
            }

            Rigidbody rigid = go.GetComponent<Rigidbody>();
            if (rigid == null)
            {
                rigid = go.AddComponent<Rigidbody>();
            }
            rigid.constraints = RigidbodyConstraints.None;
            rigid.useGravity = false;
            rigid.drag = 0;
            rigid.angularDrag = 0;
            rigid.angularVelocity = Random.insideUnitSphere * Random.Range(0, rotateSpeed);

            if (currentNum % 10 == 0)
            {
                yield return new WaitForEndOfFrame();
            }
            yield return new WaitForEndOfFrame();
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, r * 0.5f);
    }
}
