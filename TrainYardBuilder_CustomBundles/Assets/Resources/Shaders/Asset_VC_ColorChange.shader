// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TYB/Asset_VC_ColorChange"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_C0("C0", Color) = (1,1,1,0)
		_C1("C1", Color) = (1,1,1,0)
		_C2("C2", Color) = (1,1,1,0)
		_C3("C3", Color) = (1,1,1,0)
		_C4("C4", Color) = (1,1,1,0)
		_C5("C5", Color) = (1,1,1,0)
		_C6("C6", Color) = (1,1,1,0)
		_C7("C7", Color) = (1,1,1,0)
		_C8("C8", Color) = (1,1,1,0)
		_C9("C9", Color) = (1,1,1,0)
		_C10("C10", Color) = (1,1,1,0)
		[Toggle(_FAKELIGHT_ON)] _FakeLight("FakeLight", Float) = 0
		_LightPower("LightPower", Range( 0 , 3)) = 0
		_Texture0("Texture 0", 2D) = "white" {}
		_ShadowStrenght("ShadowStrenght", Range( 0 , 1)) = 0.5
		_ReflectionPower("ReflectionPower", Range( 0 , 1)) = 0.5
		_ReflectionSmoothness("ReflectionSmoothness", Range( 0 , 1)) = 0.1
		_NormalStrenght("NormalStrenght", Range( 0 , 1)) = 0.12
		_ShadowSharpness("ShadowSharpness", Range( 0 , 1)) = 0.01
		_SnowAmount("Snow Amount", Range( 0 , 2)) = 0
		_HighlightC0("HighlightC0", Range( 0 , 1)) = 0
		_HighlightC1("HighlightC1", Range( 0 , 1)) = 0
		_HighlightC2("HighlightC2", Range( 0 , 1)) = 0
		_HighlightC3("HighlightC3", Range( 0 , 1)) = 0
		_HighlightC4("HighlightC4", Range( 0 , 1)) = 0
		_HighlightC5("HighlightC5", Range( 0 , 1)) = 0
		_HighlightC6("HighlightC6", Range( 0 , 1)) = 0
		_HighlightC7("HighlightC7", Range( 0 , 1)) = 0
		_HighlightC8("HighlightC8", Range( 0 , 1)) = 0
		_HighlightC9("HighlightC9", Range( 0 , 1)) = 0
		_HighlightC10("HighlightC10", Range( 0 , 1)) = 0
		_GrungeStrength("GrungeStrength", Range( 0 , 1)) = 0
		_GrungeDirtTexture("GrungeDirtTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120112
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _FAKELIGHT_ON
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 lightmapUVOrVertexSH : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Texture0_ST;
			float4 _C10;
			float4 _C9;
			float4 _C8;
			float4 _C6;
			float4 _C5;
			float4 _C4;
			float4 _C7;
			float4 _C2;
			float4 _C1;
			float4 _C0;
			float4 _C3;
			float _HighlightC3;
			float _ReflectionSmoothness;
			float _LightPower;
			float _ShadowStrenght;
			float _GrungeStrength;
			float _SnowAmount;
			float _NormalStrenght;
			float _HighlightC10;
			float _HighlightC0;
			float _HighlightC8;
			float _HighlightC7;
			float _ReflectionPower;
			float _HighlightC6;
			float _HighlightC1;
			float _HighlightC5;
			float _HighlightC4;
			float _HighlightC2;
			float _HighlightC9;
			float _ShadowSharpness;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture0;
			sampler2D _GrungeDirtTexture;
			uniform float4 _CameraDepthTexture_TexelSize;
			float DitherIsOn;


			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			
			float3 PerturbNormal107_g13( float3 surf_pos, float3 surf_norm, float height, float scale )
			{
				// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
				float3 vSigmaS = ddx( surf_pos );
				float3 vSigmaT = ddy( surf_pos );
				float3 vN = surf_norm;
				float3 vR1 = cross( vSigmaT , vN );
				float3 vR2 = cross( vN , vSigmaS );
				float fDet = dot( vSigmaS , vR1 );
				float dBs = ddx( height );
				float dBt = ddy( height );
				float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
				return normalize ( abs( fDet ) * vN - vSurfGrad );
			}
			
			inline float4 TriplanarSampling606( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord3.z = eyeDepth;
				float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				float3 vertexPos691 = v.positionOS.xyz;
				float4 ase_clipPos691 = TransformObjectToHClip((vertexPos691).xyz);
				float4 screenPos691 = ComputeScreenPos(ase_clipPos691);
				o.ase_texcoord9 = screenPos691;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.positionCS = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.ase_tangent = v.ase_tangent;
				o.texcoord1 = v.texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Texture0 = IN.ase_texcoord3.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode199 = tex2D( _Texture0, uv_Texture0 );
				float Base_R_BaseMap453 = tex2DNode199.r;
				float4 C0458 = _C0;
				float4 color495 = IsGammaSpace() ? float4(1,0.9774903,0.7216981,0) : float4(1,0.9495558,0.479512,0);
				float3 break484 = WorldPosition;
				float2 appendResult487 = (float2(( break484.x + _TimeParameters.x ) , break484.y));
				float simplePerlin3D480 = snoise( float3( appendResult487 ,  0.0 )*2.0 );
				simplePerlin3D480 = simplePerlin3D480*0.5 + 0.5;
				float temp_output_489_0 = (0.5 + (simplePerlin3D480 - 0.0) * (1.0 - 0.5) / (1.0 - 0.0));
				float clampResult483 = clamp( temp_output_489_0 , 0.0 , 1.0 );
				float4 Highlight493 = ( color495 * clampResult483 );
				float4 lerpResult574 = lerp( _C0 , Highlight493 , _HighlightC0);
				float4 lerpResult503 = lerp( _C1 , Highlight493 , _HighlightC1);
				float BaseMultiplier126 = 10.0;
				float VC_R_Rounded114 = round( ( IN.ase_color.r * BaseMultiplier126 ) );
				float clampResult144 = clamp( VC_R_Rounded114 , 0.0 , 1.0 );
				float4 lerpResult143 = lerp( lerpResult574 , lerpResult503 , clampResult144);
				float4 lerpResult522 = lerp( _C2 , Highlight493 , _HighlightC2);
				float clampResult146 = clamp( VC_R_Rounded114 , 1.0 , 2.0 );
				float4 lerpResult148 = lerp( lerpResult143 , lerpResult522 , (0.0 + (clampResult146 - 1.0) * (1.0 - 0.0) / (2.0 - 1.0)));
				float4 lerpResult527 = lerp( _C3 , Highlight493 , _HighlightC3);
				float clampResult158 = clamp( VC_R_Rounded114 , 2.0 , 3.0 );
				float4 lerpResult160 = lerp( lerpResult148 , lerpResult527 , (0.0 + (clampResult158 - 2.0) * (1.0 - 0.0) / (3.0 - 2.0)));
				float4 lerpResult532 = lerp( _C4 , Highlight493 , _HighlightC4);
				float clampResult165 = clamp( VC_R_Rounded114 , 3.0 , 4.0 );
				float4 lerpResult167 = lerp( lerpResult160 , lerpResult532 , (0.0 + (clampResult165 - 3.0) * (1.0 - 0.0) / (4.0 - 3.0)));
				float4 lerpResult537 = lerp( _C5 , Highlight493 , _HighlightC5);
				float clampResult170 = clamp( VC_R_Rounded114 , 4.0 , 5.0 );
				float4 lerpResult172 = lerp( lerpResult167 , lerpResult537 , (0.0 + (clampResult170 - 4.0) * (1.0 - 0.0) / (5.0 - 4.0)));
				float4 lerpResult542 = lerp( _C6 , Highlight493 , _HighlightC6);
				float clampResult177 = clamp( VC_R_Rounded114 , 5.0 , 6.0 );
				float4 lerpResult175 = lerp( lerpResult172 , lerpResult542 , (0.0 + (clampResult177 - 5.0) * (1.0 - 0.0) / (6.0 - 5.0)));
				float4 lerpResult547 = lerp( _C7 , Highlight493 , _HighlightC7);
				float clampResult182 = clamp( VC_R_Rounded114 , 6.0 , 7.0 );
				float4 lerpResult180 = lerp( lerpResult175 , lerpResult547 , (0.0 + (clampResult182 - 6.0) * (1.0 - 0.0) / (7.0 - 6.0)));
				float4 lerpResult552 = lerp( _C8 , Highlight493 , _HighlightC8);
				float clampResult187 = clamp( VC_R_Rounded114 , 7.0 , 8.0 );
				float4 lerpResult185 = lerp( lerpResult180 , lerpResult552 , (0.0 + (clampResult187 - 7.0) * (1.0 - 0.0) / (8.0 - 7.0)));
				float4 lerpResult557 = lerp( _C9 , Highlight493 , _HighlightC9);
				float clampResult192 = clamp( VC_R_Rounded114 , 8.0 , 9.0 );
				float4 lerpResult190 = lerp( lerpResult185 , lerpResult557 , (0.0 + (clampResult192 - 8.0) * (1.0 - 0.0) / (9.0 - 8.0)));
				float4 lerpResult562 = lerp( _C10 , Highlight493 , _HighlightC10);
				float clampResult196 = clamp( VC_R_Rounded114 , 9.0 , 10.0 );
				float4 lerpResult198 = lerp( lerpResult190 , lerpResult562 , (0.0 + (clampResult196 - 9.0) * (1.0 - 0.0) / (10.0 - 9.0)));
				float4 ColorMap161 = lerpResult198;
				float Base_A_Mask455 = tex2DNode199.a;
				float4 lerpResult442 = lerp( ( Base_R_BaseMap453 * C0458 ) , ( ColorMap161 * Base_R_BaseMap453 ) , Base_A_Mask455);
				float4 AlbedoColor470 = lerpResult442;
				float4 color586 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
				float3 surf_pos107_g13 = WorldPosition;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 surf_norm107_g13 = ase_worldNormal;
				float Base_B_Height454 = tex2DNode199.b;
				float height107_g13 = Base_B_Height454;
				float lerpResult374 = lerp( 0.0 , 0.4 , _NormalStrenght);
				float scale107_g13 = lerpResult374;
				float3 localPerturbNormal107_g13 = PerturbNormal107_g13( surf_pos107_g13 , surf_norm107_g13 , height107_g13 , scale107_g13 );
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_worldToTangent = float3x3(ase_worldTangent,ase_worldBitangent,ase_worldNormal);
				float3 worldToTangentDir42_g13 = mul( ase_worldToTangent, localPerturbNormal107_g13);
				float3 temp_output_436_40 = worldToTangentDir42_g13;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal318 = temp_output_436_40;
				float3 worldNormal318 = float3(dot(tanToWorld0,tanNormal318), dot(tanToWorld1,tanNormal318), dot(tanToWorld2,tanNormal318));
				float3 WorldNormal444 = worldNormal318;
				float SnowVariable592 = saturate( ( WorldNormal444.y * _SnowAmount ) );
				float4 lerpResult580 = lerp( AlbedoColor470 , color586 , SnowVariable592);
				float4 triplanar606 = TriplanarSampling606( _GrungeDirtTexture, WorldPosition, ase_worldNormal, 1.0, float2( 2,2 ), 1.0, 0 );
				float4 Dirt608 = ( triplanar606 * 0.4 );
				float clampResult625 = clamp( (0.0 + (pow( triplanar606.r , 0.1 ) - 0.5) * (1.0 - 0.0) / (0.925 - 0.5)) , 0.0 , 1.0 );
				float lerpResult613 = lerp( 0.0 , clampResult625 , _GrungeStrength);
				float DirtMask611 = lerpResult613;
				float4 lerpResult603 = lerp( lerpResult580 , Dirt608 , DirtMask611);
				float dotResult242 = dot( WorldNormal444 , _MainLightPosition.xyz );
				float ShadowValue462 = ( 1.0 - _ShadowStrenght );
				float LightDirect465 = (ShadowValue462 + (max( dotResult242 , 0.0 ) - 0.0) * (1.0 - ShadowValue462) / (1.0 - 0.0));
				float3 bakedGI243 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, WorldNormal444);
				Light ase_mainLight = GetMainLight( ShadowCoords );
				MixRealtimeAndBakedGI(ase_mainLight, WorldNormal444, bakedGI243, half4(0,0,0,0));
				float3 LightIndirect451 = bakedGI243;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float lerpResult599 = lerp( 10.0 , 1.0 , _ReflectionSmoothness);
				float3 temp_output_330_0 = SHADERGRAPH_REFLECTION_PROBE(ase_worldViewDir,WorldNormal444,lerpResult599);
				float3 temp_cast_2 = (_ReflectionPower).xxx;
				float3 Reflections448 = (float3( 0,0,0 ) + (temp_output_330_0 - float3( 0,0,0 )) * (temp_cast_2 - float3( 0,0,0 )) / (float3( 1,1,1 ) - float3( 0,0,0 )));
				float ase_lightAtten = 0;
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float lerpResult342 = lerp( 0.75 , 15.0 , _ShadowSharpness);
				float clampResult404 = clamp( pow( ase_lightAtten , pow( lerpResult342 , 2.0 ) ) , 0.0 , 1.0 );
				float LightAtmospheric473 = (ShadowValue462 + (clampResult404 - 0.0) * (1.0 - ShadowValue462) / (1.0 - 0.0));
				float fresnelNdotV249 = dot( WorldNormal444, ase_worldViewDir );
				float fresnelNode249 = ( 0.0 + 0.0 * pow( 1.0 - fresnelNdotV249, 6.0 ) );
				float4 lerpResult203 = lerp( ( lerpResult603 * float4( ( ( ( LightDirect465 + LightIndirect451 ) * _LightPower ) + Reflections448 ) , 0.0 ) * LightAtmospheric473 ) , float4( ( LightIndirect451 + Reflections448 ) , 0.0 ) , fresnelNode249);
				#ifdef _FAKELIGHT_ON
				float4 staticSwitch244 = lerpResult203;
				#else
				float4 staticSwitch244 = AlbedoColor470;
				#endif
				float4 FinalAlbedo377 = staticSwitch244;
				float4 temp_cast_6 = (0.0).xxxx;
				float4 temp_cast_7 = (1.0).xxxx;
				float4 clampResult577 = clamp( FinalAlbedo377 , temp_cast_6 , temp_cast_7 );
				
				float Base_G_Alpha375 = tex2DNode199.g;
				float eyeDepth = IN.ase_texcoord3.z;
				float temp_output_680_0 = ( 0.0 + _ProjectionParams.y );
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen687 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither687 = Dither8x8Bayer( fmod(clipScreen687.x, 8), fmod(clipScreen687.y, 8) );
				float4 screenPos691 = IN.ase_texcoord9;
				float4 ase_screenPosNorm691 = screenPos691 / screenPos691.w;
				ase_screenPosNorm691.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm691.z : ase_screenPosNorm691.z * 0.5 + 0.5;
				float screenDepth691 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm691.xy ),_ZBufferParams);
				float distanceDepth691 = saturate( abs( ( screenDepth691 - LinearEyeDepth( ase_screenPosNorm691.z,_ZBufferParams ) ) / ( 0.2 ) ) );
				float DitherFade689 = ( ( ( ( ( eyeDepth + -temp_output_680_0 ) / ( 0.2 - temp_output_680_0 ) ) - dither687 ) + ( 1.0 - distanceDepth691 ) ) + ( 1.0 - DitherIsOn ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = clampResult577.rgb;
				float Alpha = ( Base_G_Alpha375 * DitherFade689 );
				float AlphaClipThreshold = 0.1;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.positionCS, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120112
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile _ DOTS_INSTANCING_ON

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Texture0_ST;
			float4 _C10;
			float4 _C9;
			float4 _C8;
			float4 _C6;
			float4 _C5;
			float4 _C4;
			float4 _C7;
			float4 _C2;
			float4 _C1;
			float4 _C0;
			float4 _C3;
			float _HighlightC3;
			float _ReflectionSmoothness;
			float _LightPower;
			float _ShadowStrenght;
			float _GrungeStrength;
			float _SnowAmount;
			float _NormalStrenght;
			float _HighlightC10;
			float _HighlightC0;
			float _HighlightC8;
			float _HighlightC7;
			float _ReflectionPower;
			float _HighlightC6;
			float _HighlightC1;
			float _HighlightC5;
			float _HighlightC4;
			float _HighlightC2;
			float _HighlightC9;
			float _ShadowSharpness;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture0;
			uniform float4 _CameraDepthTexture_TexelSize;
			float DitherIsOn;


			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord2.z = eyeDepth;
				float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 vertexPos691 = v.positionOS.xyz;
				float4 ase_clipPos691 = TransformObjectToHClip((vertexPos691).xyz);
				float4 screenPos691 = ComputeScreenPos(ase_clipPos691);
				o.ase_texcoord4 = screenPos691;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.normalOS );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Texture0 = IN.ase_texcoord2.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode199 = tex2D( _Texture0, uv_Texture0 );
				float Base_G_Alpha375 = tex2DNode199.g;
				float eyeDepth = IN.ase_texcoord2.z;
				float temp_output_680_0 = ( 0.0 + _ProjectionParams.y );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen687 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither687 = Dither8x8Bayer( fmod(clipScreen687.x, 8), fmod(clipScreen687.y, 8) );
				float4 screenPos691 = IN.ase_texcoord4;
				float4 ase_screenPosNorm691 = screenPos691 / screenPos691.w;
				ase_screenPosNorm691.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm691.z : ase_screenPosNorm691.z * 0.5 + 0.5;
				float screenDepth691 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm691.xy ),_ZBufferParams);
				float distanceDepth691 = saturate( abs( ( screenDepth691 - LinearEyeDepth( ase_screenPosNorm691.z,_ZBufferParams ) ) / ( 0.2 ) ) );
				float DitherFade689 = ( ( ( ( ( eyeDepth + -temp_output_680_0 ) / ( 0.2 - temp_output_680_0 ) ) - dither687 ) + ( 1.0 - distanceDepth691 ) ) + ( 1.0 - DitherIsOn ) );
				

				float Alpha = ( Base_G_Alpha375 * DitherFade689 );
				float AlphaClipThreshold = 0.1;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #define ASE_FOG 1
            #define _ALPHATEST_ON 1
            #define ASE_SRP_VERSION 120112
            #define REQUIRE_DEPTH_TEXTURE 1


            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Texture0_ST;
			float4 _C10;
			float4 _C9;
			float4 _C8;
			float4 _C6;
			float4 _C5;
			float4 _C4;
			float4 _C7;
			float4 _C2;
			float4 _C1;
			float4 _C0;
			float4 _C3;
			float _HighlightC3;
			float _ReflectionSmoothness;
			float _LightPower;
			float _ShadowStrenght;
			float _GrungeStrength;
			float _SnowAmount;
			float _NormalStrenght;
			float _HighlightC10;
			float _HighlightC0;
			float _HighlightC8;
			float _HighlightC7;
			float _ReflectionPower;
			float _HighlightC6;
			float _HighlightC1;
			float _HighlightC5;
			float _HighlightC4;
			float _HighlightC2;
			float _HighlightC9;
			float _ShadowSharpness;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture0;
			uniform float4 _CameraDepthTexture_TexelSize;
			float DitherIsOn;


			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord2.z = eyeDepth;
				float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 vertexPos691 = v.positionOS.xyz;
				float4 ase_clipPos691 = TransformObjectToHClip((vertexPos691).xyz);
				float4 screenPos691 = ComputeScreenPos(ase_clipPos691);
				o.ase_texcoord4 = screenPos691;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				o.positionCS = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Texture0 = IN.ase_texcoord2.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode199 = tex2D( _Texture0, uv_Texture0 );
				float Base_G_Alpha375 = tex2DNode199.g;
				float eyeDepth = IN.ase_texcoord2.z;
				float temp_output_680_0 = ( 0.0 + _ProjectionParams.y );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen687 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither687 = Dither8x8Bayer( fmod(clipScreen687.x, 8), fmod(clipScreen687.y, 8) );
				float4 screenPos691 = IN.ase_texcoord4;
				float4 ase_screenPosNorm691 = screenPos691 / screenPos691.w;
				ase_screenPosNorm691.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm691.z : ase_screenPosNorm691.z * 0.5 + 0.5;
				float screenDepth691 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm691.xy ),_ZBufferParams);
				float distanceDepth691 = saturate( abs( ( screenDepth691 - LinearEyeDepth( ase_screenPosNorm691.z,_ZBufferParams ) ) / ( 0.2 ) ) );
				float DitherFade689 = ( ( ( ( ( eyeDepth + -temp_output_680_0 ) / ( 0.2 - temp_output_680_0 ) ) - dither687 ) + ( 1.0 - distanceDepth691 ) ) + ( 1.0 - DitherIsOn ) );
				

				float Alpha = ( Base_G_Alpha375 * DitherFade689 );
				float AlphaClipThreshold = 0.1;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

            #define ASE_FOG 1
            #define _ALPHATEST_ON 1
            #define ASE_SRP_VERSION 120112
            #define REQUIRE_DEPTH_TEXTURE 1


            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Texture0_ST;
			float4 _C10;
			float4 _C9;
			float4 _C8;
			float4 _C6;
			float4 _C5;
			float4 _C4;
			float4 _C7;
			float4 _C2;
			float4 _C1;
			float4 _C0;
			float4 _C3;
			float _HighlightC3;
			float _ReflectionSmoothness;
			float _LightPower;
			float _ShadowStrenght;
			float _GrungeStrength;
			float _SnowAmount;
			float _NormalStrenght;
			float _HighlightC10;
			float _HighlightC0;
			float _HighlightC8;
			float _HighlightC7;
			float _ReflectionPower;
			float _HighlightC6;
			float _HighlightC1;
			float _HighlightC5;
			float _HighlightC4;
			float _HighlightC2;
			float _HighlightC9;
			float _ShadowSharpness;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture0;
			uniform float4 _CameraDepthTexture_TexelSize;
			float DitherIsOn;


			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord.z = eyeDepth;
				float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 vertexPos691 = v.positionOS.xyz;
				float4 ase_clipPos691 = TransformObjectToHClip((vertexPos691).xyz);
				float4 screenPos691 = ComputeScreenPos(ase_clipPos691);
				o.ase_texcoord2 = screenPos691;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Texture0 = IN.ase_texcoord.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode199 = tex2D( _Texture0, uv_Texture0 );
				float Base_G_Alpha375 = tex2DNode199.g;
				float eyeDepth = IN.ase_texcoord.z;
				float temp_output_680_0 = ( 0.0 + _ProjectionParams.y );
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen687 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither687 = Dither8x8Bayer( fmod(clipScreen687.x, 8), fmod(clipScreen687.y, 8) );
				float4 screenPos691 = IN.ase_texcoord2;
				float4 ase_screenPosNorm691 = screenPos691 / screenPos691.w;
				ase_screenPosNorm691.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm691.z : ase_screenPosNorm691.z * 0.5 + 0.5;
				float screenDepth691 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm691.xy ),_ZBufferParams);
				float distanceDepth691 = saturate( abs( ( screenDepth691 - LinearEyeDepth( ase_screenPosNorm691.z,_ZBufferParams ) ) / ( 0.2 ) ) );
				float DitherFade689 = ( ( ( ( ( eyeDepth + -temp_output_680_0 ) / ( 0.2 - temp_output_680_0 ) ) - dither687 ) + ( 1.0 - distanceDepth691 ) ) + ( 1.0 - DitherIsOn ) );
				

				surfaceDescription.Alpha = ( Base_G_Alpha375 * DitherFade689 );
				surfaceDescription.AlphaClipThreshold = 0.1;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

            #define ASE_FOG 1
            #define _ALPHATEST_ON 1
            #define ASE_SRP_VERSION 120112
            #define REQUIRE_DEPTH_TEXTURE 1


            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Texture0_ST;
			float4 _C10;
			float4 _C9;
			float4 _C8;
			float4 _C6;
			float4 _C5;
			float4 _C4;
			float4 _C7;
			float4 _C2;
			float4 _C1;
			float4 _C0;
			float4 _C3;
			float _HighlightC3;
			float _ReflectionSmoothness;
			float _LightPower;
			float _ShadowStrenght;
			float _GrungeStrength;
			float _SnowAmount;
			float _NormalStrenght;
			float _HighlightC10;
			float _HighlightC0;
			float _HighlightC8;
			float _HighlightC7;
			float _ReflectionPower;
			float _HighlightC6;
			float _HighlightC1;
			float _HighlightC5;
			float _HighlightC4;
			float _HighlightC2;
			float _HighlightC9;
			float _ShadowSharpness;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture0;
			uniform float4 _CameraDepthTexture_TexelSize;
			float DitherIsOn;


			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			float4 _SelectionID;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord.z = eyeDepth;
				float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 vertexPos691 = v.positionOS.xyz;
				float4 ase_clipPos691 = TransformObjectToHClip((vertexPos691).xyz);
				float4 screenPos691 = ComputeScreenPos(ase_clipPos691);
				o.ase_texcoord2 = screenPos691;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				o.positionCS = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Texture0 = IN.ase_texcoord.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode199 = tex2D( _Texture0, uv_Texture0 );
				float Base_G_Alpha375 = tex2DNode199.g;
				float eyeDepth = IN.ase_texcoord.z;
				float temp_output_680_0 = ( 0.0 + _ProjectionParams.y );
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen687 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither687 = Dither8x8Bayer( fmod(clipScreen687.x, 8), fmod(clipScreen687.y, 8) );
				float4 screenPos691 = IN.ase_texcoord2;
				float4 ase_screenPosNorm691 = screenPos691 / screenPos691.w;
				ase_screenPosNorm691.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm691.z : ase_screenPosNorm691.z * 0.5 + 0.5;
				float screenDepth691 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm691.xy ),_ZBufferParams);
				float distanceDepth691 = saturate( abs( ( screenDepth691 - LinearEyeDepth( ase_screenPosNorm691.z,_ZBufferParams ) ) / ( 0.2 ) ) );
				float DitherFade689 = ( ( ( ( ( eyeDepth + -temp_output_680_0 ) / ( 0.2 - temp_output_680_0 ) ) - dither687 ) + ( 1.0 - distanceDepth691 ) ) + ( 1.0 - DitherIsOn ) );
				

				surfaceDescription.Alpha = ( Base_G_Alpha375 * DitherFade689 );
				surfaceDescription.AlphaClipThreshold = 0.1;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120112
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Texture0_ST;
			float4 _C10;
			float4 _C9;
			float4 _C8;
			float4 _C6;
			float4 _C5;
			float4 _C4;
			float4 _C7;
			float4 _C2;
			float4 _C1;
			float4 _C0;
			float4 _C3;
			float _HighlightC3;
			float _ReflectionSmoothness;
			float _LightPower;
			float _ShadowStrenght;
			float _GrungeStrength;
			float _SnowAmount;
			float _NormalStrenght;
			float _HighlightC10;
			float _HighlightC0;
			float _HighlightC8;
			float _HighlightC7;
			float _ReflectionPower;
			float _HighlightC6;
			float _HighlightC1;
			float _HighlightC5;
			float _HighlightC4;
			float _HighlightC2;
			float _HighlightC9;
			float _ShadowSharpness;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture0;
			uniform float4 _CameraDepthTexture_TexelSize;
			float DitherIsOn;


			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord1.z = eyeDepth;
				float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				float3 vertexPos691 = v.positionOS.xyz;
				float4 ase_clipPos691 = TransformObjectToHClip((vertexPos691).xyz);
				float4 screenPos691 = ComputeScreenPos(ase_clipPos691);
				o.ase_texcoord3 = screenPos691;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.normalOS);

				o.positionCS = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Texture0 = IN.ase_texcoord1.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 tex2DNode199 = tex2D( _Texture0, uv_Texture0 );
				float Base_G_Alpha375 = tex2DNode199.g;
				float eyeDepth = IN.ase_texcoord1.z;
				float temp_output_680_0 = ( 0.0 + _ProjectionParams.y );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen687 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither687 = Dither8x8Bayer( fmod(clipScreen687.x, 8), fmod(clipScreen687.y, 8) );
				float4 screenPos691 = IN.ase_texcoord3;
				float4 ase_screenPosNorm691 = screenPos691 / screenPos691.w;
				ase_screenPosNorm691.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm691.z : ase_screenPosNorm691.z * 0.5 + 0.5;
				float screenDepth691 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm691.xy ),_ZBufferParams);
				float distanceDepth691 = saturate( abs( ( screenDepth691 - LinearEyeDepth( ase_screenPosNorm691.z,_ZBufferParams ) ) / ( 0.2 ) ) );
				float DitherFade689 = ( ( ( ( ( eyeDepth + -temp_output_680_0 ) / ( 0.2 - temp_output_680_0 ) ) - dither687 ) + ( 1.0 - distanceDepth691 ) ) + ( 1.0 - DitherIsOn ) );
				

				surfaceDescription.Alpha = ( Base_G_Alpha375 * DitherFade689 );
				surfaceDescription.AlphaClipThreshold = 0.1;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.CommentaryNode;675;1210.826,2195.477;Inherit;False;1991.666;833.748;Scale depth from start to end;17;703;704;696;701;682;687;685;686;678;684;681;679;697;680;683;688;689;;0,0,0,1;0;0
Node;AmplifyShaderEditor.ProjectionParams;688;1244.717,2585.892;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;683;1244.802,2475.172;Float;False;Constant;_StartDitheringFade;Start Dithering Fade;36;1;[Header];Create;True;1;DITHER;0;0;False;1;Space(10);False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;680;1460.294,2478.704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;697;1529.793,2637.891;Inherit;False;779.8999;310.4042;Prevent small objects from dither;4;693;695;692;691;;0.9433962,0.8348588,0.502848,0.454902;0;0
Node;AmplifyShaderEditor.NegateNode;679;1621.681,2355.823;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;681;1247.385,2292.589;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;684;1612.267,2441.176;Float;False;Constant;_EndDitheringFade;End Dithering Fade;39;0;Create;True;0;0;0;False;0;False;0.2;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;678;1830.066,2453.076;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;686;1768.766,2297.277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;692;1557.493,2854.401;Inherit;False;Constant;_AlphaFadeDepth1;Alpha Fade Depth;12;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;695;1558.766,2690.806;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;685;1983.952,2298.186;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;687;1952.362,2548.65;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;691;1832.591,2775.856;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;682;2185.802,2300.082;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;693;2150.701,2775.607;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;701;2362.818,2659.753;Inherit;False;Global;DitherIsOn;DitherIsOn;38;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;317;-2710.133,1426.768;Inherit;True;Property;_Texture0;Texture 0;15;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;696;2366.193,2539.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;704;2665.494,2667.061;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;199;-2368.866,1408.864;Inherit;True;Property;_TYB_PackedTex;TYB_PackedTex;0;0;Create;True;0;0;0;False;0;False;-1;7b080005d5ecf4c4bbfeaeede6d3eeea;7b080005d5ecf4c4bbfeaeede6d3eeea;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;703;2844.614,2543.031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;375;-1891.974,1452.588;Inherit;False;Base_G_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;689;2975.428,2538.063;Inherit;False;DitherFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;2316.832,1773.549;Inherit;False;375;Base_G_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;690;2351.813,1852.327;Inherit;False;689;DitherFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;436;-2148.045,1889.603;Inherit;False;Normal From Height;-1;;13;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;1;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;439;-2688.705,1847.724;Inherit;False;Constant;_MaxNormalStrgh;MaxNormalStrgh;23;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;318;-1880.06,1801.15;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;444;-1666.444,1760.381;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;-2359.871,1772.611;Inherit;False;454;Base_B_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;374;-2328.702,1862.602;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.4;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;202;-2553.532,3663.081;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;340;-2270.262,3803.734;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;404;-2095.115,3799.487;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;319;-1889.299,3809.365;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;341;-2928.615,3813.885;Inherit;False;Property;_ShadowSharpness;ShadowSharpness;20;0;Create;True;0;0;0;False;0;False;0.01;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;342;-2617.687,3784.636;Inherit;False;3;0;FLOAT;0.75;False;1;FLOAT;15;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;343;-2443.676,3840.227;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;463;-2098.912,3949.709;Inherit;False;462;ShadowValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;473;-1700.782,3832.739;Inherit;False;LightAtmospheric;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;334;-1857.864,4264.669;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;321;-2364.924,4068.611;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;447;-2361.937,4223.047;Inherit;False;444;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;448;-1669.915,4295.894;Inherit;False;Reflections;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;243;-1979.157,3121.617;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;451;-1735.289,3120.498;Inherit;False;LightIndirect;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;-2164.024,3120.735;Inherit;False;444;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;446;-2393.549,3244.104;Inherit;False;444;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;242;-2194.453,3397.626;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;431;-2064.49,3394.048;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;238;-2462.708,3414.893;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;464;-2165.266,3511.138;Inherit;False;462;ShadowValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;326;-1911.625,3393.531;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;465;-1723.832,3394.15;Inherit;False;LightDirect;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;453;-2058.171,1381.838;Inherit;False;Base_R_BaseMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;454;-1972.202,1518.428;Inherit;False;Base_B_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;455;-2013.629,1619.358;Inherit;False;Base_A_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;10;-2648.025,880.7694;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-2349.976,899.6572;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-2553.778,1173.761;Inherit;False;BaseMultiplier;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-2726.778,1163.761;Inherit;False;Constant;_Float11;Float 11;11;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;112;-2186.83,900.3455;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-2023.201,900.9431;Inherit;False;VC_R_Rounded;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;-360.3312,2186.365;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-690.3434,2134.748;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;247;-726.1263,2030.119;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;336;-526.5603,2162.055;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;246;-1066.664,2195.669;Inherit;False;Property;_LightPower;LightPower;14;0;Create;True;0;0;0;False;0;False;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;452;-955.2892,2052.767;Inherit;False;451;LightIndirect;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;-963.3129,1960.377;Inherit;False;465;LightDirect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;467;-736.4861,2241.666;Inherit;False;448;Reflections;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;249;-447.6045,2717.423;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;445;-683.342,2739.822;Inherit;False;444;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;337;-307.1857,2514.522;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;474;-573.3159,2308.089;Inherit;False;473;LightAtmospheric;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;450;-519.0941,2464.518;Inherit;False;451;LightIndirect;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-524.0375,2571.367;Inherit;False;448;Reflections;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;477;-4601.773,473.2678;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;485;-5026.649,430.7643;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;481;-5406.732,664.9968;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;484;-5231.649,408.7643;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WorldPosInputsNode;488;-5664.179,240.2024;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;493;-4043.622,546.9968;Inherit;False;Highlight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;483;-4405.732,471.9968;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;494;-4152.832,448.1231;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;495;-4454.832,295.1231;Inherit;False;Constant;_HighlightColor;HighlightColor;19;0;Create;True;0;0;0;False;0;False;1,0.9774903,0.7216981,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;487;-5029.649,544.7644;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;480;-4903.732,633.9968;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;486;-5176.649,296.7643;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;492;-4932.179,349.2024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;491;-4777.179,316.2024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;489;-4652.179,747.2024;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;501;-4900.53,-8.063985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;502;-4744.53,-7.063985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;507;-4605.428,-8.86097;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;500;-5103,-9.501938;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;509;-4404.946,44.15405;Inherit;False;HighlightPulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-5140.223,1398.651;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-5141.901,1655.631;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-5142.332,1917.699;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;159;-4696.121,1867.303;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;3;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-5145.405,2168.014;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;165;-4891.321,2115.988;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;3;False;2;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;166;-4699.193,2117.618;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;3;False;2;FLOAT;4;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-5142.473,2421.557;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;170;-4888.389,2369.531;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;171;-4696.261,2371.162;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT;5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-5142.173,2678.957;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-5143.937,2934.677;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-5143.937,3190.401;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;177;-4888.09,2626.93;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;5;False;2;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;178;-4695.962,2628.561;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;5;False;2;FLOAT;6;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;182;-4889.854,2882.652;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;6;False;2;FLOAT;7;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;183;-4697.725,2884.282;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;6;False;2;FLOAT;7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;187;-4889.854,3138.376;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;7;False;2;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;188;-4697.725,3140.006;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;7;False;2;FLOAT;8;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-5140.41,3449.646;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;192;-4886.326,3397.621;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;8;False;2;FLOAT;9;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;193;-4694.199,3399.251;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;8;False;2;FLOAT;9;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-5144.462,3704.193;Inherit;False;114;VC_R_Rounded;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;196;-4890.379,3652.167;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;9;False;2;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;197;-4698.25,3653.798;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;9;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;141;-4633.982,1235.626;Inherit;False;Property;_C1;C1;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5283019,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;149;-4441.813,1547.766;Inherit;False;Property;_C2;C2;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;150;-4439.299,1824.812;Inherit;False;Property;_C3;C3;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;168;-4443.372,2075.127;Inherit;False;Property;_C4;C4;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;173;-4440.44,2327.673;Inherit;False;Property;_C5;C5;5;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;176;-4440.141,2585.072;Inherit;False;Property;_C6;C6;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;181;-4441.903,2840.794;Inherit;False;Property;_C7;C7;7;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;186;-4441.903,3096.518;Inherit;False;Property;_C8;C8;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;191;-4438.377,3355.762;Inherit;False;Property;_C9;C9;10;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;195;-4442.43,3610.308;Inherit;False;Property;_C10;C10;12;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3107657,0.8301887,0.09789959,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;147;-4697.913,1605.278;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;158;-4888.248,1865.673;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;144;-4885.954,1352.139;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;146;-4883.912,1605.282;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;142;-4641.86,1055.014;Inherit;False;Property;_C0;C0;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5283019,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;143;-3612.379,1259;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;148;-3553.278,1576.069;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;160;-3572.975,1820.858;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;167;-3576.048,2071.172;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;172;-3573.116,2324.716;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;175;-3572.817,2582.116;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;180;-3574.58,2837.837;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;185;-3574.58,3093.56;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;190;-3571.053,3352.805;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;198;-3575.105,3607.35;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;523;-5243.25,187.5509;Inherit;False;Constant;_HighlightSpeed;HighlightSpeed;21;0;Create;True;0;0;0;False;0;False;4;0;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;-4163.508,1594.091;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;522;-3774.643,1587.519;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;526;-4155.651,1849.107;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;527;-3766.787,1842.536;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;-4154.651,2101.108;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;532;-3765.788,2094.537;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;536;-4150.65,2351.107;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;537;-3761.788,2344.537;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;541;-4145.649,2609.106;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;542;-3756.788,2602.537;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;546;-4150.648,2863.106;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;547;-3761.788,2856.538;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;551;-4152.647,3121.106;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;552;-3763.788,3114.539;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;556;-4152.647,3371.105;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;557;-3763.789,3364.539;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;561;-4151.646,3636.105;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;562;-3762.789,3629.54;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;573;-4156.22,3774.384;Float;False;Property;_HighlightC10;HighlightC10;32;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;572;-4144.053,3513.936;Float;False;Property;_HighlightC9;HighlightC9;31;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;571;-4157.053,3245.936;Float;False;Property;_HighlightC8;HighlightC8;30;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;570;-4165.053,2994.936;Float;False;Property;_HighlightC7;HighlightC7;29;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;569;-4163.309,2742.48;Float;False;Property;_HighlightC6;HighlightC6;28;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;568;-4156.309,2483.48;Float;False;Property;_HighlightC5;HighlightC5;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;567;-4182.309,2227.479;Float;False;Property;_HighlightC4;HighlightC4;26;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;566;-4198.309,1970.48;Float;False;Property;_HighlightC3;HighlightC3;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;565;-4207.309,1718.48;Float;False;Property;_HighlightC2;HighlightC2;24;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;458;-4404.565,980.377;Inherit;False;C0;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;503;-3825.451,1295.095;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;574;-3879.053,1031.833;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;496;-4214.316,1301.667;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;575;-4268.053,1104.833;Inherit;False;493;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;564;-4222.309,1412.48;Float;False;Property;_HighlightC1;HighlightC1;23;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;576;-4200.053,1190.833;Float;False;Property;_HighlightC0;HighlightC0;22;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectionProbeNode;330;-2046.132,4224.893;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;437;-1544.934,2002.353;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-2305.98,2671.132;Inherit;False;Property;_ShadowStrenght;ShadowStrenght;16;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;325;-1967.828,2690.629;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;462;-1799.723,2701.713;Inherit;False;ShadowValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-2927.335,2602.424;Inherit;False;ColorMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;595;-2174.674,2200.933;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;593;-2565.007,2272.417;Inherit;True;Property;_TextureSample1;Texture Sample 0;33;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;a4e60d649c7f3f444b01ffe03e9d6658;a4e60d649c7f3f444b01ffe03e9d6658;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;596;-2148.982,2340.805;Inherit;False;592;SnowVariable;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;594;-1766.532,2090.904;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;599;-2575.458,4241.006;Inherit;False;3;0;FLOAT;10;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;333;-2889.863,4317.669;Inherit;False;Property;_ReflectionSmoothness;ReflectionSmoothness;18;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;335;-2447.809,4378.091;Inherit;False;Property;_ReflectionPower;ReflectionPower;17;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-2653.047,1960.385;Inherit;False;Property;_NormalStrenght;NormalStrenght;19;0;Create;True;0;0;0;False;0;False;0.12;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;-916.4584,1482.781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;583;-755.7593,1491.181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;586;-1040.392,1195.83;Inherit;False;Constant;_Color0;Color 0;7;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;588;-1245.552,1640.575;Float;False;Property;_SnowAmount;Snow Amount;21;0;Create;True;0;0;0;False;0;False;0;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;592;-718.7485,1605.531;Inherit;False;SnowVariable;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;580;-426.7004,1553.082;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;589;-1537.251,1374.103;Inherit;False;444;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;598;-1281.194,1390.645;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;472;-644.7133,1349.734;Inherit;False;470;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-1412.178,987.0372;Inherit;False;161;ColorMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;-1425.759,1072.863;Inherit;False;453;Base_R_BaseMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;-1139.594,961.9362;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;442;-556.8397,757.8895;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;443;-1068.24,653.5892;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;459;-1283.159,774.2641;Inherit;False;458;C0;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-1343.377,649.6551;Inherit;False;453;Base_R_BaseMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;457;-999.4037,839.8221;Inherit;False;455;Base_A_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;470;-367.3451,764.3005;Inherit;False;AlbedoColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;603;-238.8029,1743.472;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;604;-571.8283,1744.528;Inherit;False;608;Dirt;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;610;-561.3221,1840.808;Inherit;False;611;DirtMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;616;242.3174,1117.543;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;608;462.9259,1116.711;Inherit;False;Dirt;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;605;-240.3784,909.7489;Inherit;False;Property;_GrungeStrength;GrungeStrength;34;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;624;95.1456,916.5861;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;627;249.0918,919.8521;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;618;77.17957,1304.198;Inherit;False;Constant;_Float3;Float 3;36;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;629;-73.9082,1044.852;Inherit;False;Constant;_Float5;Float 5;36;0;Create;True;0;0;0;False;0;False;0.925;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;628;-73.9082,978.8521;Inherit;False;Constant;_Float4;Float 4;35;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;607;-565.1307,1001.242;Inherit;True;Property;_GrungeDirtTexture;GrungeDirtTexture;35;0;Create;True;0;0;0;False;0;False;466c3697c4a3a6948a82107a95bb3963;466c3697c4a3a6948a82107a95bb3963;False;white;LockedToTexture2D;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector3Node;630;-347.9082,1304.852;Inherit;False;Constant;_Vector0;Vector 0;35;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;642;-508.9082,1205.852;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;327;-799.8672,2836.465;Inherit;False;Constant;_DiffuseGlossiness;DiffuseGlossiness;15;0;Create;True;0;0;0;False;0;False;0;0;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;643;-747.9082,1214.852;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;631;-753.9082,1072.852;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;606;-213.5095,1095.331;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;Assets/GridObjects/Americana/Baked/Extra Textures/dirt_basecolor.png;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;2,2;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;482;-5667.732,410.9968;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;625;436.6636,919.0907;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;613;580.8578,792.7813;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;611;800.0951,886.5055;Inherit;False;DirtMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;377;320,2240;Inherit;False;FinalAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;471;-128,2240;Inherit;False;470;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;203;-64,2336;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;244;96,2240;Inherit;False;Property;_FakeLight;FakeLight;13;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;577;2572.832,1613.549;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;656;5192.799,1807.352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;663;5500.462,1930.462;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;667;5387.214,2121.648;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;672;5030.797,1527.112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;645;5078.488,1374.055;Inherit;False;Property;_DitherLevel;DitherLevel;36;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;644;5395.7,1466.215;Inherit;False;1;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;669;4231.515,1238.947;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;670;4850.315,1456.047;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;673;4644.915,1566.547;Inherit;False;Property;_seethr;seethr;37;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;647;4338.266,1643.304;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;674;4509.715,1262.347;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;657;4851.799,2031.352;Inherit;False;Property;_fade;fade;9;0;Create;True;0;0;0;False;0;False;0.55;0.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;658;4996.799,1899.352;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;655;4994.799,1739.352;Inherit;False;Property;_fademove;fade move;11;0;Create;True;0;0;0;False;0;False;0.27;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;648;4568.665,1864.923;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;659;4851.799,2223.352;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;661;4634.702,2346.898;Inherit;False;Constant;_AlphaFadeDepth;Alpha Fade Depth;12;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;666;5198.495,2160.225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;660;4627.2,2127.352;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;646;2572.832,1769.549;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;2573.832,1891.549;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;578;2381.832,1701.549;Inherit;False;Constant;_Float1;Float 1;30;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;579;2381.832,1637.549;Inherit;False;Constant;_Float2;Float 1;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;2349.832,1573.549;Inherit;False;377;FinalAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;212;-820.1134,955.9781;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;214;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;215;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;216;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;217;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;218;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;219;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;220;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;221;431.0522,1921.917;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;213;2764.832,1677.549;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;TYB/Asset_VC_ColorChange;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;21;Surface;0;638566448539866650;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;638479181453897798;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;638566447097369131;Meta Pass;0;0;Extra Pre Pass;0;638479181345683115;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;True;False;False;True;True;True;False;False;;False;0
WireConnection;680;0;683;0
WireConnection;680;1;688;2
WireConnection;679;0;680;0
WireConnection;678;0;684;0
WireConnection;678;1;680;0
WireConnection;686;0;681;0
WireConnection;686;1;679;0
WireConnection;685;0;686;0
WireConnection;685;1;678;0
WireConnection;691;1;695;0
WireConnection;691;0;692;0
WireConnection;682;0;685;0
WireConnection;682;1;687;0
WireConnection;693;0;691;0
WireConnection;696;0;682;0
WireConnection;696;1;693;0
WireConnection;704;0;701;0
WireConnection;199;0;317;0
WireConnection;199;7;317;1
WireConnection;703;0;696;0
WireConnection;703;1;704;0
WireConnection;375;0;199;2
WireConnection;689;0;703;0
WireConnection;436;20;456;0
WireConnection;436;110;374;0
WireConnection;318;0;436;40
WireConnection;444;0;318;0
WireConnection;374;1;439;0
WireConnection;374;2;338;0
WireConnection;340;0;202;0
WireConnection;340;1;343;0
WireConnection;404;0;340;0
WireConnection;319;0;404;0
WireConnection;319;3;463;0
WireConnection;342;2;341;0
WireConnection;343;0;342;0
WireConnection;473;0;319;0
WireConnection;334;0;330;0
WireConnection;334;4;335;0
WireConnection;448;0;334;0
WireConnection;243;0;438;0
WireConnection;451;0;243;0
WireConnection;242;0;446;0
WireConnection;242;1;238;0
WireConnection;431;0;242;0
WireConnection;326;0;431;0
WireConnection;326;3;464;0
WireConnection;465;0;326;0
WireConnection;453;0;199;1
WireConnection;454;0;199;3
WireConnection;455;0;199;4
WireConnection;113;0;10;1
WireConnection;113;1;126;0
WireConnection;126;0;125;0
WireConnection;112;0;113;0
WireConnection;114;0;112;0
WireConnection;245;0;603;0
WireConnection;245;1;336;0
WireConnection;245;2;474;0
WireConnection;240;0;247;0
WireConnection;240;1;246;0
WireConnection;247;0;466;0
WireConnection;247;1;452;0
WireConnection;336;0;240;0
WireConnection;336;1;467;0
WireConnection;249;0;445;0
WireConnection;249;2;327;0
WireConnection;337;0;450;0
WireConnection;337;1;449;0
WireConnection;477;0;491;0
WireConnection;477;1;489;0
WireConnection;485;0;484;0
WireConnection;485;1;486;0
WireConnection;484;0;488;0
WireConnection;493;0;494;0
WireConnection;483;0;489;0
WireConnection;494;0;495;0
WireConnection;494;1;483;0
WireConnection;487;0;485;0
WireConnection;487;1;484;1
WireConnection;480;0;487;0
WireConnection;492;0;486;0
WireConnection;492;1;523;0
WireConnection;491;0;492;0
WireConnection;489;0;480;0
WireConnection;501;0;500;0
WireConnection;502;0;501;0
WireConnection;507;0;502;0
WireConnection;509;0;507;0
WireConnection;159;0;158;0
WireConnection;165;0;164;0
WireConnection;166;0;165;0
WireConnection;170;0;169;0
WireConnection;171;0;170;0
WireConnection;177;0;174;0
WireConnection;178;0;177;0
WireConnection;182;0;179;0
WireConnection;183;0;182;0
WireConnection;187;0;184;0
WireConnection;188;0;187;0
WireConnection;192;0;189;0
WireConnection;193;0;192;0
WireConnection;196;0;194;0
WireConnection;197;0;196;0
WireConnection;147;0;146;0
WireConnection;158;0;163;0
WireConnection;144;0;140;0
WireConnection;146;0;145;0
WireConnection;143;0;574;0
WireConnection;143;1;503;0
WireConnection;143;2;144;0
WireConnection;148;0;143;0
WireConnection;148;1;522;0
WireConnection;148;2;147;0
WireConnection;160;0;148;0
WireConnection;160;1;527;0
WireConnection;160;2;159;0
WireConnection;167;0;160;0
WireConnection;167;1;532;0
WireConnection;167;2;166;0
WireConnection;172;0;167;0
WireConnection;172;1;537;0
WireConnection;172;2;171;0
WireConnection;175;0;172;0
WireConnection;175;1;542;0
WireConnection;175;2;178;0
WireConnection;180;0;175;0
WireConnection;180;1;547;0
WireConnection;180;2;183;0
WireConnection;185;0;180;0
WireConnection;185;1;552;0
WireConnection;185;2;188;0
WireConnection;190;0;185;0
WireConnection;190;1;557;0
WireConnection;190;2;193;0
WireConnection;198;0;190;0
WireConnection;198;1;562;0
WireConnection;198;2;197;0
WireConnection;522;0;149;0
WireConnection;522;1;521;0
WireConnection;522;2;565;0
WireConnection;527;0;150;0
WireConnection;527;1;526;0
WireConnection;527;2;566;0
WireConnection;532;0;168;0
WireConnection;532;1;531;0
WireConnection;532;2;567;0
WireConnection;537;0;173;0
WireConnection;537;1;536;0
WireConnection;537;2;568;0
WireConnection;542;0;176;0
WireConnection;542;1;541;0
WireConnection;542;2;569;0
WireConnection;547;0;181;0
WireConnection;547;1;546;0
WireConnection;547;2;570;0
WireConnection;552;0;186;0
WireConnection;552;1;551;0
WireConnection;552;2;571;0
WireConnection;557;0;191;0
WireConnection;557;1;556;0
WireConnection;557;2;572;0
WireConnection;562;0;195;0
WireConnection;562;1;561;0
WireConnection;562;2;573;0
WireConnection;458;0;142;0
WireConnection;503;0;141;0
WireConnection;503;1;496;0
WireConnection;503;2;564;0
WireConnection;574;0;142;0
WireConnection;574;1;575;0
WireConnection;574;2;576;0
WireConnection;330;0;321;0
WireConnection;330;1;447;0
WireConnection;330;2;599;0
WireConnection;437;0;594;0
WireConnection;325;0;324;0
WireConnection;462;0;325;0
WireConnection;161;0;198;0
WireConnection;595;0;436;40
WireConnection;595;1;593;0
WireConnection;594;0;593;0
WireConnection;594;2;596;0
WireConnection;599;2;333;0
WireConnection;582;0;598;1
WireConnection;582;1;588;0
WireConnection;583;0;582;0
WireConnection;592;0;583;0
WireConnection;580;0;472;0
WireConnection;580;1;586;0
WireConnection;580;2;592;0
WireConnection;598;0;589;0
WireConnection;200;0;162;0
WireConnection;200;1;461;0
WireConnection;442;0;443;0
WireConnection;442;1;200;0
WireConnection;442;2;457;0
WireConnection;443;0;460;0
WireConnection;443;1;459;0
WireConnection;470;0;442;0
WireConnection;603;0;580;0
WireConnection;603;1;604;0
WireConnection;603;2;610;0
WireConnection;616;0;606;0
WireConnection;616;1;618;0
WireConnection;608;0;616;0
WireConnection;624;0;606;1
WireConnection;627;0;624;0
WireConnection;627;1;628;0
WireConnection;627;2;629;0
WireConnection;642;0;643;1
WireConnection;642;1;643;2
WireConnection;606;0;607;0
WireConnection;625;0;627;0
WireConnection;613;1;625;0
WireConnection;613;2;605;0
WireConnection;611;0;613;0
WireConnection;377;0;244;0
WireConnection;203;0;245;0
WireConnection;203;1;337;0
WireConnection;203;2;249;0
WireConnection;244;1;471;0
WireConnection;244;0;203;0
WireConnection;577;0;378;0
WireConnection;577;1;579;0
WireConnection;577;2;578;0
WireConnection;656;0;655;0
WireConnection;656;1;658;0
WireConnection;663;1;667;0
WireConnection;667;0;666;0
WireConnection;672;0;670;0
WireConnection;672;1;673;0
WireConnection;644;0;645;0
WireConnection;670;0;669;0
WireConnection;670;1;660;0
WireConnection;674;0;669;0
WireConnection;658;0;648;0
WireConnection;658;1;657;0
WireConnection;648;0;647;0
WireConnection;659;0;661;0
WireConnection;666;0;659;0
WireConnection;646;0;376;0
WireConnection;646;1;690;0
WireConnection;213;2;577;0
WireConnection;213;3;646;0
WireConnection;213;4;201;0
ASEEND*/
//CHKSM=50DC1DC5570FD33AAD199C7B62ED8F3D6B325788