using System;
using System.Collections.Generic;
using UnityEngine;

namespace CustomObjectsCreation
{
    [Serializable]
    public struct SerializableGuid : ISerializationCallbackReceiver
    {
        [SerializeField]
        byte[] guidByteArray;

        public byte[] GuidByteArray
        {
            get
            {
                if (guidByteArray == null || guidByteArray.Length != 16)
                {
                    guidByteArray = new byte[16];
                }
                return guidByteArray;
            }
        }
        public Guid Value => guidByteArray == null || guidByteArray.Length != 16 ? Guid.Empty : new Guid(guidByteArray);
        public SerializableGuid(Guid guid)
        {
            guidByteArray = guid.ToByteArray();
        }

        public SerializableGuid(byte[] byteArray)
        {
            guidByteArray = new byte[16];
            Array.Copy(byteArray, guidByteArray, 16);
        }

        public override bool Equals(object obj)
        {
            return obj is SerializableGuid guid &&
                ItemsSequenceEqual(GuidByteArray, guid.guidByteArray);
        }

        public override int GetHashCode()
        {
            return -1324198676 + new Guid(GuidByteArray).GetHashCode();
        }

        public override string ToString() => new Guid(GuidByteArray).ToString();

        public void OnBeforeSerialize()
        {
        }

        public void OnAfterDeserialize()
        {
            if (guidByteArray == null || guidByteArray.Length != 16)
            {
                guidByteArray = new byte[16];
            }
        }

        public static bool operator ==(SerializableGuid a, SerializableGuid b) => a.Value == b.Value;
        public static bool operator !=(SerializableGuid a, SerializableGuid b) => a.Value != b.Value;
        public static implicit operator SerializableGuid(Guid guid) => new(guid);
        public static implicit operator Guid(SerializableGuid serializable) => serializable.Value;
        public static implicit operator SerializableGuid(string serializedGuid)
        {
            if (string.IsNullOrEmpty(serializedGuid))
            {
                return new SerializableGuid(Guid.Empty);
            }
            return new SerializableGuid(new Guid(serializedGuid));
        }
        public static implicit operator string(SerializableGuid serializedGuid) => serializedGuid.ToString();

        public static bool ItemsSequenceEqual<T>(IList<T> list1, IList<T> list2)
        {
            int count = list1.Count;
            int otherCount = list2.Count;
            if (count != otherCount)
            {
                return false;
            }
            for (int i = 0; i < count; i++)
            {
                T item1 = list1[i];
                T item2 = list2[i];

                if (item1.Equals(item2) == false)
                {
                    return false;
                }
            }
            return true;
        }
    }
}