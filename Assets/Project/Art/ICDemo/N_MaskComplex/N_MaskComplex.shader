Shader "nreal/N_MaskComplex" {
	SubShader
	{
		Tags{ "Queue" = "Background" }
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		//Cull Off
		ZWrite On
		//ZTest Always
		Pass
		{
			Color(0,0,0,0)
		}
	}
	FallBack "Diffuse"
}
