/**
 * <copyright>
 * Tracks and Rails Asset Package by Zen Fulcrum
 * Copyright 2015 Zen Fulcrum LLC
 * Usage is subject to Unity's Asset Store EULA (https://unity3d.com/legal/as_terms)
 * </copyright>
 */
namespace ZenFulcrumCopy.Track
{

    using UnityEngine;
    using System;

    /**
	 * A "simple", lightweight, GameObject free transformation.
	 */
#pragma warning disable 660, 661 //==() implemented but not .Equals(), .Hash()
    [Serializable]
	public class SimpleTransform
	{
		public static readonly SimpleTransform identity = new();

		public Vector3 position;
		public Quaternion rotation;

		//public SimpleTransform(Vector3 origin = null, Quaternion rotation = null) {
		public SimpleTransform(Vector3 position = default(Vector3), Quaternion rotation = default(Quaternion))
		{
			this.position = position;
			this.rotation = rotation;

			//since the default quaternion is not the identity:
			if (rotation.w == 0 && rotation.x == 0 && rotation.y == 0 && rotation.z == 0)
				this.rotation.w = 1;
		}

		public SimpleTransform(SimpleTransform other)
		{
			position = other.position;
			rotation = other.rotation;
		}

		public SimpleTransform(Transform other)
		{
			position = other.position;
			rotation = other.rotation;
		}

		public SimpleTransform Clone()
		{
			return new SimpleTransform(this);
		}

		/** Takes any crazy values (non-unit quaternions, infinite/NaN position) and resets them to a reasonable default. */
		public SimpleTransform MakeValid()
		{
			if (rotation.w == 0 && rotation.x == 0 && rotation.y == 0 && rotation.z == 0)
				rotation.w = 1;
			if (float.IsNaN(position.x) || float.IsInfinity(position.x)) position.x = 0;
			if (float.IsNaN(position.y) || float.IsInfinity(position.y)) position.y = 0;
			if (float.IsNaN(position.z) || float.IsInfinity(position.z)) position.z = 0;

			if (float.IsNaN(rotation.x) || float.IsNaN(rotation.y) || float.IsNaN(rotation.z) || float.IsNaN(rotation.w))
			{
				rotation = Quaternion.identity;
			}

			//normalize the rotation quaternion (UnityEditor.Handles complains a lot about nearly-but-not-quite-unit quaternions)
			float magnitudeInv = 1 / Mathf.Sqrt(rotation.x * rotation.x + rotation.y * rotation.y + rotation.z * rotation.z + rotation.w * rotation.w);
			rotation.x *= magnitudeInv;
			rotation.y *= magnitudeInv;
			rotation.z *= magnitudeInv;
			rotation.w *= magnitudeInv;

			return this;
		}

		public void ApplyTo(Transform t)
		{
			t.rotation = rotation;
			t.position = position;
		}

		public void SetIdentity()
		{
			position = new Vector3(0, 0, 0);
			rotation = Quaternion.identity;
		}

		/** Retaining position, turns the rotation 180 around the y axis *before* the actual rotation. */
		public SimpleTransform AboutFace()
		{
			rotation = rotation * Quaternion.AngleAxis(180, Vector3.up);
			return this;
		}

		public SimpleTransform AboutFaced()
		{
			SimpleTransform ret = new SimpleTransform(this);
			return ret.AboutFace();
		}

		public SimpleTransform Scale(Vector3 scale)
		{
			position = Vector3.Scale(position, scale);
			return this;
		}

		public SimpleTransform Scaled(Vector3 scale)
		{
			SimpleTransform ret = new SimpleTransform(this);
			ret.Scale(scale);
			return ret;
		}

		/**
		 * Returns a SimpleTransform converted from our own local coordinates to global coordinates, 
		 * based on being inside/under the transform of the given parent.
		 */
		public SimpleTransform LocalToAbsolute(Transform parent)
		{
			return parent * Scaled(parent.lossyScale);
		}

		public Vector3 forward
		{
			get { return rotation * Vector3.forward; }
		}

		public Vector3 backward
		{
			//oops: "backward" != "back"
			get { return rotation * Vector3.back; }
		}

		public Vector3 up
		{
			get { return rotation * Vector3.up; }
		}

		public Vector3 down
		{
			get { return rotation * Vector3.down; }
		}

		public Vector3 right
		{
			get { return rotation * Vector3.right; }
		}

		public Vector3 left
		{
			get { return rotation * Vector3.left; }
		}

		public override string ToString()
		{
			return "(" + position + ", " + rotation + ")";
		}

		public static SimpleTransform Lerp(SimpleTransform a, SimpleTransform b, float percent)
		{
			return new SimpleTransform(
				Vector3.Lerp(a.position, b.position, percent),
				Quaternion.Slerp(a.rotation, b.rotation, percent)
			);
		}

		public static Vector3 operator *(SimpleTransform t, Vector3 v)
		{
			return t.rotation * v + t.position;
		}

		public static SimpleTransform operator *(Transform a, SimpleTransform b)
		{
			SimpleTransform ret = new SimpleTransform();
			ret.rotation = a.rotation * b.rotation;
			ret.position = a.position + a.rotation * b.position;
			return ret;
		}

		public static SimpleTransform operator *(SimpleTransform a, Transform b)
		{
			SimpleTransform ret = new SimpleTransform();
			ret.rotation = a.rotation * b.rotation;
			ret.position = a.position + a.rotation * b.position;
			return ret;
		}

		public static SimpleTransform operator *(SimpleTransform a, SimpleTransform b)
		{
			SimpleTransform ret = new SimpleTransform();
			ret.rotation = a.rotation * b.rotation;
			ret.position = a.position + a.rotation * b.position;
			return ret;
		}

		public static bool operator ==(SimpleTransform a, SimpleTransform b)
		{
			if (ReferenceEquals(a, null))
			{
				return ReferenceEquals(b, null);
			}
			else if (ReferenceEquals(b, null))
			{
				return false;
			}
			else
			{
				return a.position == b.position && a.rotation == b.rotation;
			}
		}

		public static bool operator !=(SimpleTransform a, SimpleTransform b)
		{
			return !(a == b);
		}

		public static implicit operator bool(SimpleTransform t)
		{
			return !ReferenceEquals(t, null);
		}

	}

}

