// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


struct VertexInput 
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 texcoord0 : TEXCOORD0;
	float2 texcoord1 : TEXCOORD1;
	float2 texcoord2 : TEXCOORD2;
};

struct VertexOutput 
{
	float4 pos : SV_POSITION;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float4 posWorld : TEXCOORD3;
	float3 normalDir : TEXCOORD4;
	float3 tangentDir : TEXCOORD5;
	float3 bitangentDir : TEXCOORD6;
	LIGHTING_COORDS(7,8)
	#if defined(LIGHTMAP_ON) || defined(UNITY_SHOULD_SAMPLE_SH)
		float4 ambientOrLightmapUV : TEXCOORD9;
	#endif
};

float sqr( float x )
	{
		return x*x;
	}

float3 WrappedDiffuse(half NdotL, half _Wrap)
{
	return saturate((NdotL + _Wrap) / ((1 + _Wrap) * (1 + _Wrap)));
}

half3 Fuzz(half NdotV, half3 Color, half FuzzRange, half FuzzBias)
{
	half3 FuzzColor = pow(exp2( - NdotV), FuzzRange) + FuzzBias;
	FuzzColor *= Color;
	return FuzzColor;
}

#define STUFF \
	float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);	\
	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);	\
	float3 DetailNormal = UnpackNormal(tex2D(_DetailNormal,TRANSFORM_TEX(i.uv0, _DetailNormal)));	\
	float4 packedTangentMap = tex2D(_Tangent, TRANSFORM_TEX(i.uv0, _Tangent));\
	/*packedTangentMap = lerp(packedTangentMap, 1-packedTangentMap, _Anisotropy);*/\
	float3 normalLocalAniso = lerp(float3(0, 0, 1), UnpackNormal(packedTangentMap), _AnisotropyRGContrast);\
	DetailNormal = lerp(float3(0, 0, 1), DetailNormal.rgb, _DetailIntensity);	\
	float3 normalLocal =  lerp(float3(0, 0, 1), UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap))), _BumpScale);\
	normalLocalAniso = BlendNormals( normalLocalAniso, DetailNormal);   \
	normalLocal = BlendNormals( normalLocal, DetailNormal);   \
	float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); 	\
	float3 normalDirectionAniso = normalize(mul( normalLocalAniso, tangentTransform )); 	\
	float3 tangentDirection = mul( tangentTransform, i.tangentDir ).xyz;	\
	float3 viewReflectDirection = reflect( -viewDirection, normalDirection );\
	float3 viewReflectDirectionAniso = reflect( -viewDirection, normalDirectionAniso );\
	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);\
	float3 lightColor = _LightColor0.rgb; \
	float3 halfDirection = normalize(viewDirection+lightDirection); \
	float4 diffuseColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex)) * _Color;	\
	/*float attenuation = lerp(LIGHT_ATTENUATION(i), lerp(1.0, LIGHT_ATTENUATION(i), diffuseColor.a), _ALPHABLEND);	\*/\
	float attenuation =LIGHT_ATTENUATION(i);	\
	float3 attenColor = attenuation * _LightColor0.xyz;	\
	float NdotV = DotClamped( normalDirection, viewDirection );	\
    float NdotH = DotClamped( normalDirection, halfDirection );	\
    float VdotH = DotClamped( viewDirection, halfDirection );	\
	float4 Specular = float4(_SpecColor.rgb, 1.0) * tex2D(_SpecGlossMap, TRANSFORM_TEX(i.uv0, _SpecGlossMap));\
	/*Specular.a = vdr(NdotV, Specular.a);*/	\
	float gloss = _Gloss * Specular.a;	\
	gloss = vdr(NdotV, gloss);	\
	float4 AO = tex2D(_OcclusionMap, TRANSFORM_TEX(i.uv0, _OcclusionMap));	\
	AO.r = lerp(1.0, AO.r, _OcclusionStrength);	\
	float NdotL = max(0, dot( normalDirection, lightDirection ));	\
    float LdotH = max(0.0,dot(lightDirection, halfDirection));	\
	\
	half SpecularPower = RoughnessToSpecPower(1.0-_GlossAniso * Specular.a);\
	float3x3 tangentToWorld = transpose(float3x3(i.tangentDir, i.bitangentDir, i.normalDir));\
	float3 hTangent = mul(tangentToWorld, float3(0, 1, 0));		\
	float3 Tangent = lerp(i.tangentDir, hTangent, _Anisotropy);\
	float3 worldTangent = mul(tangentToWorld, float4(normalLocalAniso.rg, 0.0, 0.0) ).xyz;\
	worldTangent = normalize(lerp(Tangent, worldTangent, _AnisotropyRGContrast));\
	float TdotL = dot( lightDirection, worldTangent );\
	float TdotV = dot( viewDirection, worldTangent );\
	float TdotH = dot( halfDirection, worldTangent );\
	/*float visTerm = SmithVisibilityTerm( NdotL, NdotV, 1.0 - (_GlossAniso * Specular.a));	*/               \
	float3 directDiffuse;\
	float3 directSpecular = AnisotropicSpecular(TdotH, NdotL, NdotV, TdotL, TdotV, _GlossAniso * Specular.a, worldTangent, SpecularPower, directDiffuse);	\
	directDiffuse *= attenColor;\
	\
	directSpecular *= attenColor * FresnelTerm(Specular.rgb, LdotH) /** visTerm*/ * unity_LightGammaCorrectionConsts_PIDiv4 * _SpecColor.a;\


float4 GI_SHIT(VertexOutput i, float3 lightColor, float3 lightDirection, float3 normalDirection, float3 viewDirection, 
float attenuation, half gloss, float3 viewReflectDirectionAniso, float4 Specular, float NdotV, float4 AO, float3 directDiffuse,
float4 diffuseColor,float3 directSpecular, float NdotL)
{
	UnityLight light;
		UnityGIInput d;
	    
	    #ifdef LIGHTMAP_OFF
	        light.color = lightColor;
	        light.dir = lightDirection;
	        light.ndotl = LambertTerm (normalDirection, light.dir);
	    #else
	        light.color = half3(0.f, 0.f, 0.f);
	        light.ndotl = 0.0f;
	        light.dir = half3(0.f, 0.f, 0.f);
	    #endif
	                    
	    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
	        d.ambient = 0;
	        d.lightmapUV = i.ambientOrLightmapUV;
	    #else
	        d.ambient = i.ambientOrLightmapUV;
	    #endif
	d.light = light;	
    d.worldPos = i.posWorld.xyz;	
    d.worldViewDir = viewDirection;	
    d.atten = attenuation;
    d.boxMax[0] = unity_SpecCube0_BoxMax;
    d.boxMin[0] = unity_SpecCube0_BoxMin;
    d.probePosition[0] = unity_SpecCube0_ProbePosition;
    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.boxMax[1] = unity_SpecCube1_BoxMax;
    d.boxMin[1] = unity_SpecCube1_BoxMin;
    d.probePosition[1] = unity_SpecCube1_ProbePosition;
    d.probeHDR[1] = unity_SpecCube1_HDR;
    Unity_GlossyEnvironmentData ugls_en_data;
    ugls_en_data.roughness = 1.0 - gloss;
    ugls_en_data.reflUVW = viewReflectDirectionAniso;
    UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data );
    lightDirection = gi.light.dir;
    lightColor = gi.light.color;
    half grazingTerm = saturate( gloss + Luminance(_SpecColor) );
    float3 indirectDiffuse = 0, indirectSpecular = 0;
    indirectSpecular = (gi.indirect.specular);
    indirectSpecular *= FresnelLerp (_SpecColor.rgb * Specular.rgb, grazingTerm,  NdotV) * AO.r * AO.g;
    indirectDiffuse = float3(0,0,0);
    indirectDiffuse += gi.indirect.diffuse;

    float3 finalColor = 0;




			   	#ifdef SPECULAR_ON 
			    	float3 specular = (_SpecColor.a * directSpecular + indirectSpecular) * AO.g;
				#else
					float3 specular = 0;
				#endif
/////// Diffuse:				

                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor.rgb * AO.r;
////////// Fuzz:
	
				#ifdef FUZZ_ON					
					half3 FuzzLighting = Fuzz(NdotV, tex2D(_FuzzTex, TRANSFORM_TEX(i.uv0, _FuzzTex)).xyz * AO.r *
					(_FuzzColor * indirectDiffuse + _FuzzColor * WrappedDiffuse(NdotL, _WrapDiffuse) * 
					attenuation * _LightColor0.xyz), _FuzzRange, _FuzzBias);
				#else
					half3 FuzzLighting = 0;
				#endif
/// Final Color:
                	finalColor = diffuse + specular + FuzzLighting;
		
               	 	return fixed4(finalColor,1);
				
  	}


half AnisotropicSpecular (half TdotH, half NdotL, half NdotV, half TdotL, half TdotV, half gloss, half3 worldTangent, half SpecPower, out half3 Diffuse)
{
	half Specular = 0;

	#ifdef SPECULAR_ON
		half roughness = 1.0 - gloss;	
		Diffuse = sqrt(1.0 - sqr(TdotL)) * NdotL;
		Specular = NdotL * pow(saturate(sqrt(1.0 - sqr(TdotL)) * sqrt(1.0 - sqr(TdotV)) - TdotL * TdotV), SpecPower);	
		half normalization =  sqrt((SpecPower+1)*((SpecPower)+1))/(8*PI);//
		Specular *= normalization;

		
	#else
	Specular = 0;
	Diffuse = NdotL;
	#endif

		return Specular;
}

void toClipOrNotToClip(half a)
{
	//#ifdef _MODE_CUTOUT
		clip(a - _Cutoff);
	//#endif
}

half vdr(half angle, half gloss)
{
return lerp(1, gloss, angle);
}	


  
VertexOutput vert (VertexInput v)
{
	VertexOutput o = (VertexOutput)0;
	o.uv0 = v.texcoord0;
	o.uv1 = v.texcoord1;
	o.uv2 = v.texcoord2;
	 #ifdef LIGHTMAP_ON
		o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
		o.ambientOrLightmapUV.zw = 0;
	#endif
	#ifdef DYNAMICLIGHTMAP_ON
		o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
	#endif
	o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
	o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
	o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
	o.posWorld = mul(unity_ObjectToWorld, v.vertex);
	float3 lightColor = _LightColor0.rgb;
	o.pos = UnityObjectToClipPos(v.vertex );
	TRANSFER_VERTEX_TO_FRAGMENT(o)
	return o;
}



