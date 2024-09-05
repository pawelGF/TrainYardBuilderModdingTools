using UnityEngine;

namespace CustomObjectsCreation
{
    [ExecuteAlways]
    public class GridSettings : MonoBehaviour
    {
        [Min(1)] public int CellCountX = 1, CellCountY = 1;
        [Range(1, 2)] public int gridSubdivision = 1;
        public GridObjectData.GridPlacementLayer PlacementLayer = GridObjectData.GridPlacementLayer.Default;
        public Side LinkingSides = Side.None;
        
        public const float CellSizeWithMargins = 1;

        void Update()
        {
            Vector3 rotation = transform.rotation.eulerAngles;
            rotation.x = 0;
            rotation.z = 0;
            transform.rotation = Quaternion.Euler(rotation);
        }

        void OnDrawGizmos()
        {
            Transform centerTransform = transform;
            float gridScale = 1f / gridSubdivision;
            Vector2 size = new Vector2(CellCountX, CellCountY) * CellSizeWithMargins * gridScale;
            Vector3 extents = new Vector3(size.x, 0, size.y) * 0.5f;
            GizmosExtend.DrawBox(centerTransform.position, extents, centerTransform.rotation, Color.blue);
            Vector2 cellSizeVector2d = new Vector2(CellSizeWithMargins, CellSizeWithMargins) * gridScale;
            Vector2 halfCellSizeVector2d = cellSizeVector2d * 0.5f;
            Vector3 halfCellSizeVector = new Vector3(halfCellSizeVector2d.x, 0, halfCellSizeVector2d.y);
            Vector2 minCornerPositionLocal2d = -size * 0.5f;
            for (int y = 0; y < CellCountY; y++)
            {
                for (int x = 0; x < CellCountX; x++)
                {
                    Vector2 cellCenterPosition2dLocal = minCornerPositionLocal2d + new Vector2(x, y) * cellSizeVector2d + halfCellSizeVector2d;

                    Vector3 cellCenterPosition = centerTransform.TransformPoint(
                        new Vector3(cellCenterPosition2dLocal.x, 0, cellCenterPosition2dLocal.y));
                    GizmosExtend.DrawBox(cellCenterPosition, halfCellSizeVector, centerTransform.rotation, Color.blue);
                }
            }
            float linkAreaSize = 0.25f;
            if ((LinkingSides & Side.Top) != 0)
            {
                Vector3 position = centerTransform.position + (centerTransform.forward * size.y * 0.5f);
                Gizmos.DrawWireSphere(position, linkAreaSize);
            }
            if ((LinkingSides & Side.Bottom) != 0)
            {
                Vector3 position = centerTransform.position - (centerTransform.forward * size.y * 0.5f);
                Gizmos.DrawWireSphere(position, linkAreaSize);
            }
            if ((LinkingSides & Side.Right) != 0)
            {
                Vector3 position = centerTransform.position + (centerTransform.right * size.x * 0.5f);
                Gizmos.DrawWireSphere(position, linkAreaSize);
            }
            if ((LinkingSides & Side.Left) != 0)
            {
                Vector3 position = centerTransform.position - (centerTransform.right * size.x * 0.5f);
                Gizmos.DrawWireSphere(position, linkAreaSize);
            }
        }

        [System.Flags]
        public enum Side
        {
            None = 0,
            Top = 1 << 0,
            Bottom = 1 << 1,
            Left = 1 << 2,
            Right = 1 << 3
        }
    }
}