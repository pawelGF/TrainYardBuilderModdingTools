#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

namespace CustomObjectsCreation.Editor
{
    public class CreateAssetBundles
    {
        [MenuItem("Assets/Build AssetBundles compressed")]
        static void BuildAllAssetBundles()
        {
            string assetBundleDirectory = "Assets/StreamingAssets";
            if (!Directory.Exists(Application.streamingAssetsPath))
            {
                Directory.CreateDirectory(assetBundleDirectory);
            }
            BuildPipeline.BuildAssetBundles(assetBundleDirectory, BuildAssetBundleOptions.None, EditorUserBuildSettings.activeBuildTarget);
        }

        [MenuItem("Assets/Build AssetBundles")]
        static void BuildAllAssetBundlesUncompressed()
        {
            string assetBundleDirectory = "Assets/StreamingAssets";
            if (!Directory.Exists(Application.streamingAssetsPath))
            {
                Directory.CreateDirectory(assetBundleDirectory);
            }
            BuildPipeline.BuildAssetBundles(assetBundleDirectory, BuildAssetBundleOptions.UncompressedAssetBundle, EditorUserBuildSettings.activeBuildTarget);
        }
    }
}
#endif