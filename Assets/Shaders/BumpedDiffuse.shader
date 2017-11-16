Shader "Unity Shaders/9/BumpedDiffuse"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry" }

		Pass
		{
			Tags {"LightMode" = "FowardBase"}
			CGPROGRAM

			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			struct a2f
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TEXCOORD0;
				float4 texcoord : TEXCOORD1;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoWx : TEXCOORD1;
				float4 TtoWy : TEXCOORD2;
				float4 TtoWz : TEXCOORD3; 
				SHADOW_COORDS(4)
			};
			
			v2f vert (a2f v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz); //w stored x or -x
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoWx = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoWx = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoWx = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(1, 1, 1, 1);
			}
			ENDCG
		}
	}
}
