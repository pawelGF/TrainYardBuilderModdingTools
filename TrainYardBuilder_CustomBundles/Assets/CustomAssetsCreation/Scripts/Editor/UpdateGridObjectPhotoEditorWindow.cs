#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Assertions;

namespace CustomObjectsCreation.Editor
{
    public class UpdateGridObjectPhotoEditorWindow : EditorWindow
    {
        int photosWidth;
        int photosHeight;

        Texture2D[] photosTextures;
        Texture2D dirtyTexture;

        GameObject prefab;
        List<string> photosPaths;

        bool isTakingPhoto;

        [MenuItem("Tools/Take Photo")]
        static void OpenWindow()
        {
            UpdateGridObjectPhotoEditorWindow window = GetWindow<UpdateGridObjectPhotoEditorWindow>();
            Rect rect = window.position;
            rect.size = new Vector2(960, 340);
            window.position = rect;

            window.dirtyTexture = Resources.Load<Texture2D>("Textures/DirtMask");
            Assert.IsNotNull(window.dirtyTexture);
            window.Show();
        }

        void OnDestroy()
        {
            Clear();
        }

        void Clear()
        {
            photosTextures = null;
            photosPaths = null;
            isTakingPhoto = false;
            EditorUtility.ClearProgressBar();
        }

        bool TakePhotos()
        {
            PhotoDimensions photoSize = PrefabPhotos.TakePhotos(prefab, OnPhotoTaken);
            photosWidth = photoSize.Width;
            photosHeight = photoSize.Height;
            return photoSize.Height != 0 && photoSize.Width != 0;
        }

        void OnGUI()
        {
            prefab = EditorGUILayout.ObjectField(label: new GUIContent("Prefab"),
                                                 obj: prefab,
                                                 objType: typeof(GameObject),
                                                 allowSceneObjects: false) as GameObject;

            if (prefab != null && isTakingPhoto == false)
            {
                if (GUILayout.Button("Take photos"))
                {
                    if (TakePhotos())
                    {
                        isTakingPhoto = true;
                    }
                }
            }

            if (photosTextures != null && photosTextures.Length > 0)
            {
                isTakingPhoto = false;
            }

            if (isTakingPhoto)
            {
                EditorUtility.DisplayProgressBar("Photos", "Taking photos", 10);
            }
            else
            {
                EditorUtility.ClearProgressBar();
            }

            if (photosTextures == null || photosTextures.Length == 0)
            {
                return;
            }

            Rect windowRect = position;
            float photosAspectRatio = photosWidth / photosHeight;
            int texturesCount = photosTextures.Length;
            EditorGUILayout.BeginHorizontal();
            try
            {
                for (int i = 0; i < texturesCount; i++)
                {
                    if (photosTextures == null)
                    {
                        return;
                    }

                    Texture2D texture = photosTextures[i];

                    GUIContent buttonWithTextureContent = new GUIContent(texture);
                    float width = (windowRect.size.x - 40) / texturesCount;
                    if (width < 0)
                    {
                        width = 0;
                    }

                    GUILayoutOption widthOption = GUILayout.Width(width);
                    GUILayoutOption heightOption = GUILayout.Height(width * photosAspectRatio);
                    if (GUILayout.Button(buttonWithTextureContent, widthOption, heightOption))
                    {
                        OnPhotoSelected(i);
                    }
                }
            }
            finally
            {
                EditorGUILayout.EndHorizontal();
            }
        }

        void OnPhotoSelected(int photoIndex)
        {
            Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(FullToLocalPath(photosPaths[photoIndex]));
            if (sprite == null)
            {
                return;
            }

            string prefabOnDiscPath = AssetDatabase.GetAssetPath(prefab);

            using (PrefabUtility.EditPrefabContentsScope editingScope = new (prefabOnDiscPath))
            {
                ObjectPhoto objectPhotoComponent = editingScope.prefabContentsRoot.GetComponent<ObjectPhoto>();
                if (objectPhotoComponent != null)
                {
                    objectPhotoComponent.Photo = sprite;
                    GridObjectData gridObjectData = prefab.GetComponent<GridObjectData>();
                    if(gridObjectData.canBeDirty)
                        objectPhotoComponent.DirtyPhoto = GetDirtyPhoto(sprite);
                }
                else
                {
                    Debug.LogError($"prefab does not have and {nameof(ObjectPhoto)} component");
                }
            }

            for (int i = 0; i < photosPaths.Count; i++)
            {
                if (i != photoIndex)
                {
                    AssetDatabase.DeleteAsset(FullToLocalPath(photosPaths[i]));
                }
            }

            Clear();
            AssetDatabase.Refresh();
        }

        Sprite GetDirtyPhoto(Sprite cleanPhoto)
        {
            Texture2D cleanTexture = cleanPhoto.texture;
            int cleanTextureWidth = cleanTexture.width;
            int cleanTextureHeight = cleanTexture.height;
            int dirtyMaskSize = dirtyTexture.width;

            int newDirtyTextureSize = GetScaledDirtyTextureSize(cleanTextureWidth, cleanTextureHeight, dirtyMaskSize);
            RenderTexture rt = new(width: newDirtyTextureSize, height: newDirtyTextureSize, depth: 24);
            RenderTexture.active = rt;
            Graphics.Blit(dirtyTexture, rt);

            Texture2D dirtyMaskScaled = new(width: cleanTextureWidth, height: cleanTextureHeight);
            dirtyMaskScaled.ReadPixels(new Rect(0, 0, cleanTextureWidth, cleanTextureHeight), 0, 0);

            Texture2D dirtyPhoto = new(width: cleanTextureWidth, height: cleanTextureHeight);
            Color[] cleanTexturePixels = cleanTexture.GetPixels();
            dirtyPhoto.SetPixels(cleanTexturePixels);
            
            for (int i = 0; i < cleanTextureWidth; i++)
            for (int j = 0; j < cleanTextureHeight; j++)
                dirtyPhoto.SetPixel(i, j,  dirtyPhoto.GetPixel(i, j) * dirtyMaskScaled.GetPixel(i, j));

            string dirtyPhotoPath = $"Photos/{cleanPhoto.name}_Dirty.png";
            string absFilePath = Path.Combine(Application.dataPath, dirtyPhotoPath);
            PhotoBox.SaveTexture(dirtyPhoto, absFilePath, new Rect(x: 0, 
                                                                   y: 0,
                                                                   width: dirtyPhoto.width, 
                                                                   height: dirtyPhoto.height));

            PhotoBox.MakeSpriteFromImage(absFilePath);
            return AssetDatabase.LoadAssetAtPath<Sprite>(FullToLocalPath(absFilePath));
        }
        
        int GetScaledDirtyTextureSize(int cleanTextureWidth, int cleanTextureHeight, int dirtyMaskSize)
        {
            double scale;
            if (cleanTextureWidth > cleanTextureHeight)
                scale = (double)cleanTextureWidth / dirtyMaskSize;
            else
                scale = (double)cleanTextureHeight / dirtyMaskSize;

            int newDirtyTextureSize = Mathf.CeilToInt((float)(dirtyMaskSize * scale));
            return newDirtyTextureSize;
        }

        void OnPhotoTaken(List<string> photosPaths)
        {
            isTakingPhoto = false;
            
            if (prefab == null) return;

            int photosCount = photosPaths.Count;
            this.photosPaths = photosPaths;
            photosTextures = new Texture2D[photosCount];
            for (int i = 0; i < photosCount; i++)
            {
                Texture2D texture = new Texture2D(photosWidth, photosHeight);
                string photoPath = photosPaths[i];
                texture.LoadImage(File.ReadAllBytes(photoPath));
                photosTextures[i] = texture;
            }
        }

        static string FullToLocalPath(string fullPath) => "Assets\\" + fullPath.Remove(0, Application.dataPath.Length);
    }
}
#endif