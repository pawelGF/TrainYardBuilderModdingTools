#if UNITY_EDITOR
using System;
using System.Collections;
using System.Reflection;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace CustomObjectsCreation.Editor
{
    [CustomPropertyDrawer(typeof(SerializableGuid))]
    public class SerializableGuidPropertyDrawer : PropertyDrawer
    {
        SerializedProperty serializedGuidByteArrayProp;
        byte[] guidBytes = new byte[16];
        public override void OnGUI(Rect rect, SerializedProperty property, GUIContent label)
        {
            serializedGuidByteArrayProp = property.FindPropertyRelative("guidByteArray");
            if (serializedGuidByteArrayProp.arraySize != 16)
            {
                EditorSerializationUtils.SetValue(property, new SerializableGuid(Guid.Empty));
            }
            Guid guid = GetGuid(serializedGuidByteArrayProp, guidBytes);
            if (guid == Guid.Empty)
            {
                SetGuid(serializedGuidByteArrayProp, Guid.NewGuid());
            }
            float buttonWidth = 120;
            Rect guidLabelRect = rect;
            guidLabelRect.width -= buttonWidth;
            Rect buttonRect = rect;
            buttonRect.width = buttonWidth;
            buttonRect.x = rect.width - buttonWidth + 20;
            string guidString = GetGuid(serializedGuidByteArrayProp, guidBytes).ToString();
            // Draw fields - passs GUIContent.none to each so they are drawn without labels
            GUI.enabled = false;
            EditorGUI.LabelField(guidLabelRect, guidString);
            GUI.enabled = true;
            if (GUI.Button(buttonRect, "Create new"))
            {
                SetGuid(serializedGuidByteArrayProp, Guid.NewGuid());
            }
        }
        public static Guid GetGuid(SerializedProperty guidByteArrayProp, byte[] guidBytesArray)
        {
            int arraySize = guidByteArrayProp.arraySize;
            for (int i = 0; i < arraySize; ++i)
            {
                SerializedProperty byteProp = guidByteArrayProp.GetArrayElementAtIndex(i);
                guidBytesArray[i] = (byte)byteProp.intValue;
            }
            Guid guid;

            try
            {
                guid = new Guid(guidBytesArray);
            }
            catch
            {
                guid = Guid.Empty;
            }
            return guid;
        }

        public static void SetGuid(SerializedProperty guidByteArrayProp, Guid guid)
        {
            byte[] guidBytesArray = guid.ToByteArray();
            int arraySize = guidBytesArray.Length;
            Undo.RecordObject(guidByteArrayProp.serializedObject.targetObject, "Set guid");

            for (int i = 0; i < guidByteArrayProp.arraySize; ++i)
            {
                SerializedProperty byteProp = guidByteArrayProp.GetArrayElementAtIndex(i);
                byteProp.intValue = guidBytesArray[i];
            }
            guidByteArrayProp.serializedObject.ApplyModifiedProperties();
        }


    }
}

namespace CustomObjectsCreation.Editor
{
    public static class EditorSerializationUtils
    {
        public static void SetValue(SerializedProperty property, object value)
        {
            Undo.RecordObject(property.serializedObject.targetObject, $"Set {property.name}");

            SetValueNoRecord(property, value);

            EditorUtility.SetDirty(property.serializedObject.targetObject);
            property.serializedObject.ApplyModifiedProperties();
        }

        public static FieldInfo GetFieldDeep(Type type, string name)
        {
            bool found = false;
            do
            {
                FieldInfo[] fields = type.GetFields(BindingFlags.Default | BindingFlags.NonPublic | BindingFlags.Instance);
                FieldInfo field = default;
                foreach (FieldInfo foundField in fields)
                {
                    if (foundField.Name == name)
                    {
                        field = foundField;
                        break;
                    }
                }
                if (field != default)
                {
                    return field;
                }
                else
                {
                    type = type.BaseType;
                }
            } while (!found && type != null);

            return null;
        }



        /// (Extension) Set the value of the serialized property, but do not record the change.
        /// The change will not be persisted unless you call SetDirty and ApplyModifiedProperties.
        public static void SetValueNoRecord(SerializedProperty property, object value)
        {
            string propertyPath = property.propertyPath;
            object container = property.serializedObject.targetObject;

            int i = 0;
            NextPathComponent(propertyPath, ref i, out PropertyPathComponent deferredToken);
            while (NextPathComponent(propertyPath, ref i, out PropertyPathComponent token))
            {
                container = GetPathComponentValue(container, deferredToken);
                deferredToken = token;
            }
            Debug.Assert(!container.GetType().IsValueType, $"Cannot use SerializedObject.SetValue on a struct object, as the result will be set on a temporary.  Either change {container.GetType().Name} to a class, or use SetValue with a parent member.");
            SetPathComponentValue(container, deferredToken, value);
        }

        // Union type representing either a property name or array element index.  The element
        // index is valid only if propertyName is null.
        struct PropertyPathComponent
        {
            public string propertyName;
            public int elementIndex;
        }

        static Regex arrayElementRegex = new(@"\GArray\.data\[(\d+)\]", RegexOptions.Compiled);

        // Parse the next path component from a SerializedProperty.propertyPath.  For simple field/property access,
        // this is just tokenizing on '.' and returning each field/property name.  Array/list access is via
        // the pseudo-property "Array.data[N]", so this method parses that and returns just the array/list index N.
        //
        // Call this method repeatedly to access all path components.  For example:
        //
        //      string propertyPath = "quests.Array.data[0].goal";
        //      int i = 0;
        //      NextPropertyPathToken(propertyPath, ref i, out var component);
        //          => component = { propertyName = "quests" };
        //      NextPropertyPathToken(propertyPath, ref i, out var component) 
        //          => component = { elementIndex = 0 };
        //      NextPropertyPathToken(propertyPath, ref i, out var component) 
        //          => component = { propertyName = "goal" };
        //      NextPropertyPathToken(propertyPath, ref i, out var component) 
        //          => returns false
        static bool NextPathComponent(string propertyPath, ref int index, out PropertyPathComponent component)
        {
            component = new PropertyPathComponent();

            if (index >= propertyPath.Length)
                return false;

            Match arrayElementMatch = arrayElementRegex.Match(propertyPath, index);
            if (arrayElementMatch.Success)
            {
                index += arrayElementMatch.Length + 1; // Skip past next '.'
                component.elementIndex = int.Parse(arrayElementMatch.Groups[1].Value);
                return true;
            }

            int dot = propertyPath.IndexOf('.', index);
            if (dot == -1)
            {
                component.propertyName = propertyPath.Substring(index);
                index = propertyPath.Length;
            }
            else
            {
                component.propertyName = propertyPath.Substring(index, dot - index);
                index = dot + 1; // Skip past next '.'
            }

            return true;
        }

        static object GetPathComponentValue(object container, PropertyPathComponent component)
        {
            if (component.propertyName == null)
                return ((IList)container)[component.elementIndex];
            else
                return GetMemberValue(container, component.propertyName);
        }

        static void SetPathComponentValue(object container, PropertyPathComponent component, object value)
        {
            if (component.propertyName == null)
                ((IList)container)[component.elementIndex] = value;
            else
                SetMemberValue(container, component.propertyName, value);
        }

        static object GetMemberValue(object container, string name)
        {
            if (container == null)
                return null;
            Type type = container.GetType();
            FieldInfo field = GetFieldDeep(type, name);
            if (field != null)
            {
                return field.GetValue(container);
            }
            return null;
        }

        static void SetMemberValue(object container, string name, object value)
        {
            Type type = container.GetType();
            FieldInfo field = GetFieldDeep(type, name);
            if (field == null)
            {
                Debug.LogError($"Failed to set member {container}.{name} via reflection");
            }
            else
            {
                field.SetValue(container, value);
            }
        }
    }
}
#endif