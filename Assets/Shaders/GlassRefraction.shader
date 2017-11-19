Shader "Unity Shaders/10/Glass Refraction" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white"{}
		_BumpMap ("Normal Map", 2D) = "bump"{}
		_CubeMap ("Environment Cubemap", CUBE) = "_Skybox"{}
		_Distortion ("Distortion", Range(0, 100)) = 10
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

			struct a2v {

			}
			ENDCG
		}

	}
}