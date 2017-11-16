Shader "Unity Shaders/9/BumpedSpecular"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
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
			float4 _Specualr;
			float _Gloss;

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
				o.TtoWy = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoWz = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoWx.w, i.TtoWy.w, i.TtoWz.w);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));


				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				return fixed4(1, 1, 1, 1);
			}
			ENDCG
		}
	}
}
