using System.Collections.Generic;
using UnityEngine;

namespace CustomObjectsCreation
{
    [ExecuteAlways]
    public class GridObjectData : MonoBehaviour
    {
        // CONST
        const int MinPrice = 1;

        // PUBLIC
        // depreciated
        [HideInInspector] public bool setEnglishNameFromPrefabName = true;
        public List<LocaleName> LocalizedName = new();
        public GridObjectCategory Category;
        
        [Min(MinPrice)] [HideInInspector] public int Price = 1; // depreciated
        public bool CanOnlyRotate90Degrees = true;
        public bool canBeDirty = false;
        
        public List<PlacableTags> Tags = new();
        public List<GridPlacementLayer> ValidPlacementLayers = new() { GridPlacementLayer.Default };
        
        // SERIALIZED
        [SerializeField] SerializableGuid guid;


        // PRIVATE
        TrainSettings trainSettingsToDestroy;
        TrackSettings trackSettingsToDestroy;
        
        // PROPERTIES
        public System.Guid Guid => guid;

        // UNITY EVENTS
        void OnValidate()
        {
            bool hasTrainSettings = TryGetComponent(out TrainSettings trainSettings);
            bool hasTrackSettings = TryGetComponent(out TrackSettings trackSettings);
            
            if (Category == GridObjectCategory.Train && hasTrainSettings == false)
                gameObject.AddComponent<TrainSettings>();
            else if(Category != GridObjectCategory.Train && hasTrainSettings) 
                trainSettingsToDestroy = trainSettings;

            if (Category == GridObjectCategory.Tracks && hasTrackSettings == false)
                gameObject.AddComponent<TrackSettings>();
            else if (Category != GridObjectCategory.Tracks && hasTrackSettings) 
                trackSettingsToDestroy = trackSettings;
        }

        void Update()
        {
            transform.localScale = Vector3.one;
            if(trainSettingsToDestroy != null) 
                DestroyImmediate(trainSettingsToDestroy);
            if(trackSettingsToDestroy != null) 
                DestroyImmediate(trackSettingsToDestroy);
        }

        // METHODS
        public enum GridObjectCategory
        {
            Decoration,
            Train,
            Tracks,
            TrainCarriage,
            Building,
        }
        public enum GridPlacementLayer
        {
            Default = 0,
            Rails = 1
        }
    }
}