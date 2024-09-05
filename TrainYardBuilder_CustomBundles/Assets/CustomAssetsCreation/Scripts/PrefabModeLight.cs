#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

namespace CustomObjectsCreation
{
    [ExecuteAlways]
    public class PrefabModeLight : MonoBehaviour
    {
        [SerializeField] Vector3 lightRotation = new (45f, 45f, 0);
        [SerializeField] float lightIntensity = 1;
        
        void Start()
        {
            PrefabStage.prefabStageOpened += OnPrefabStageOpened;
        }

        void OnPrefabStageOpened(PrefabStage prefabStage)
        {
            // Do stuff here
            GameObject go = new GameObject();
            go.transform.rotation = Quaternion.Euler(lightRotation);
            Light directionalLight = go.AddComponent<Light>();
            directionalLight.type = LightType.Directional;
            directionalLight.intensity = lightIntensity;

            SceneManager.MoveGameObjectToScene(go, prefabStage.scene);

            // Unsubscribe when done so you dont get multiple callbacks when re-entering prefab mode
            PrefabStage.prefabStageOpened -= OnPrefabStageOpened;
        }
    }
}
#endif