// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:32719,y:32712,varname:node_3138,prsc:2|emission-6890-OUT;n:type:ShaderForge.SFN_Tex2d,id:6706,x:32093,y:33028,varname:_node_5893_copy,prsc:2,ntxv:0,isnm:False|TEX-9178-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:9178,x:31829,y:32899,ptovrint:False,ptlb:node_9178,ptin:_node_9178,varname:node_9178,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_ViewVector,id:3747,x:31829,y:33141,varname:node_3747,prsc:2;n:type:ShaderForge.SFN_Dot,id:7857,x:32093,y:33222,varname:node_7857,prsc:2,dt:0|A-3747-OUT,B-2944-OUT;n:type:ShaderForge.SFN_NormalVector,id:2944,x:31840,y:33293,prsc:2,pt:False;n:type:ShaderForge.SFN_Multiply,id:6890,x:32537,y:33114,varname:node_6890,prsc:2|A-6706-RGB,B-2794-OUT;n:type:ShaderForge.SFN_Power,id:2794,x:32394,y:33220,varname:node_2794,prsc:2|VAL-2999-OUT,EXP-5498-OUT;n:type:ShaderForge.SFN_Vector1,id:5498,x:32252,y:33411,varname:node_5498,prsc:2,v1:5;n:type:ShaderForge.SFN_Clamp01,id:2999,x:32232,y:33186,varname:node_2999,prsc:2|IN-7857-OUT;proporder:9178;pass:END;sub:END;*/

Shader "Exo-Planets/SunCorona" {
    Properties {
        _node_9178 ("node_9178", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _node_9178; uniform float4 _node_9178_ST;
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
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _node_5893_copy = tex2D(_node_9178,TRANSFORM_TEX(i.uv0, _node_9178));
                float3 emissive = (_node_5893_copy.rgb*pow(saturate(dot(viewDirection,i.normalDir)),5.0));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
