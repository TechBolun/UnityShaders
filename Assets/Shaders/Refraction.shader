// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders/10/Refraction" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_RefractColor ("Refraction Color", Color) = (1, 1, 1, 1)
		_RefractionAmount ("Refraction Amount", Range (0, 1)) = 0.5
		_RefractionRatio ("Refraction Ratio", Range (0.1, 1)) = 0.5
		_CubeMap ("Refraction Cubemap", Cube) = "_Skybox" {}
	}

	Subshader {
		Tags {"RenderType" = "Opaque" "Quene" = "Geometry"}

		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma multi_compile_fwdbase

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			float _RefractionAmount;
			fixed _RefractionRatio;
			samplerCUBE _CubeMap;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldPos :TEXCOORD00;
				float3 worldNormal : TEXCOORD01;
				float3 worldViewDir : TEXCOORD02;
				float3 worldRefr : TEXCOORD03;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

				o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractionRatio);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 refraction = texCUBE(_CubeMap, i.worldRefr).rgb * _RefractColor.rgb;

				//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				float atten = 1.0;

				fixed3 color = ambient + lerp(diffuse, refraction, _RefractionAmount) * atten;

				return fixed4(color, 1);

			}

			ENDCG
		}
	}

	Fallback "Reflective/VertexLit"
}