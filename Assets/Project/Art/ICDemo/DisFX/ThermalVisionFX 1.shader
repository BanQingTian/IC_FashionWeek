Shader "NReal/ThermalVisionFX22" {
	Properties {
		_NormalTex("Normal Texture",2D) = "white" {}
		_DistanceFadeOut("DistanceFadeOut",Range(0,3)) = 0
		_MatCap("MatCap", 2D) = "white" {}

		_Color ("Main Color", Color) = (.5,.5,.5,1)

//		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
//		_Outline ("Outline width", Range (.002, 1)) = .005
//		_MainTex ("Base (RGB)", 2D) = "white" { }
//        _BaseColor ("Base Color", Color) = (0,0,0,1)  
		[HideInInspector] _EffectorColor("", Color) = (0, 0, 0)
	}
 
CGINCLUDE
#include "UnityCG.cginc"

//struct appdata {
//	float4 vertex : POSITION;
//	float3 normal : NORMAL;
//};
 
struct v2f {
	float4 pos : POSITION;
	float4 color : COLOR;
	//float2 uv_Matcap : TEXCOORD1;	
	//float3 matColor : TEXCOORD2;
};
 
 	//	sampler2D _NormalTex;
		//float _DistanceFadeOut;
		//sampler2D _MatCap;

//uniform float _Outline;
//uniform float4 _OutlineColor;
 
v2f vert(appdata_full v) {
	// just make a copy of incoming vertex data but scaled according to normal direction
	v2f o;
	//o.uv_Matcap.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(v.normal));
	//o.uv_Matcap.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(v.normal));
	//o.uv_Matcap = o.uv_Matcap * 0.5 + 0.5;
	//o.matColor = tex2Dlod(_MatCap, float4(o.uv_Matcap,0,0)).rgb;

	o.pos = UnityObjectToClipPos(v.vertex);
 
	float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
	float2 offset = TransformViewToProjection(norm.xy);
	o.pos.xy += offset * o.pos.z ;
//	o.pos.xy += offset * o.pos.z * _Outline;
//	o.color = _OutlineColor;
	return o;
}
ENDCG
 
SubShader {
//		Tags {"Queue" = "Geometry+100" }
		Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
		//Cull Off

		CGPROGRAM
		#pragma surface surf Lambert noambient vertex:vert2
		#pragma target 4.6

//		sampler2D _MainTex;
		fixed4 _Color;

		sampler2D _NormalTex;
		float _DistanceFadeOut;
		sampler2D _MatCap;
//		float4 _BaseColor;

		half _Density;
        half _Speed;

        float _EffectorRange;
        float _EffectorOffset;
        float4x4 _EffectorMatrix;
        half3 _EffectorColor;

        float _LocalTime;
 
		struct Input {
//			float2 uv_MainTex;
			float2 uv_NormalTex;
			float2 uv_Matcap;	
			float3 matColor;
			float3 viewDir;

			float3 worldPos;
			float vface : VFACE;
		};

		void vert2 (inout appdata_full v, out Input o) 
		{
		  UNITY_INITIALIZE_OUTPUT(Input,o);
//          v.vertex.xyz += v.normal;
		  o.uv_Matcap.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(v.normal));
		  o.uv_Matcap.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(v.normal));
		  o.uv_Matcap = o.uv_Matcap * 0.5 + 0.5;
		  o.matColor = tex2Dlod(_MatCap, float4(o.uv_Matcap,0,0)).rgb;
      	}

		 // Hash function from H. Schechter & R. Bridson, goo.gl/RXiKaH
        uint Hash(uint s)
        {
            s ^= 2747636419u;
            s *= 2654435769u;
            s ^= s >> 16;
            s *= 2654435769u;
            s ^= s >> 16;
            s *= 2654435769u;
            return s;
        }

        float Random(uint seed)
        {
            return float(Hash(seed)) / 4294967295.0; // 2^32-1
        }
 
		void surf (Input IN, inout SurfaceOutput o) {

			 //Effect coordinates
            float3 coord = mul(_EffectorMatrix, float4(IN.worldPos, 1));

             //Density
            float density1 = _Density;
            float density2 = _Density / 2; // half density
            float density3 = _Density / 3; // quarter density

            // Current slice number
            float slice1 = floor(coord.z * density1);
            float slice2 = floor(coord.z * density2); // half density
            float slice3 = floor(coord.z * density3); // quarter density

            // Random number used to select density
            float rnd2 = Random(slice2 + 10000) < 0.5;
            float rnd3 = Random(slice3 + 10000) < 0.5;

            // Actual density and current slice number
            float density = lerp(lerp(density1, density2, rnd2), density3, rnd3);
            float slice = lerp(lerp(slice1, slice2, rnd2), slice3, rnd3);

            // Random seed for the current slice
            uint seed = (uint)(slice * 199 + 10000);

            // Scrolling speed
            float speed = _Speed * (Random(seed) + 1) * 0.5;

            // Convert into polar coordinates
            float phi = atan2(coord.x, coord.y) * UNITY_INV_TWO_PI + 0.5;
            phi = frac(phi + speed * _LocalTime);

            // Threshold for the current slice
            float th = (slice / density - _EffectorOffset) / _EffectorRange;

            // Thresholding
            if (frac(phi) < th) discard;

			 //// Slice emission
            float em = saturate(1 - (frac(phi) - th) * 5);
            em *= 0.5 + Random(seed + 1);


			float3 matCapColor = IN.matColor;
			o.Normal = UnpackNormal(tex2D(_NormalTex,IN.uv_NormalTex));
			float NdotV = dot(o.Normal,IN.viewDir);
			float NdotVInver = 1-NdotV;

			float lightOpacity = dot(IN.viewDir,o.Normal);
			lightOpacity = pow(lightOpacity,2);

			float r = max(1-_DistanceFadeOut,0) * _Color.r;
			float g = max(0,lightOpacity*2-_DistanceFadeOut) * _Color.g;
			float b = max(0,0.1-lightOpacity) * _Color.b;
			
			float3 col = lerp(float3(0.5,1-NdotVInver*1.5,0) , float3(r*2,g*10,b)*8*matCapColor, float3(1,NdotV,NdotVInver*2)*1.2) + pow(matCapColor,2);

			bool backface = IN.vface < 0;


			//o.Emission = lerp(float3(0.5,0.1,0.5) , col, float3(1,NdotV,NdotVInver*2)*1.2) * _Color.a;
			float3 ee = lerp(float3(0.5,0.1,0.5) , col, float3(1,NdotV,NdotVInver*2)*1.2) * _Color.a;
			o.Emission = ee;
			//o.Emission = (backface ? 0 : ee) + em * _EffectorColor;
			o.Emission =  ee+em * _EffectorColor;

			o.Emission = GammaToLinearSpace(o.Emission);

			//o.Emission = lerp(float3(0.5,1-NdotVInver*3,0) , float3(r,g,b)*4, float3(1,NdotV,NdotVInver*2)*0.8) + pow(matCapColor,4);

//			o.Alpha *= _Color.a;
			//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			//o.Albedo = c.rgb;
			//o.Alpha = c.a;
		}
		ENDCG
 
		// note that a vertex shader is specified here but its using the one above
//		Pass {
//			Name "OUTLINE"
//			Tags { "LightMode" = "Always" }
//			Cull Front
//			ZWrite On
//			ColorMask RGB
//			Blend SrcAlpha OneMinusSrcAlpha
//			//Offset 50,50
// 
//			CGPROGRAM
//			#pragma vertex vert
//			#pragma fragment frag
//			half4 frag(v2f i) :COLOR 
//			{ 
//				//float3 matCapColor = i.matColor;
//				return i.color; 
//			}
//			ENDCG
//		}
	}
 
//SubShader {
//		CGPROGRAM
//		#pragma surface surf Lambert
 
//		sampler2D _MainTex;
//		fixed4 _Color;
 
//		struct Input {
//			float2 uv_MainTex;
//		};
 
//		void surf (Input IN, inout SurfaceOutput o) {
//			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
//			o.Albedo = c.rgb;
//			o.Alpha = c.a;
//		}
//		ENDCG
 
//				Pass {
//					Name "OUTLINE"
//					Tags { "LightMode" = "Always" }
//					Cull Front
//					ZWrite On
//					ColorMask RGB
//					Blend SrcAlpha OneMinusSrcAlpha
 
//					CGPROGRAM
//					#pragma vertex vert
//					#pragma exclude_renderers gles xbox360 ps3
//					ENDCG
//					SetTexture [_MainTex] { combine primary }
//				}
//	}
 
	Fallback "Diffuse"
}