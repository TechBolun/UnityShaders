Shader "Unity Shaders/10/Glass Refraction" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white"{}
		_BumpMap ("Normal Map", 2D) = "bump"{}
		_CubeMap ("Environment Cubemap", CUBE) = "_Skybox"{}
		_Distortion ("Distortion", Range(0, 1000)) = 10
		_RefractionAmount ("Refraction Amount", Range(0.0, 1.0)) = 1.0
	}
	Subshader {
		Tags {"RenderType" = "Opaque" "Queue" = "Transparent"}

		GrabPass {"_RefractionTex"}

		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _CubeMap;
			float _Distortion;
			fixed _RefractionAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoWx : TEXCOORD2;  
			    float4 TtoWy : TEXCOORD3;  
			    float4 TtoWz : TEXCOORD4; 
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				o.scrPos = ComputeGrabScreenPos(o.pos);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoWx = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoWy = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			  	o.TtoWz = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z); 

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoWx.w, i.TtoWy.w, i.TtoWz.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refractColor = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;

				bump = normalize(half3(dot(i.TtoWx, bump), dot(i.TtoWy, bump), dot(i.TtoWz, bump)));

				fixed3 worldReflDir = reflect(-worldViewDir, bump);
				fixed3 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflectColor = texCUBE(_CubeMap, worldReflDir).rgb * texColor.rgb;

				fixed3 finalColor = reflectColor * (1 - _RefractionAmount) + refractColor * _RefractionAmount;

				return fixed4(finalColor, 1);

			}
	
			ENDCG
		}

	}
}