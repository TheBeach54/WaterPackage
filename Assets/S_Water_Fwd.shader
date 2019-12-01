Shader "Medic/S_Water_Fwd" {
	Properties{
		[Header(Texture)][Space]
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Displacement("Displacement Map", 2D) = "black" {}
		[Header(Pan Setup)][Space]
		_GlobalSpeed("Global Speed", Float) = 1
		_Speed("Pan Speed (xy) Bump01 (zw) Bump02", Vector) = (1,0,-1,0.5)
			_FlowSpeed("_FlowSpeed",Float) = 1
			_FlowIntensity("_FlowIntensity", Float) = 1

		[Header(Water)][Space]
		_Color("Water Color",Color) = (1,1,1,1)
		_WaterOpacity("Water Opacity", Range(0,1)) = 0

		[Header(Reflection)][Space]
		_ReflBoost("Reflection Brightness" , Float) = 0.1
		_ReflPow("Reflection Power", Float) = 1
		_BumpAmt("Reflection Amplitude", Float) = 1
			_SunDiscScale("Sun Scale", Range(0,1)) = 0.01
			_SunDiscPow("Sun Power", Float) = 0.5

		[Header(Refraction)][Space]
		_GrabBoost("Refraction Brightness", Float) = 0.9
		_BumpGrabAmt("Grab Amplitude", Float) = 1
		_MaxGrab("Depth Grab Amplitude", Float) = 2
			_RefractionOffset("_RefractionOffset", Float) = 1

		[Header(Fresnel Setup)][Space]
		_Fresnel("Fresnel Power (def:1.0)", Float) = 1
		_ReflCurve("Fresnel Multiply (def:0.5)", Float) = 0.5
		_ReflOffset("Fresnel Offset (def:0.5)", Float) = 0.5
		[Space]
		_Shading("Use Surface Normal or Normal map", Range(0,1)) = 1
		_NormalMapAmt("Normal Map Boost", Float) = 1

		[Header(Depth Test)]
		_DepthPos("Depth Mask Offset", Float) = 0
		_DepthFalloff("Depth Mask Falloff", Float) = -10
		[Space]
		_DistancePos("Depth Gradient Offset", Float) = 0
		_DistanceFalloff("Depth Gradient Falloff", Float) = -100
		_DistancePower("Depth Gradient Power", Float) = 0.2

[Header(Displacement)]
			_DispIntensity("_DispIntensity", Float) = 1

			[Toggle(_USE_REFLECTION_PROBE)]_UseReflectionProbe("_USE_REFLECTION_PROBE", Float) = 0
			[Toggle(_BOX_PROJECTION)]_UseBoxProjection("_BOX_PROJECTION", Float) = 0
				[Toggle(_USE_FLOW_VERTEX)]_UseFlow("_USE_FLOW_VERTEX", Float) = 0
				[Toggle(_DRAW_SUN_DISC)]_DrawSunDisc("_DRAW_SUN_DISC", Float) = 0
				

		[HideInInspector][HDR] _ReflectionTex("", 2D) = "white" {}


 	
	}
		SubShader{
	
		Tags{ "Queue" = "Transparent+500" "RenderType" = "Transparent" "ForceNoShadowCasting" = "True" "LightMode" = "ForwardBase" }

		GrabPass{}

		Pass{
		//Name "FORWARD"
		ZWrite Off

		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// compile directives
#pragma vertex vert
#pragma fragment frag
#pragma target 5.0

#pragma shader_feature _USE_REFLECTION_PROBE
#pragma shader_feature _BOX_PROJECTION
#pragma shader_feature _USE_FLOW_VERTEX
#pragma shader_feature _DRAW_SUN_DISC


#include "UnityCG.cginc"

	CBUFFER_START(WaterParam) //Change every frame
	uniform sampler2D_float _CameraDepthTexture;
	float4 _CameraDepthTexture_ST;
	uniform sampler2D_float _ReflectionTex;
	uniform sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;

	//Matrix we get from a script
	float4x4 _ProjectInverse;
	float4x4 _ViewInverse;
	CBUFFER_END // WaterParam

	CBUFFER_START(WaterParamRare) //Never change during runtime
	sampler2D _BumpMap;

	sampler2D _Displacement;
	float _DispIntensity;

#ifdef _USE_FLOW_VERTEX
	half _FlowSpeed;
	half _FlowIntensity;
#endif
	float4 _BumpMap_ST;
	float4 _Color;
	float4 _Speed;
#ifdef _DRAW_SUN_DISC
	float4 _SunColor, _SunDir;
	float _SunDiscScale, _SunDiscPow;
#endif
	float _RefractionOffset;
	float _Shading;
	float _GlobalSpeed;
	float _WaterOpacity;
	float _ReflBoost;
	float _ReflPow;
	float _GrabBoost;
	float _BumpGrabAmt, _MaxGrab;
	float _BumpAmt, _NormalMapAmt;
	float _Fresnel, _ReflOffset, _ReflCurve;
	float _DepthPos, _DepthFalloff;
	float _DistancePos, _DistanceFalloff, _DistancePower;
	CBUFFER_END // WaterParamRare




	struct appdata {
		float4 color : COLOR0;
		float4 vertex : POSITION;
		float4 tangent : TANGENT;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
		
		float4 uvgrab : TEXCOORD5;
		float4 screenUV : ATTR0;
		float4 pos : SV_POSITION;
		float4 tSpace0 : TEXCOORD1;
		float4 tSpace1 : TEXCOORD2;
		float4 tSpace2 : TEXCOORD3;
		fixed4 color : COLOR0;
		float3 viewNormal : ATTR1;
		float2 pack0 : TEXCOORD0; 
		float eyeD : TEXCOORD4;
		
	};

	float3 BoxProjection(
		float3 direction, float3 position,
		float3 cubemapPosition, float3 boxMin, float3 boxMax
		) {
		float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
		float scalar = min(min(factors.x, factors.y), factors.z);
		return direction * scalar + (position - cubemapPosition);
	}

	// Vertex shader
	v2f vert(appdata v) {

		v2f o;
		UNITY_INITIALIZE_OUTPUT(v2f,o);

		o.pos = UnityObjectToClipPos(v.vertex);
		o.screenUV = ComputeScreenPos(o.pos);
/*
#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
#else
		float scale = 1.0;
#endif

		//Compute uv for the grabPass using the screenPos
		o.uvgrab.xy = (float2(o.pos.x, o.pos.y*scale) + o.pos.w) * 0.5;
		o.uvgrab.zw = o.pos.zw;*/

		o.uvgrab = ComputeGrabScreenPos(o.pos);


		//Transform uv using the Unity Inspector
		o.pack0.xy = TRANSFORM_TEX(v.texcoord, _BumpMap);
		
		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

		float disp = tex2Dlod(_Displacement, float4(v.texcoord + _Time.x * _Speed.xy, 0, 0)).x * 2 - 1;
		disp *= _DispIntensity;

		worldPos += worldNormal * disp * (v.color.r);
		o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1));


		fixed3 screenNormal = normalize(mul(UNITY_MATRIX_V,worldNormal));
		fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
		fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;

		//Reconstruct binormal
		fixed3 worldBinormal = normalize(cross(worldNormal, worldTangent) * tangentSign);

		//We pack tangent binormal normal and world pos in three float4
		//Just like unity does in surface shader
		o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
		o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
		o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
		o.viewNormal = screenNormal;
		o.color = v.color;

		COMPUTE_EYEDEPTH(o.eyeD);

		return o;
	}

	// Fragment shader
	fixed4 frag(v2f i) : SV_Target{

	//------------------------------------------//
	//------------------SHADER------------------//
	//------------------------------------------//


		fixed4 o;

	//return float4(i.viewNormal, 1.0);
	float3 worldTan = float3(i.tSpace0.x, i.tSpace1.x, i.tSpace2.x);
	float3 worldBin = float3(i.tSpace0.y, i.tSpace1.y, i.tSpace2.y);
	float3 worldNor = float3(i.tSpace0.z, i.tSpace1.z, i.tSpace2.z);
	float3 worldPos = float3(i.tSpace0.w, i.tSpace1.w, i.tSpace2.w);


	_DepthPos *= 0.01;
	_DepthFalloff *= 0.01;
	_DistancePos *= 0.01;
	_DistanceFalloff *= 0.01;






	//Premultiplied speed and setup uvPan
	//_Speed is a float4 xy is for the first map and zw for the second
	_Speed = _Speed *  _GlobalSpeed;

#ifdef _USE_FLOW_VERTEX
	//Setting up flow using the vertex colors
	float phase1 = frac(_Time.y * _FlowSpeed);
	float phase2 = frac(_Time.y * _FlowSpeed + 0.5);

	float2 flow = (i.color.rg * 2 - 1) * _FlowIntensity;

	float lerpFactor = abs(0.5 - phase1) / 0.5;

	//Fetch normal map, we dont need the z component
	//We don't need a precise normal map so we can just generate the third component later
	fixed2 bump = tex2D(_BumpMap, float2(i.pack0 + _Time.x * _Speed.xy) - flow * phase1).ag * 2 - 1;
	bump += (tex2D(_BumpMap, float2(i.pack0 + _Time.x * _Speed.zw) *0.7 - flow * phase1).ag * 2 - 1);
	fixed2 bumpSec = tex2D(_BumpMap, float2(i.pack0 + _Time.x * _Speed.xy) - flow * phase2).ag * 2 - 1;
	bumpSec += (tex2D(_BumpMap, float2(i.pack0 + _Time.x * _Speed.zw)*0.7 - flow * phase2).ag * 2 - 1);

	fixed2 grabBump = tex2D(_BumpMap, float2(i.pack0 + _Time.x * 0.8 * _Speed.xy) - flow * phase1).ag * 2 - 1;
	grabBump += (tex2D(_BumpMap, float2(i.pack0 + _Time.x * 0.8 * _Speed.zw) *0.7 - flow * phase1).ag * 2 - 1);
	fixed2 grabBumpSec = tex2D(_BumpMap, float2(i.pack0 + _Time.x * 0.8 * _Speed.xy) - flow * phase2).ag * 2 - 1;
	grabBumpSec += (tex2D(_BumpMap, float2(i.pack0 + _Time.x * 0.8 * _Speed.zw)*0.7 - flow * phase2).ag * 2 - 1);

	//Combine bump just add them for the moment
	fixed2 doubleBump = lerp(bump.rg, bumpSec.rg, lerpFactor);
	fixed2 grabDoubleBump = lerp(grabBump.rg, grabBumpSec.rg, lerpFactor);

#endif
#ifndef _USE_FLOW_VERTEX
	//Fetch normal map, we dont need the z component
	//We don't need a precise normal map so we can just generate the third component later
	fixed2 bump = UnpackNormal(tex2D(_BumpMap, float2(i.pack0 + _Time.x * _Speed.xy))).xy;
	fixed2 bumpSec = UnpackNormal(tex2D(_BumpMap, float2(i.pack0 + _Time.x * _Speed.zw)*0.7)).xy;

	fixed2 grabBump = UnpackNormal(tex2D(_BumpMap, float2(i.pack0 + _Time.x * 0.5 * _Speed.xy))).xy;
	fixed2 grabBumpSec = UnpackNormal(tex2D(_BumpMap, float2(i.pack0 + _Time.x * 0.5 * _Speed.zw)*0.7)).xy;

	//Combine bump just add them for the moment
	fixed2 doubleBump = bump.rg + bumpSec.rg;
	fixed2 grabDoubleBump = grabBump.rg + grabBumpSec.rg;
#endif



	//return float4(worldTan, 1);
	float2 uv = i.screenUV.xy / i.screenUV.w;
	//Compute the refraction ( sample GrabPass )

	float2 grabOffset = (i.viewNormal *_RefractionOffset + grabDoubleBump) * _BumpGrabAmt;// _BumpGrabAmt * ((1 - depthTest)*_MaxGrab);
	i.uvgrab.xy = grabOffset * i.uvgrab.z + i.uvgrab.xy;
	half3 grab = tex2D(_GrabTexture, uv + grabOffset / i.screenUV.w); //tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab)).rgb;

																	  
	//Compute world position using the depth buffer

	//---(This part needs work)---
	float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + (grabOffset) / i.screenUV.w);
	float depth2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
	float depthRefract = LinearEyeDepth(depth);
	float depthNoRefract = LinearEyeDepth(depth2);

	float eyeTest = i.eyeD - depthRefract;

	if (eyeTest > 0)
	{
		grab = tex2D(_GrabTexture, uv ); //tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab)).rgb;
		depth = depth2;
	}
	//return float4(test.xxx, 1);
	

	//return float4(grab, 1);
#if defined(UNITY_REVERSED_Z)
	depth = 1.0f - depth;
	depthNoRefract = 1.0f - depthNoRefract;
#endif

	float4 H = float4(uv.xy * 2 - 1, depth, 1.0);
	float4 D = mul(_ProjectInverse, H);
	D = float4(D.xyz / D.w, 1.0);
	float4 wSPos = mul(_ViewInverse, D);
	//return float4(wSPos.rgb, 1.0);

	float3 depthWP = wSPos.xyz;

	//Here we compensate from an unknown issue (" You jsut need to fix that matrix mate ")
	float toCamDist = length((worldPos - _WorldSpaceCameraPos.xyz) * float3(0, 1, 0));
	depthWP += toCamDist;

	//---(/This part need work)---

	//Setup gradient
	float depthTest = pow(smoothstep(_DistancePos + worldPos.y, _DistancePos + worldPos.y + _DistanceFalloff, depthWP.y), _DistancePower);
	float mask = smoothstep(_DepthPos + worldPos.y, _DepthPos + worldPos.y + _DepthFalloff, depthWP.y);

	//Reconstruct the normal map using the sum of both initial normal map
	float3 finalNM = normalize(float3(doubleBump*_NormalMapAmt, 1));

	//Compute the world normal 
	float3 worldNormal = normalize(worldBin * finalNM.y + (worldTan * finalNM.x + worldNor));

	
	//Compute the view direction
	float3 V = normalize( _WorldSpaceCameraPos - worldPos);// UNITY_MATRIX_IT_MV[2].xyz);

	//Compute the spec factor
	//Here we use both the world normal previously computed 
	//and the world normal we calculated in the vertex shader 
	float NdotV = saturate(dot(V, worldNor));
	float NdotVnormal = saturate(dot(V, worldNormal));

	float3 reflDir = reflect( worldPos - _WorldSpaceCameraPos, worldNormal);
#ifdef _DRAW_SUN_DISC

	float sunDisc = pow(smoothstep(1 - _SunDiscScale,1,dot(normalize(reflDir), _SunDir)), _SunDiscPow);
	float3 sunImpact = sunDisc*_SunColor;
#endif

#ifdef _USE_REFLECTION_PROBE
#if _BOX_PROJECTION
	reflDir = BoxProjection(
		reflDir, worldPos,
		unity_SpecCube0_ProbePosition,
		unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
		);
#endif


	float4 reflection = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflDir);
	reflection.xyz = DecodeHDR(reflection, unity_SpecCube0_HDR);

#else
	//Compute the reflection ( sample ReflectionTex )
	float2 offset = doubleBump * _BumpAmt;
	fixed4 reflection = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.screenUV + float4(offset, 0, 0)));
	
#endif
	
	//Here we provide to the user everything he need to customize his reflection fresnel
	//It's quiet hard to find something realistic, i'm sure there is some "real" values
	//If you find them it's possible to have something really close by tweaking these variables
	// y = f(a,b,c) = x^a * b + c  :  0 < y < 1   and   0 < x < 1
	float spec = saturate(pow(lerp(NdotV , NdotVnormal,_Shading), _Fresnel)*_ReflCurve + _ReflOffset);


	//We separate here two cases, one where we want the grabPass seven in the depth
	//another where we just want the color ( picture a deep well )
	float3 grabTransp = lerp(grab, grab*_Color  , depthTest);
	float3 grabOpaque = lerp(grab, _Color, depthTest);

	//return float4(depthTest.xxx, 1);
	//We blend them with a parameter
	//We multiply each final value with a parameter
	//It's useful to tweak the final result
	float3 grabFinal = lerp(grabTransp, grabOpaque, _WaterOpacity) * _GrabBoost;
	float3 reflFinal = pow(reflection* _ReflBoost, _ReflPow);

	
	//Finally we lerp between the reflection and the refraction using the spec we computed earlier
	fixed3 finalEmi = lerp(reflFinal, grabFinal, spec);

#ifdef _DRAW_SUN_DISC

	finalEmi.xyz += sunImpact.xyz;
#endif

	//Output
	o.rgb = finalEmi.xyz;
	o.a = mask ;
	return o;

	//------------------------------------------//
	//----------------END-SHADER----------------//
	//------------------------------------------//



	}

		ENDCG

	}


	


	}
		FallBack "Diffuse"
}
