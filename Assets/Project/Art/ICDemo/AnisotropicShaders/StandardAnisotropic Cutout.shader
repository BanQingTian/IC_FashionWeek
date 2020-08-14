// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Standard Anisotropic Cutout" {
    Properties {
	
        [Header(Color)]_Color ("Color", Color) = (0.5,0.5,0.5,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _MainTex ("Albedo", 2D) = "white" {}
        _OcclusionMap ("Occlusion", 2D) = "white" {}
        _OcclusionStrength ("", Range(0, 1)) = 1
		[Header(Specularity)][Toggle(SPECULAR_ON)]  _UseSpecular ("Use Specular", Float ) = 0
		_SpecColor ("Specular Color", Color) = (0.2,0.2,0.2)
        _SpecGlossMap ("Specular", 2D) = "white" {}        
		_Gloss ("Smoothness (Reflections)", Range(0, 1)) = 0.5
		_GlossAniso ("Smoothness (Specular)", Range(0, 1)) = 0.5
		_Anisotropy("Anisotropy", Range(0, 1))	 = 0  		   
        [Header(Tangent Direction)]_Tangent ("Tangent (RG)", 2D) = "bump" {}   
		_AnisotropyRGContrast("", Range(0, 1))= 0
        [Header(Surface normals)]_BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("", Range(0, 1)) = 1
        _DetailNormal ("Detail Normal", 2D) = "bump" {}
        _DetailIntensity ("", Range(0, 1)) = 1
		 [Header(Fuzz)][Toggle(FUZZ_ON)]  _UseFuzz ("Use Fuzz", Float ) = 0
		 _FuzzColor ("Fuzz Color", Color) = (0,0,0,1)
		 _FuzzTex ("FuzzTex", 2D) = "white" {}
		_FuzzRange ("Fuzz Range", Range(1, 5)) = 1        
        _FuzzBias ("Fuzz Bias", Range(0, 1)) = 0        
		_WrapDiffuse("Light Wrap", Range(0,1))=0
		 //[HideinInspector][Header(Opacity options)][KeywordEnum(Opaque, Cutout)] _Mode ("Blend mode", Float) = 1.0
		
		       
    }

	SubShader {
        Tags {
            
			 "Queue"="AlphaTest"
			 "RenderType"="TransparentCutout"
        }
        Pass {

            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            //#define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "StandardAnisotropic common inputs.cginc"
			#include "StandardAnisotropic.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ SPECULAR_ON
			#pragma multi_compile _ FUZZ_ON
			//#pragma multi_compile _MODE_OPAQUE, _MODE_CUTOUT
            #pragma exclude_renderers xbox360 ps3 
            #pragma target 3.0

			float4 frag(VertexOutput i) : COLOR 
				{
					
	                STUFF;
					toClipOrNotToClip(diffuseColor.a);
	/////// GI Data:
					
					float4 finalColor = GI_SHIT(i, lightColor, lightDirection, normalDirection, viewDirection, 
					attenuation, gloss, viewReflectDirectionAniso, Specular, NdotV, AO,
					directDiffuse, diffuseColor, directSpecular, NdotL);
					return finalColor;

	            }

	            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            //#define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "StandardAnisotropic common inputs.cginc"
			#include "StandardAnisotropic.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ SPECULAR_ON
			#pragma multi_compile _ FUZZ_ON
			//#pragma multi_compile _MODE_OPAQUE, _MODE_CUTOUT
            #pragma exclude_renderers xbox360 ps3 
            #pragma target 3.0

           

         	
         	float4 frag(VertexOutput i) : COLOR 
{
				STUFF;
				toClipOrNotToClip(diffuseColor.a);
				#ifdef SPECULAR_ON
                float3 specular = _SpecColor.a * (directSpecular) * AO.g;
				#else
				float3 specular = 0;
				#endif
				
                
                float3 diffuse = (directDiffuse) * diffuseColor.rgb * AO.r;
////////// Fuzz:
				#ifdef FUZZ_ON
				half3 FuzzLighting = Fuzz(NdotV, tex2D(_FuzzTex, TRANSFORM_TEX(i.uv0, _FuzzTex)).xyz * AO.r * (_FuzzColor * WrappedDiffuse(NdotL, _WrapDiffuse) * attenColor), _FuzzRange, _FuzzBias);
				#else
				half3 FuzzLighting = 0;
				#endif
/// Final Color:
                float3 finalColor = diffuse + specular + FuzzLighting;
				
                return fixed4(finalColor,1);
            }

            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
			//#pragma multi_compile _MODE_OPAQUE, _MODE_CUTOUT
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			half _Cutoff;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				
				//#ifdef _MODE_CUTOUT
					clip(_MainTex_var.a - _Cutoff);
				//#endif

                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
       

        
    }
    FallBack "Diffuse"
}

