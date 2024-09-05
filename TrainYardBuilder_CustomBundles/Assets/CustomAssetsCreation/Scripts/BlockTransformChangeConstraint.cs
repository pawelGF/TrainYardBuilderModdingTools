using UnityEngine;

namespace CustomObjectsCreation
{
    [ExecuteAlways]
    public class BlockTransformChangeConstraint : MonoBehaviour
    {
        void Update()
        {
            transform.localScale = Vector3.one;
            transform.localPosition = Vector3.zero;
            transform.localRotation = Quaternion.identity;
        }
    }
}