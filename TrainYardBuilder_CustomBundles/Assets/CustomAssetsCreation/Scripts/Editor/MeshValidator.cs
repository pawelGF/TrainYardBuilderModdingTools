#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[ExecuteAlways]
public class MeshValidator : MonoBehaviour
{
    void Update() => Validate();

    void OnValidate() => Validate();

    void Validate()
    {
        foreach (Transform child in GetChildren(transform))
        {
            KeepMeshReadable(child);
            KeepProperLightLayerMask(child);
        }
    }

    static void KeepMeshReadable(Transform child)
    {
        MeshFilter mf = child.GetComponent<MeshFilter>();
        if (mf)
        {
            string meshPath = AssetDatabase.GetAssetPath(mf.sharedMesh);
            ModelImporter modelImporter = AssetImporter.GetAtPath(meshPath) as ModelImporter;
            if (modelImporter && modelImporter.isReadable == false)
            {
                modelImporter.isReadable = true;
                modelImporter.SaveAndReimport();
            }
        }
    }

    static void KeepProperLightLayerMask(Transform child)
    {
        MeshRenderer mr = child.GetComponent<MeshRenderer>();
        if (mr)
        {
            if(mr.renderingLayerMask != 1 << 2)
            {
                mr.renderingLayerMask = 1 << 2;
                EditorUtility.SetDirty(mr);
            }
        }
    }

    Transform[] GetChildren(Transform transform)
    {
        List<Transform> result = new();
        try
        {
            foreach (Transform child in transform)
            {
                result.Add(child);
                result.AddRange(GetChildren(child));
            }
        }
        catch (UnassignedReferenceException e)
        {
            Console.WriteLine(e);
            throw;
        }

        return result.ToArray();
    }
}
#endif