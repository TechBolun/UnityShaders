﻿Shader "Unity Shaders/10/Mirror"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;

			struct a2v {
				float3 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			
			};
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.uv.x = 1 - o.uv.x;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}

	FallBack Off
}
