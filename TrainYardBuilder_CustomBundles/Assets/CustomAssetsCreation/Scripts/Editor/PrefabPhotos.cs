using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;

#if UNITY_EDITOR
using UnityEditor.SceneManagement;
#endif

namespace CustomObjectsCreation.Editor
{
    public static class AssetDatabaseExtended
    {
#if UNITY_EDITOR
        public static T GetScriptableObject<T>() where T : ScriptableObject
        {
            T[] s = GetAllScriptableObjects<T>();
            return s.Length == 0 ? null : s[0];
        }

        public static T[] GetAllScriptableObjects<T>() where T : ScriptableObject
        {
            List<Object> assets = GetAssets("t:" + typeof(T).Name);
            int assetsCount = assets.Count;
            T[] scriptableObjects = new T[assetsCount];
            for (int i = 0; i < assetsCount; i++)
            {
                scriptableObjects[i] = assets[i] as T;
            }

            return scriptableObjects;
        }

        static List<Object> GetAssets(string searchString, bool includeSubAssets = true)
        {
            string[] guids = AssetDatabase.FindAssets(searchString);
            List<Object> objects = new List<Object>(guids.Length);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                if (includeSubAssets)
                {
                    objects.AddRange(AssetDatabase.LoadAllAssetsAtPath(path));
                }
                else
                {
                    objects.Add(AssetDatabase.LoadMainAssetAtPath(path));
                }
            }

            return objects;
        }
#endif
    }

    public static class PrefabPhotos
    {
        static string photoBoxScenePath = "Assets/Scenes/PhotoBoxScene.unity";
        static Scene photoBoxScene;
        static Action<List<string>> onPhotosTakenCallback;
        static List<string> openScenesPaths = new();
        static GameObject currentPrefab;
        static GameObject trackPreviewGameObject;
        static int currentTrackVariantMeshDataIndex;
        static TrackSettings currentTrackSettings;
        static List<string> tracksPhotos = new();
        static int tracksPhotoSide = -1;
        static Action<List<string>> onAllTrackPhotosTaken;
        
        static void OnTrackPreviewPhotoTaken(List<string> photosPaths)
        {
            if (trackPreviewGameObject != null) 
                Object.DestroyImmediate(trackPreviewGameObject);
        }

#if UNITY_EDITOR
        public static PhotoDimensions TakePhotos(GameObject prefab, 
                                                 Action<List<string>> onPhotosTaken,
                                                 int specificSide = -1)
        {
            if (prefab == null)
                return default;

            if (currentPrefab != null)
                return default;

            if (Application.isPlaying)
            {
                Debug.LogError("Application is playing. Cannot take photos for prafab");
                return default;
            }

            int openScenesCount = SceneManager.sceneCount;
            openScenesPaths.Clear();
            openScenesPaths.Capacity = openScenesCount;
            for (int i = 0; i < openScenesCount; i++)
            {
                Scene scene = SceneManager.GetSceneAt(i);
                if (scene.IsValid() && scene.isLoaded) 
                    openScenesPaths.Add(scene.path);
            }

            if (openScenesPaths.Contains(photoBoxScenePath) == false)
                photoBoxScene = EditorSceneManager.OpenScene(photoBoxScenePath, OpenSceneMode.Additive);
            else
                photoBoxScene = SceneManager.GetSceneByPath(photoBoxScenePath);

            if (photoBoxScene.IsValid() == false)
            {
                ReturnToPreviousScenes();
                return default;
            }

            SceneManager.SetActiveScene(photoBoxScene);
            PhotoBox photoBox = Object.FindObjectOfType<PhotoBox>();
            if (photoBox == null)
            {
                Debug.LogError("No found PhotoBox object!");
                ReturnToPreviousScenes();
                return default;
            }

            onPhotosTakenCallback = onPhotosTaken;
            PhotoDimensions photoDimensions = photoBox.TakePhotos(prefab, OnPhotosTaken, specificSide);
            return photoDimensions;
        }
#endif

        static void OnPhotosTaken(List<string> photosPaths)
        {
            Action<List<string>> photoTakenCallback = onPhotosTakenCallback;
            ReturnToPreviousScenes();
            photoTakenCallback?.Invoke(photosPaths);
        }

        static void ReturnToPreviousScenes()
        {
            OpenScenes(openScenesPaths);
            if (openScenesPaths.Contains(photoBoxScenePath) == false)
            {
#if UNITY_EDITOR
                EditorSceneManager.CloseScene(photoBoxScene, true);
#endif
            }

            photoBoxScene = default;
            currentPrefab = null;
            onPhotosTakenCallback = null;
            openScenesPaths.Clear();
        }

        public static void OpenScenes(IEnumerable<string> scenesPaths)
        {
            foreach (string scenePath in scenesPaths)
            {
                Scene scene = SceneManager.GetSceneByPath(scenePath);
                if (scene.IsValid() && scene.isLoaded)
                {
                    continue;
                }

#if UNITY_EDITOR
                EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Additive);
#endif
            }
        }
    }
}