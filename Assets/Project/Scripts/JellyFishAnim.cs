using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JellyFishAnim : MonoBehaviour
{

    private Renderer render;
    private Material[] mats;
    private Color defaultColor;

    // Use this for initialization
    void Start()
    {
        render = this.GetComponent<Renderer>();
        Color defaultColor = render.material.color;
        mats = render.materials;
        for (int i = 0; i < mats.Length; i++)
        {
            mats[i].color = new Color(defaultColor.r, defaultColor.g, defaultColor.b, 0);
        }
        StartCoroutine(appear());
    }

    IEnumerator appear()
    {
        float a = 0;
        while (mats[0].color.a < 0.999f)
        {
            for (int i = 0; i < mats.Length; i++)
            {
                a += Time.fixedDeltaTime * 0.6f;
                mats[i].color = new Color(defaultColor.r, defaultColor.g, defaultColor.b, a);
                Debug.Log(mats[0].color.a);
            }
            yield return null;
        }
        for (int i = 0; i < mats.Length; i++)
        {
            mats[i].color = new Color(0.913f, 0.913f, 0.913f, 1);
        }
    }
}
