using UnityEngine;

namespace CustomObjectsCreation
{
    [ExecuteAlways]
    public class UniformScaleConstraint : MonoBehaviour
    {
        void Update()
        {
            Vector3 scale = transform.localScale;
            scale.y = scale.x;
            scale.z = scale.x;
            transform.localScale = scale;
        }
    }
}