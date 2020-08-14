/*
http://www.cgsoso.com/forum-211-1.html

CG搜搜 Unity3d 每日Unity3d插件免费更新 更有VIP资源！

CGSOSO 主打游戏开发，影视设计等CG资源素材。

插件如若商用，请务必官网购买！

daily assets update for try.

U should buy the asset from home store if u use it in your project!
*/

using UnityEngine;
using System.Collections;

public class F3DPlanet : MonoBehaviour
{
    public float RotationRate;
    public float OrbitRate;
    public Transform OrbitPoint;

    public bool ShowOrbit;

    float distToOrbitPoint;
    Vector3 orbitAxis;
    Vector3 pointToPlanetDir;

    // Use this for initialization
    void Start ()
    {
        if (OrbitPoint)
        {
            distToOrbitPoint = Vector3.Distance(transform.position, OrbitPoint.position);
            orbitAxis = transform.up;
            pointToPlanetDir = Vector3.Normalize(transform.position - OrbitPoint.position);
        }
    }
    
    // Update is called once per frame
    void Update ()
    {
        transform.rotation *= Quaternion.Euler(0f, RotationRate * Time.deltaTime, 0f);

        if (OrbitPoint)
        {
            pointToPlanetDir = Quaternion.AngleAxis(OrbitRate * Time.deltaTime, orbitAxis) * pointToPlanetDir;
            transform.position = OrbitPoint.position + pointToPlanetDir * distToOrbitPoint;
        }
    }
}
