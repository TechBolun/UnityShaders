﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders/6/BlinnPhongUseBuildInFunction" {
	Properties {
		_Diffuse ("Diffuse Map", Color) = (1, 1, 1, 1)
		_Specular ("Specular Map", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range (8.0, 256)) = 20
	}
	Subshader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			fixed _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
			};

			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// Use the build-in funtion to compute the normal in world space
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize (i.worldPos);
				fixed3 worldLightDir = normalize (UnityWorldSpaceLightDir(i.worldPos));

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				
				//fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				fixed3 halfDir = normalize(viewDir + worldLightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				return fixed4(diffuse + specular + ambient, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}