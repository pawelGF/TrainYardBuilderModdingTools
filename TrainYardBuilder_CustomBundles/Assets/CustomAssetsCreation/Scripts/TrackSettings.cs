using UnityEngine;

namespace CustomObjectsCreation
{
    public class TrackSettings : MonoBehaviour
    {
        public enum TrackType
        {
            T05x1 = 0, T1x1 = 1, T1x4 = 2, TBendToLeftSlim = 3, TBendToLeft = 4, TBendToRightSlim = 5, TBendToRight = 6,
            TCross1to2 = 7, TCross1to3 = 8, TCross1to3Slim = 9, TTurnLong = 10, TTurn = 11
        }

        public float TrackOffsetFromGround = .1f;
        public TrackType Type;
    }
}