Shader "Unity Shaders/6/Blinn-Phong"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20

	}
	SubShader
	{
		Pass{

			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			//保证光照减弱 attenuation 等变量可以被正确赋值
			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert (a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, i.worldPos.xyz));//SpecularVertex里面用的是v.vertex 这里用i.worldPos 因为是vertex的world坐标
				
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				// the auuenuation of diectional light is always 1
				fixed atten = 1.0;

				//update the output color 
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}

		Pass {
			Tags {"LightMode" = "ForwardAdd"}

			Blend One One

			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members pos,worldNormal,worldPos)
#pragma exclude_renderers d3d11

			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			struct a2v {
				float vertex = POSITION;
				float normal : NORMAL;
			};

			struct v2f {
				float pos = SV_POSITION;
				float worldNormal = TEXCOORD0;
				float worldPos = TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_WorldToObject, v.vertex);
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
				//Spot light or point light, 
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos,xyz);
				#endif
			}

			ENDCG
		}
	}

	FallBack "Specular"
}