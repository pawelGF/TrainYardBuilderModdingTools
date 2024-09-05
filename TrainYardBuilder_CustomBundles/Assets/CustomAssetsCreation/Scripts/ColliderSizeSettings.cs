using UnityEngine;

namespace CustomObjectsCreation
{
    [DisallowMultipleComponent, ExecuteAlways]
    public class ColliderSizeSettings : MonoBehaviour
    {
        [SerializeField] public Collider Collider;
        [SerializeField] public GameObject MeshRootGameObject;
        [SerializeField, Min(0)] public float SizeOnGridX = 1, SizeOnGridY = 2;
        bool autoSize = true;
        public const float CellSizeWithMargins = 1;
        public const float CellMargin = 0.01f;

        void Update()
        {
            transform.localScale = Vector3.one;
        }

        void OnValidate()
        {
            if (Collider == null || MeshRootGameObject == null)
            {
                return;
            }
            if ((Collider is BoxCollider || Collider is CapsuleCollider) == false)
            {
                Collider = null;
                Debug.Log("Collider should be Capsule Collider or Box Collider");
                return;
            }
            if (Collider is CapsuleCollider)
            {
                if (SizeOnGridX != SizeOnGridY)
                {
                    SizeOnGridY = SizeOnGridX;
                }
            }
            Collider.transform.localScale = Vector3.one;
            Transform parent = Collider.transform.parent;
            while (parent != null)
            {
                parent.localScale = Vector3.one;
                parent = parent.parent;
            }
            if (autoSize)
            {
                GetColliderSize(out Vector3 size, out Vector3 center);
                SetColliderSize(size, center);
            }
        }

        void OnDrawGizmos()
        {
            if (Collider == null || MeshRootGameObject == null)
            {
                return;
            }
            GetColliderSize(out Vector3 size, out Vector3 center);
            Vector3 marginSizeAdd = new Vector3(CellMargin, 0, CellMargin);
            
            GizmosExtend.DrawBox(center, size * 0.5f, transform.rotation, Color.green);
            GizmosExtend.DrawBox(center, size * 0.5f + marginSizeAdd, transform.rotation, Color.red);
            
            if (autoSize)
            {
                SetColliderSize(size, center);
            }
        }

        void GetColliderSize(out Vector3 size, out Vector3 center)
        {
            if (Collider == null || MeshRootGameObject == null)
            {
                size = Vector3.zero;
                center = Vector3.zero;
            }
            Renderer[] renderers = MeshRootGameObject.GetComponentsInChildren<Renderer>();
            Bounds bounds = new Bounds();
            foreach (Renderer renderer in renderers)
            {
                bounds = Expand(bounds, renderer.bounds);
            }
            float sizeX = SizeOnGridX * CellSizeWithMargins - 2 * CellMargin;
            float sizeY = bounds.size.y;
            float sizeZ = SizeOnGridY * CellSizeWithMargins - 2 * CellMargin;
            center = transform.position;
            center.y = bounds.center.y;
            size = new Vector3(sizeX, sizeY, sizeZ);
        }
        public Bounds Expand(Bounds bounds, Bounds otherCube)
        {
            if (bounds.size == Vector3.zero)
            {
                return otherCube;
            }
            Vector3 min = bounds.min;
            Vector3 max = bounds.max;
            Vector3 otherMin = otherCube.min;
            Vector3 otherMax = otherCube.max;
            if (otherMin.x < min.x)
            {
                min.x = otherMin.x;
            }
            if (otherMin.y < min.y)
            {
                min.y = otherMin.y;
            }
            if (otherMax.x > max.x)
            {
                max.x = otherMax.x;
            }
            if (otherMax.y > max.y)
            {
                max.y = otherMax.y;
            }
            Vector3 size = max - min;
            Vector3 center = min + (size * 0.5f);
            return new Bounds(center, size);
        }

        void SetColliderSize(Vector3 size, Vector3 center)
        {
            if (Collider == null)
            {
                return;
            }
            Vector3 centerLocal = transform.position - center;
            centerLocal.y = center.y - transform.position.y;
            if (Collider is BoxCollider boxCollider)
            {
                boxCollider.size = size;

                boxCollider.center = centerLocal;
                return;
            }
            if (Collider is CapsuleCollider capsuleCollider)
            {
                capsuleCollider.radius = size.x * 0.5f;
                capsuleCollider.height = size.y;
                capsuleCollider.center = centerLocal;
            }

        }
    }
}