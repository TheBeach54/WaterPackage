// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Per pixel bumped refraction.
// Uses a normal map to distort the image behind, and
// an additional texture to tint the color.

Shader "Beach/WaterUnder" {
	Properties{
		_BumpAmt("Bump Boost", Float) = 10
		_GrabAmt("Distortion", range(0,2)) = 10
		_RefractionBias("_RefractionBias", Float) = 0
		_MainTex("Tint Color (RGB)", 2D) = "white" {}
	_BumpMap("Normalmap", 2D) = "bump" {}
	_Color("_Color", Color) = (1,1,1,1)
		_SunDiscScale("Sun Scale", Float) = 0.005
		_LiquidIndice("_LiquidIndice", Range(0,2)) = 1.05
		_SunDiscPow("Sun Power", Float) = 3
		_Speed("_Speed", Vector) = (1,1,1,1)
		_ShadowOpacity("_ShadowOpacity", Range(0,1)) = 0.75
		_ShadowDisp("Shadow Displacement", Float) = 0.5
		[Toggle(_RECEIVE_SHADOWS)]_ReceiveShadows("(variant) Receive Shadows", Float) = 0

	}

		Category{

		// We must be transparent, so other objects are drawn before this one.
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent"  "ForceNoShadowCasting" = "True"  "LightMode" = "ForwardBase" }


		SubShader{
		LOD 200
		ZWrite Off
		// This pass grabs the screen behind the object into a texture.
		// We can access the result in the next pass as _GrabTexture
		GrabPass{
	}

	// Main pass: Take the texture grabbed above and use the bumpmap to perturb it
	// on to the screen
		Pass{



		CGPROGRAM

#pragma shader_feature _RECEIVE_SHADOWS


#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"

#ifdef _RECEIVE_SHADOWS
#include "Shadows.cginc"
#endif

#include "WaterUtils.cginc"


	float _ShadowOpacity;
	float _ShadowDisp;
	float _RefractionBias;
	float _SunDiscScale, _SunDiscPow;
	float _BumpAmt;
	float _GrabAmt;
	float _LiquidIndice;
	float4 _BumpMap_ST;
	float4 _MainTex_ST, _Color;
	float4 _Speed;
	float4 _GrabTexture_TexelSize;
	sampler2D _BumpMap;
	sampler2D _MainTex;

	
	struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord: TEXCOORD0;
		float4 tangent : TANGENT;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 vertex : POSITION;
		float4 screenUV : TEXCOORD0;
		float4 tSpace0 : TEXCOORD1;
		float4 tSpace1 : TEXCOORD2;
		float4 tSpace2 : TEXCOORD3;
		float2 uvbump : TEXCOORD4;
		float2 uvmain : TEXCOORD5;
	};

	v2f vert(appdata_t v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
#else
		float scale = 1.0;
#endif
		o.screenUV = ComputeScreenPos(o.vertex);
		o.uvbump = TRANSFORM_TEX(v.texcoord, _BumpMap);
		o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);

		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;


		fixed3 worldNormal = -normalize(UnityObjectToWorldNormal(v.normal));
		fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
		fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;

		fixed3 worldBinormal = normalize(cross(worldNormal, worldTangent) * tangentSign);

		o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
		o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
		o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

		return o;
	}



	half4 frag(v2f i) : COLOR
	{
		half4 o;

	float3 worldTan = float3(i.tSpace0.x, i.tSpace1.x, i.tSpace2.x);
	float3 worldBin = float3(i.tSpace0.y, i.tSpace1.y, i.tSpace2.y);
	float3 worldNor = float3(i.tSpace0.z, i.tSpace1.z, i.tSpace2.z);
	float3 worldPos = float3(i.tSpace0.w, i.tSpace1.w, i.tSpace2.w);
	// calculate perturbed coordinates


	half2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump + _Time.xx * _Speed.xy)).rg; // we could optimize this by just reading the x & y without reconstructing the Z
	bump += UnpackNormal(tex2D(_BumpMap, (i.uvbump*0.7 + _Time.xx * _Speed.zw)*0.7)).rg;
	//Using the normal map we compute the new UV to sample the depth and the grabPass
	float2 uv = i.screenUV.xy / i.screenUV.w;




	float3 viewVector = _WorldSpaceCameraPos - worldPos;
	float eyeD = length(viewVector);
	float3 V = viewVector / eyeD;
	V = -V;

	float2 grabOffset = bump * _BumpAmt;
	//i.uvgrab.xy = grabOffset * i.uvgrab.z + i.uvgrab.xy;

	float2 refrUV = uv + grabOffset / i.screenUV.w;
	float2 refrBiasUV = uv + (grabOffset*(1 + _RefractionBias)) / i.screenUV.w;

	half3 grab;
	float depth, depth2;
	float depthEye, depthRefrEye;

	GetGrabDepth_Corrected(eyeD, uv, refrUV, refrBiasUV, grab, depth, depth2, depthEye, depthRefrEye);




	//Reconstruct the normal map using the sum of both initial normal map
	float3 finalNM = normalize(float3(bump * _BumpAmt, 1));

	//Compute the world normal 
	float3 worldNormal = normalize(worldBin * finalNM.y + (worldTan * finalNM.x + worldNor));


	//Compute the view direction




	float3 refractDir = refract(V, worldNormal, _LiquidIndice);
	//float3 reflDir = reflect(V, worldNormal);

	float RdotL = saturate(dot(_WorldSpaceLightPos0, normalize(refractDir)));

	//We draw the sun if needed
	float sunDisc = RdotL;
	sunDisc = saturate(sunDisc);
	sunDisc = pow(sunDisc, _SunDiscPow);
	sunDisc *= _SunDiscScale;
	float3 sunImpact = sunDisc*_LightColor0;
	//return float4(sunDisc.xxx, 1);


#ifdef _RECEIVE_SHADOWS
	float3 shadowRefract = bump.xyx * float3(1,1,0) * _ShadowDisp;
	float atten = GetSunShadowsAttenuation_PCF3x3(worldPos + shadowRefract, eyeD, 0);
	atten = lerp(1, atten, _ShadowOpacity);
	sunImpact *= atten;
	//	return float4(t.xxx, 1);
#endif

	o.rgb = grab * _Color.rgb + sunImpact;
	o.a = 1;
	return o;
	}
		ENDCG
	}
	}

		// ------------------------------------------------------------------
		// Fallback for older cards and Unity non-Pro

	}
		Fallback "Diffuse"
}