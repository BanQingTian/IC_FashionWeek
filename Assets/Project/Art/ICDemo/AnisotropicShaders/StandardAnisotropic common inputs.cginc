
#define PI 3.14159265

uniform float _Gloss, _GlossAniso, _Cutoff, _LacquerReflection;
uniform float _Anisotropy;
uniform float _AnisotropyRGContrast;
uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
uniform float _FuzzRange;
uniform float4 _FuzzColor, _Color;
uniform float _FuzzBias;
uniform sampler2D _OcclusionMap; uniform float4 _OcclusionMap_ST;
uniform sampler2D _DetailNormal; uniform float4 _DetailNormal_ST;
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform sampler2D _FuzzTex; uniform float4 _FuzzTex_ST;
uniform float _BumpScale;
uniform float _DetailIntensity;
uniform sampler2D _SpecGlossMap; uniform float4 _SpecGlossMap_ST;
uniform sampler2D _Tangent; uniform float4 _Tangent_ST;
uniform fixed _UseSpecular;
uniform float _OcclusionStrength, _WrapDiffuse;
