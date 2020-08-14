using UnityEngine;

public class AutoMove : MonoBehaviour
{
    public float speed = 3;
    public Vector3 moveVec;

    void Update()
    {
        transform.position += speed * Time.deltaTime * moveVec;
    }
}