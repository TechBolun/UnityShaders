Shader "TATest/ShaderTest_Water" 
{	
	Properties 
	{
		_MainColor ("主色调", Color) = (0.1137,0.4,0.31,1)
		_BumpyMap("起伏贴图", 2D) = "white" {}
		_ReflectionMap("反射贴图",2D) = "white"{}
		_BumpDirection("波纹流向与速度", Vector) = (1.0, 3.0, 0, 0)
		_BumpReflectTiling("波纹重复率", Vector) = (3.0, 2.0, 0, 0)
		_TransparentController ("透明度", Range(0, 1)) = 1
		_Distortion ("扰动强度", Range(1, 100)) = 20
		_VertexColorTransparent ("顶点色透明度", Range(0, 1)) = 1
	}

	SubShader 
	{
		Tags {"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"} 	
		Blend SrcAlpha OneMinusSrcAlpha
		ZTest LEqual
		ZWrite Off 
		LOD 400

		CGPROGRAM
		#pragma surface surf Lambert alpha vertex:ReflectionCoords approxview halfasview noforwardadd

		sampler2D _BumpyMap;
		sampler2D _ReflectionMap;	
		fixed4 _MainColor;
		half4 _BumpDirection;
		half4 _BumpReflectTiling;
		fixed _TransparentController;
		float _Distortion;
		fixed _VertexColorTransparent;
		

		struct Input
		{		
			half4 bumpCoords : TEXCOORD1;
			half4 reflectionCoords : TEXCOORD2;
			float4 color : COLOR;
		};
		
		void ReflectionCoords (inout appdata_full v, out Input o) 
		{
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.bumpCoords.xyzw = v.texcoord.xyxy * _BumpReflectTiling + _Time.xxxx * _BumpDirection;
            o.reflectionCoords.xyzw = v.texcoord.xyxy * _BumpReflectTiling;
		}
				
		void surf (Input IN, inout SurfaceOutput o) 
		{	
			fixed4 normal_1 = tex2D(_BumpyMap, IN.bumpCoords.xy);

			fixed4 bump = normal_1 - 0.5; 

			fixed4 offset = bump;
			fixed4 reflection = tex2D(_ReflectionMap ,IN.reflectionCoords.xy + offset.xy);
		
			fixed4 ReflectionCol = reflection;
			o.Albedo = _MainColor.xyz + ReflectionCol.xyz;
			o.Alpha =  _MainColor.a * _TransparentController * IN.color.a * _VertexColorTransparent;
			o.Emission = pow(ReflectionCol, 4.5).xyz;			
		}		
		ENDCG
	}
FallBack "Transparent/VertexLit"		
} 
