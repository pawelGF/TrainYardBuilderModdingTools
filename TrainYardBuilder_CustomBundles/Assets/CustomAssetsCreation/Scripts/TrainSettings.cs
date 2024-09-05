using UnityEngine;

namespace CustomObjectsCreation
{
    public class TrainSettings : MonoBehaviour
    {
        public Transform FrontWheelsPosition;
        public Transform BackWheelsPosition;
        public Transform FrontDetectorPosition;
        public Transform IndicatorPosition;

        public bool HaveSmoke = false;
        public Transform SmokePosition;
    }
}