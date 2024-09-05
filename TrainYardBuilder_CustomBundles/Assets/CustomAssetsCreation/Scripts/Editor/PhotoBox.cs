#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace CustomObjectsCreation
{
    public class PhotoBox : MonoBehaviour
    {
        static string relativeFolderPath = "Photos";
        static int width = 800;
        static float zoomMultiplier = 1f;
        static float scale = 0.5f;
        static Vector3 hsvMatching = new(5, 0.5f, 0.5f);
        static float backgroundMatchingTolerance = 0.85f; 
        static float cameraAspect = 1;
        
        [SerializeField] new Camera camera;
        [SerializeField] Transform photoPosition;
        [SerializeField] Transform viewAngleTransform;
        [SerializeField, Min(1)] int shotAnglesCount = 8;
        [SerializeField] bool overrideExistingPhotos = true;
        
        RenderTexture renderTexture;
        Bounds lastBounds;
        List<string> imagePaths = new();

        static int height => Mathf.RoundToInt(width / cameraAspect);
        
        public PhotoDimensions TakePhotos(GameObject prefab, 
                                          System.Action<List<string>> OnEndCallback = null, 
                                          int specificSide = -1)
        {
            TakePhotos(prefab, true, onEndCallback: OnEndCallback, specificSide: specificSide);
            return new PhotoDimensions(width, height);
        }

        Color GetBackgroundColor()
        {
            renderTexture = new RenderTexture(width, height, 16);
            camera.targetTexture = renderTexture;
            camera.Render();
            Texture2D backgroundTexture = ConvertToTexture2D(renderTexture);
            Color backgroundColor = backgroundTexture.GetPixel(0, 0);
            return backgroundColor;
        }

        void TakePhotos(GameObject prefab, bool createSprites, Color? backgroundColor = null,
                        System.Action<List<string>> onEndCallback = null, int specificSide = -1)
        {
            camera.aspect = cameraAspect;
            if (createSprites)
            {
                imagePaths.Clear();
            }
            if (backgroundColor.HasValue == false)
            {
                backgroundColor = GetBackgroundColor();
            }

            GameObject photographedGameObject = Instantiate(prefab, photoPosition);
            photographedGameObject.SetActive(true);
            photographedGameObject.name = prefab.name;
            photographedGameObject.transform.localPosition = Vector3.zero;
            photographedGameObject.transform.localRotation = Quaternion.identity;
            photographedGameObject.transform.localScale = Vector3.one;
            photographedGameObject.transform.localScale = new Vector3(scale, scale, scale);
            
            float oneShotAngleRotation = 360 / shotAnglesCount;
            int startIndex = 0;
            int endIndex = shotAnglesCount - 1;
            if (specificSide != -1 && specificSide < shotAnglesCount)
            {
                startIndex = specificSide;
                endIndex = specificSide;
            }
            
            for (int i = startIndex; i <= endIndex; i++)
            {
                photographedGameObject.transform.rotation = Quaternion.Euler(new Vector3(0, oneShotAngleRotation * i, 0));
                Renderer[] renderers = photographedGameObject.GetComponentsInChildren<Renderer>();
                if (renderers.Length == 0)
                {
                    Debug.Log($"No renderers in object {photographedGameObject.name}");
                    return;
                }

                Bounds bounds = renderers[0].bounds;
                foreach (Renderer renderer in renderers) 
                    bounds.Encapsulate(renderer.bounds);
                lastBounds = bounds;

                ZoomFit(camera, bounds, viewAngleTransform, zoomMultiplier);
                renderTexture = new RenderTexture(width, height, 16);
                camera.targetTexture = renderTexture;
                camera.Render();
                Texture2D convertedTexture = ConvertToTexture2D(renderTexture);
                Rect imageRect = ChangeTextureAlphaOnColor(convertedTexture, backgroundColor.Value);
                
                string absFolderPath = Path.Combine(Application.dataPath, relativeFolderPath);
                if (!Directory.Exists(absFolderPath)) 
                    Directory.CreateDirectory(absFolderPath);

                string fileName = $"{prefab.name}_{i}";
                string localFilePath = $"Assets/{relativeFolderPath}/{fileName}.png";
                if (overrideExistingPhotos == false) 
                    localFilePath = AssetDatabase.GenerateUniqueAssetPath(localFilePath);

                int dataPathLength = Application.dataPath.Length;
                string absFilePath = Path.Combine(Application.dataPath.Remove(dataPathLength - "Assets\"".Length), localFilePath);
                SaveTexture(convertedTexture, absFilePath, imageRect);
                imagePaths.Add(absFilePath);
                renderTexture.Release();
            }
            DestroyImmediate(photographedGameObject);

            List<string> spritesPaths = null;
            if (createSprites)
            {
                spritesPaths = CreateSprites();
            }
            onEndCallback?.Invoke(spritesPaths);
        }

        Rect ChangeTextureAlphaOnColor(Texture2D texture, Color color)
        {
            int imageMinX = texture.width;
            int imageMinY = texture.height;
            int imageMaxX = 0, imageMaxY = 0;
            for (int y = 0; y < texture.height; y++)
            {
                for (int x = 0; x < texture.width; x++)
                {
                    // Read out pixel value at that location in both textures
                    Color pixelColor = texture.GetPixel(x, y);
                    float similarityCoef = GetSimilarityCoeficent(pixelColor, color, hsvMatching.x, hsvMatching.y, hsvMatching.z);
                    if (similarityCoef > backgroundMatchingTolerance)
                    {
                        texture.SetPixel(x, y, new Color(0, 0, 0, 0));
                    }
                    else
                    {
                        if (x < imageMinX)
                        {
                            imageMinX = x;
                        }
                        if (x > imageMaxX)
                        {
                            imageMaxX = x;
                        }
                        if (y < imageMinY)
                        {
                            imageMinY = y;
                        }
                        if (y > imageMaxY)
                        {
                            imageMaxY = y;
                        }
                    }
                }
            }
            // Apply the results
            texture.Apply();
            Rect imageRect = new Rect(imageMinX, imageMinY, imageMaxX - imageMinX + 1, imageMaxY - imageMinY + 1);
            return imageRect;
        }

        List<string> CreateSprites()
        {
            AssetDatabase.Refresh();
            List<string> spritePaths = new List<string>(imagePaths.Count);
            foreach (string filePath in imagePaths)
            {
                MakeSpriteFromImage(filePath);
                spritePaths.Add(filePath);
            }
            imagePaths.Clear();
            return spritePaths;
        }

        public static void SaveTexture(Texture2D texture, string path, Rect imageRect)
        {
            Texture2D croppedTexture = new Texture2D((int)imageRect.size.x, (int)imageRect.size.y);
            Graphics.CopyTexture(src: texture,
                                 srcElement: 0,
                                 srcMip: 0,
                                 srcX: (int)imageRect.min.x,
                                 srcY: (int)imageRect.min.y,
                                 srcWidth: (int)imageRect.size.x,
                                 srcHeight: (int)imageRect.size.y,
                                 dst: croppedTexture,
                                 dstElement: 0,
                                 dstMip: 0,
                                 dstX: 0,
                                 dstY: 0);
            byte[] encodedImageData = croppedTexture.EncodeToPNG();
            if (path.EndsWith(".png") == false) 
                path += ".png";
            File.WriteAllBytes(path, encodedImageData);
        }

        public static void MakeSpriteFromImage(string imagePath)
        {
            string assetPath = FullToLocalPath(imagePath);
            Texture2D texture = new Texture2D(width, height);
            if (File.Exists(imagePath) == false)
            {
                Debug.LogError($"No file {imagePath}");
            }
            texture.LoadImage(File.ReadAllBytes(imagePath));
            Sprite sprite = Sprite.Create(texture,
                    new Rect(0.0f, 0.0f, texture.width, texture.height),
                    new Vector2(0.5f, 0.5f), 50f, 0, SpriteMeshType.FullRect);
            SaveSpriteAsAsset(sprite, assetPath);
        }

        static Sprite SaveSpriteAsAsset(Sprite sprite, string unityPath)
        {
            TextureImporter ti = AssetImporter.GetAtPath(unityPath) as TextureImporter;
            
            if (ti == null)
                AssetDatabase.Refresh();
            ti = AssetImporter.GetAtPath(unityPath) as TextureImporter;
            ti.spritePixelsPerUnit = sprite.pixelsPerUnit;
            ti.mipmapEnabled = false;
            ti.textureType = TextureImporterType.Sprite;
            ti.spriteImportMode = SpriteImportMode.Single;
            ti.isReadable = true;

            EditorUtility.SetDirty(ti);
            ti.SaveAndReimport();

            return AssetDatabase.LoadAssetAtPath<Sprite>(unityPath);
        }

        static void ZoomFit(Camera c, Bounds b, Transform viewAngleTransform, float zoomMultiplier)
        {
            Vector3 max = b.size;
            float radius = Mathf.Max(max.x, Mathf.Max(max.y, max.z));
            float dist = radius / Mathf.Sin(c.fieldOfView * Mathf.Deg2Rad / 2f);
            Vector3 pos = b.center - viewAngleTransform.forward * dist * zoomMultiplier;
            c.nearClipPlane = 0.001f;
            c.transform.position = pos;
            c.transform.LookAt(b.center);
        }
        public static string FullToLocalPath(string fullPath)
        {
            return "Assets\\" + fullPath.Remove(0, Application.dataPath.Length);
        }

        Texture2D ConvertToTexture2D(RenderTexture renderTexture)
        {
            RenderTexture previousRenderTexture = RenderTexture.active;
            RenderTexture.active = renderTexture;

            Texture2D savableTexture = new Texture2D(renderTexture.width, renderTexture.height, TextureFormat.ARGB32, false);
            savableTexture.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
            savableTexture.Apply();

            RenderTexture.active = previousRenderTexture;

            return savableTexture;
        }
        public static float GetSimilarityCoeficent(Color color, Color otherColor, float hMult, float sMult, float vMult)
        {
            Color.RGBToHSV(color, out float h, out float s, out float v);
            Color.RGBToHSV(otherColor, out float otherH, out float otherS, out float otherV);

            float hVal = 1 - Mathf.Abs(h - otherH) * hMult;
            float sVal = 1 - Mathf.Abs(s - otherS) * sMult;
            float vVal = 1 - Mathf.Abs(v - otherV) * vMult;
            return (hVal + sVal + vVal) / 3;

        }
    }
}
#endif