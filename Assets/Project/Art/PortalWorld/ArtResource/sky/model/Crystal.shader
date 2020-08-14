// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0.022,fgcg:0.022,fgcb:0.022,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:33144,y:32685,varname:node_4013,prsc:2|normal-1119-RGB,emission-420-OUT;n:type:ShaderForge.SFN_Color,id:1304,x:32441,y:32560,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_1304,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0.176436,c3:0.234,c4:1;n:type:ShaderForge.SFN_Tex2d,id:1119,x:32207,y:32989,ptovrint:False,ptlb:node_1119,ptin:_node_1119,varname:node_1119,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:6afcff0778df1f6448fafc6e152b43bf,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Fresnel,id:2081,x:32240,y:32752,varname:node_2081,prsc:2|EXP-6441-OUT;n:type:ShaderForge.SFN_Add,id:5283,x:32625,y:32685,varname:node_5283,prsc:2|A-1304-RGB,B-6104-OUT;n:type:ShaderForge.SFN_OneMinus,id:2266,x:32441,y:32727,varname:node_2266,prsc:2|IN-2081-OUT;n:type:ShaderForge.SFN_Slider,id:6441,x:31879,y:32788,ptovrint:False,ptlb:node_6441,ptin:_node_6441,varname:node_6441,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1888261,max:1;n:type:ShaderForge.SFN_Cubemap,id:6788,x:32427,y:32963,ptovrint:False,ptlb:node_6788,ptin:_node_6788,varname:node_6788,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,cube:b6357062b8c7dec45b1aed1acc3c3b63,pvfc:0;n:type:ShaderForge.SFN_Multiply,id:6728,x:32717,y:33139,varname:node_6728,prsc:2|A-6788-RGB,B-9031-RGB;n:type:ShaderForge.SFN_Color,id:9031,x:32404,y:33121,ptovrint:False,ptlb:node_9031,ptin:_node_9031,varname:node_9031,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0.6275864,c3:1,c4:1;n:type:ShaderForge.SFN_Add,id:420,x:32827,y:32718,varname:node_420,prsc:2|A-5283-OUT,B-6728-OUT;n:type:ShaderForge.SFN_Add,id:6104,x:32696,y:32454,varname:node_6104,prsc:2|A-7012-OUT,B-2266-OUT;n:type:ShaderForge.SFN_Fresnel,id:5783,x:32206,y:32518,varname:node_5783,prsc:2|EXP-2550-OUT;n:type:ShaderForge.SFN_Slider,id:2550,x:31816,y:32541,ptovrint:False,ptlb:node_6441_copy,ptin:_node_6441_copy,varname:_node_6441_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:4.806858,max:10;n:type:ShaderForge.SFN_Multiply,id:7012,x:32328,y:32286,varname:node_7012,prsc:2|A-5783-OUT,B-4069-OUT;n:type:ShaderForge.SFN_Vector1,id:4069,x:32092,y:32317,varname:node_4069,prsc:2,v1:10;proporder:1304-1119-6441-6788-9031-2550;pass:END;sub:END;*/

Shader "Shader Forge/Crystal" {
    Properties {
        _Color ("Color", Color) = (0,0.176436,0.234,1)
        _node_1119 ("node_1119", 2D) = "bump" {}
        _node_6441 ("node_6441", Range(0, 1)) = 0.1888261
        _node_6788 ("node_6788", Cube) = "_Skybox" {}
        _node_9031 ("node_9031", Color) = (0,0.6275864,1,1)
        _node_6441_copy ("node_6441_copy", Range(0, 10)) = 4.806858
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
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _node_1119; uniform float4 _node_1119_ST;
            uniform float _node_6441;
            uniform samplerCUBE _node_6788;
            uniform float4 _node_9031;
            uniform float _node_6441_copy;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _node_1119_var = UnpackNormal(tex2D(_node_1119,TRANSFORM_TEX(i.uv0, _node_1119)));
                float3 normalLocal = _node_1119_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float3 emissive = ((_Color.rgb+((pow(1.0-max(0,dot(normalDirection, viewDirection)),_node_6441_copy)*10.0)+(1.0 - pow(1.0-max(0,dot(normalDirection, viewDirection)),_node_6441))))+(texCUBE(_node_6788,viewReflectDirection).rgb*_node_9031.rgb));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, finalRGBA, fixed4(0.022,0.022,0.022,1));
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
