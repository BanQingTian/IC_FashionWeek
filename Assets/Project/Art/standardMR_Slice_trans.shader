 Shader "nreal/standardMR_Slice_trans" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MetalicTex("MetalicTex", 2D) = "white" {}
		_RoughnessTex ("RoughnessTex", 2D) = "white" {}

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_NormalTex("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Map Intensity", Range(0,2)) = 1

		[HDR] _EmissionColor("Emission", Color) = (0, 0, 0)

		[Header(Backface Attributes)]
		_Color2("Color", Color) = (1, 1, 1, 1)
		[Gamma] _Metallic2("Metallic", Range(0, 1)) = 0
		_Glossiness2("Smoothness", Range(0, 1)) = 0.5

		[HideInInspector] _EffectorColor("", Color) = (0, 0, 0)
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200
		Cull Off
		Blend srcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:blend

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		//float4 _MainTex_ST;
		sampler2D _MetalicTex;
		//float4 _MetalicTex_ST;
		sampler2D _RoughnessTex;
		//float4 _RoughnessTex_ST;

		sampler2D _NormalTex;
		float _NormalIntensity;


		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalTex;
			float3 worldPos;
			float vface : VFACE;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		half3 _EmissionColor;

		half4 _Color2;
		half _Metallic2;
		half _Glossiness2;

		half _Density;
		half _Speed;

		float _EffectorRange;
		float _EffectorOffset;
		float4x4 _EffectorMatrix;
		half3 _EffectorColor;

		float _LocalTime;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

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

		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Effect coordinates
			float3 coord = mul(_EffectorMatrix, float4(IN.worldPos, 1));

			// Density
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

			// Slice emission
			float em = saturate(1 - (frac(phi) - th) * 5);
			em *= 0.5 + Random(seed + 1);

			// Surface shader output
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			half4 metalCol = tex2D(_MetalicTex, IN.uv_MainTex);
			half4 roughCol = tex2D(_RoughnessTex, IN.uv_MainTex);
			bool backface = IN.vface < 0;

			float3 normalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			normalMap = float3(normalMap.x * _NormalIntensity,normalMap.y * _NormalIntensity, normalMap.z);
			o.Albedo = backface ? _Color2.rgb : c.rgb;
			o.Metallic = backface ? _Metallic2 : _Metallic * metalCol.r;
			o.Smoothness = backface ? _Glossiness2 : _Glossiness * roughCol.r;
			o.Normal = normalMap.rgb;
			o.Emission = (backface ? 0 : _EmissionColor) + em * _EffectorColor;
			o.Alpha = 0.5;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
