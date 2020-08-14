// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:0,lgpr:1,limd:3,spmd:0,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:32964,y:32391,varname:node_3138,prsc:2|emission-8939-OUT;n:type:ShaderForge.SFN_Add,id:8939,x:32197,y:32424,varname:node_8939,prsc:2|A-586-OUT,B-2691-OUT;n:type:ShaderForge.SFN_Fresnel,id:586,x:31803,y:32142,varname:node_586,prsc:2|EXP-5198-OUT;n:type:ShaderForge.SFN_Slider,id:5198,x:31350,y:32141,ptovrint:False,ptlb:Fresnel power,ptin:_Fresnelpower,varname:node_5198,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1,cur:2.69905,max:5;n:type:ShaderForge.SFN_Tex2d,id:7356,x:31476,y:33138,ptovrint:False,ptlb:Mask sun,ptin:_Masksun,varname:node_7356,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:be18e697199557b4fb19c620a722eeba,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:2787,x:31491,y:32772,ptovrint:False,ptlb:Color 1,ptin:_Color1,varname:node_2787,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.8705883,c2:0.3176471,c3:0.02745098,c4:1;n:type:ShaderForge.SFN_Lerp,id:2691,x:31756,y:32943,varname:node_2691,prsc:2|A-2787-RGB,B-383-RGB,T-7356-RGB;n:type:ShaderForge.SFN_Color,id:383,x:31491,y:32960,ptovrint:False,ptlb:Color 2,ptin:_Color2,varname:node_383,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.7597377,c3:0.4264706,c4:1;proporder:5198-7356-2787-383;pass:END;sub:END;*/

Shader "Exo-Planets/Sun" {
    Properties {
        _Fresnelpower ("Fresnel power", Range(1, 5)) = 2.69905
        _Masksun ("Mask sun", 2D) = "white" {}
        _Color1 ("Color 1", Color) = (0.8705883,0.3176471,0.02745098,1)
        _Color2 ("Color 2", Color) = (1,0.7597377,0.4264706,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
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
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float _Fresnelpower;
            uniform sampler2D _Masksun; uniform float4 _Masksun_ST;
            uniform float4 _Color1;
            uniform float4 _Color2;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float4 _Masksun_var = tex2D(_Masksun,TRANSFORM_TEX(i.uv0, _Masksun));
                float3 emissive = (pow(1.0-max(0,dot(normalDirection, viewDirection)),_Fresnelpower)+lerp(_Color1.rgb,_Color2.rgb,_Masksun_var.rgb));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
