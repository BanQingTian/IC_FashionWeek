using UnityEngine;

namespace Nreal.AR
{
    [RequireComponent(typeof(Transform))]
    public class AutoRotate : MonoBehaviour
    {
        public float speed = 3;
        public Vector3 rotateVec;
        private float x, y, z;
        private float _timer;
        public bool autoRotate = false;
        public bool randomRotate = true;

        void Awake()
        {
            Randomise();
        }

        void Update()
        {
            if (autoRotate)
            {
                this.transform.Rotate(x * Time.deltaTime, y * Time.deltaTime, z * Time.deltaTime);
                _timer -= Time.deltaTime;
                if (_timer <= 0f && randomRotate)
                {
                    Randomise();
                }
            }
            else
            {
                this.transform.Rotate(rotateVec * speed);
            }
        }

        private void Randomise()
        {
            x = Random.Range(-speed, speed);
            y = Random.Range(-speed, speed);
            z = Random.Range(-speed, speed);
            _timer = Random.Range(0f, 2f);
        }
    }
}