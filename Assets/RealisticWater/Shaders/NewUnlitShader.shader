// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/ShadowMap"
{
	Properties
	{

		_MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		//LOD 100

		Pass
	{
		Name "FORWARD"
		Tags{ "LightMode" = "ForwardBase" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 5.0

		// make fog work
		#pragma multi_compile_fwdbase
#pragma multi_compile_fwdadd_fullshadows

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

		sampler2D _MainTex;
	float4 _Color;

	struct VSOut
	{
		float4 pos        : SV_POSITION;
		float2 uv        : TEXCOORD1;
		LIGHTING_COORDS(3,4)
	};
	VSOut vert(appdata_full v)
	{
		VSOut o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		TRANSFER_VERTEX_TO_FRAGMENT(o);
		return o;
	}
	float4 frag(VSOut i) : COLOR
	{
		float3 lightColor = _LightColor0.rgb;
		float3 lightDir = _WorldSpaceLightPos0;
		float4 colorTex = tex2D(_MainTex, i.uv.xy * float2(25.0f,25.0f));
		float  atten = LIGHT_ATTENUATION(i);
		return float4(atten.xxx, 1);
		float3 N = float3(0.0f, 1.0f, 0.0f);
		float  NL = saturate(dot(N, lightDir));
		float3 color = colorTex.rgb * lightColor * NL * atten;
		return float4(color, colorTex.a * _Color.a);
	}
		ENDCG
	}
	}
}
