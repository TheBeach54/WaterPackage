// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Beach/Water" {
	Properties{

		[Toggle(_DEFERRED_RENDERING)]_DeferredRendering("_DEFERRED_RENDERING", Float) = 1
		[Header(Textures)][Space]
	_CausticMap("Caustic Map (RG:DeformMap,B:Caustic Mask)", 2D) = "black" {}
	[Header(Procedural Waves Setup)]
	_wavAmp("_wavAmp", Float) = 1
	_wavFreq("_wavFreq", Float) = 1
	_wavSpeed("_wavSpeed", Float) = 1
	_wavNorm("_wavNormal", Float) = 1
	[HideInInspector]_DynamicHeight("D", 2D) = "grey" {}
	[HideInInspector]_DynamicBump("B",2D) = "bump" {}
			
		[Toggle(_USE_DYNAMIC_WAVES)]_UseDynamicWaves("Use Dynamic Waves(variant)", Float) = 0
			_Displacement("_Displacement", Float) = 1
			_NormalPower("Displaced Normal Power", Float) = 1

	[Header(Normal Map Pan Setup)][Space]
		_BumpMap("Normal Map", 2D) = "bump" {}
		_GlobalSpeed("Global Speed", Float) = 5
		_NormalPropScale("Second Normal Map Proportional Scale", Float) = 0.7
		_Speed("Pan Speed (xy) Bump01 (zw) Bump02", Vector) = (1,0,-1,0.5)
		[Toggle(_USE_FLOW_VERTEX)]_UseFlow("Use Flow Vertex (variant)", Float) = 0

		_FlowSpeed("Flow Speed",Float) = 0.5
		_FlowIntensity("Flow Intensity", Float) = 1

		[Header(Water)][Space]
		_GlobalBrightness("_GlobalBrightness", Float) = 1
		[HDR]_Color("Water Color",Color) = (0,0,0,1)
		_WaterOpacity("Water Opacity", Range(0,1)) = 1
		[Toggle(_USE_FOG_EXPONENTIAL)]_UseFogExp("Use exponential fog instead of world space mask", Float) = 1
		[PowerSlider(3.0)]_Density("Fog Exponential Density", Range(0,10)) = 1

		[Header(Reflection)][Space]

		[Toggle(_USE_REFLECTION_PROBE)]_UseReflectionProbe("(variant) Use Reflection Probe", Float) = 1
		[Toggle(_BOX_PROJECTION)]_UseBoxProjection("(variant) Probe Box Projection", Float) = 0
		_ReflBoost("Reflection Brightness" , Float) = 1
		_ReflPow("Reflection Power", Float) = 1
		_BumpAmt("Reflection Amplitude", Float) = 0
		_Smoothness("Reflection Glossiness", Range(0,1)) = 1
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_NormalMapAmt("Normal Map Boost", Float) = 0.08

		[Header(Refraction)][Space]
		_GrabBoost("Refraction Brightness", Float) = 1
		_BumpGrabAmt("Grab Amplitude", Float) = 0.05
		_GrabPropScale("Normal Map Proportional Tilling", Float) = 0.7
		_GrabPropSpeed("Normal Map Proportional Speed", Float) = 0.5
		_RefractionOffset("Refraction Offset", Float) = 0
		_RefractionBias("Refraction Bias",Float) = 0.2
		[Space]


	[Header(Fresnel Setup)][Space]
		_FresnelIndice("Liquid Indice", Float) = 1.4
		_NormalMapFresnelAmt("Fresnel Normal Map Boost", Float) = 0.15
		[PowerSlider(3.0)]_ReflectionDensity("_ReflectionDensity", Range(0,10)) = 0.5
		_ReflMin("Min Reflection (1:Transparent)", Float) = 1
		_ReflMax("Max Reflection (0:Mirror)", Float) = 0
		[Space]
	[Toggle(_DEBUG_FRESNEL)]_DebugFresnel("DEBUG : Visualize Fresnel (0=Mirror,1=Transparent)", Float) = 0


		[Header(Shading)][Space]
		_SunShading("Sun Shading", Range(0,1)) = 0.1
		_SunVolumetricShading("_SunVolumetricShading", Float) = 1
		_ShadingDensity("Volumetric Water Density", Float) = 0.12
		_ShadowMaxDepth("Volumetric Shadow Max Depth" , Float) = 10

		_AmbientShading("Ambient Shading", Range(0,1)) = 0.05
		[Toggle(_DRAW_SUN_DISC)]_DrawSunDisc("(variant) Draw Sun Disc ", Float) = 1
		_SunDiscScale("Sun Scale", Range(0,1)) = 0.005
		_SunDiscPow("Sun Power", Float) = 3
		[Toggle(_RECEIVE_SHADOWS)]_ReceiveShadows("(variant) Receive Shadows", Float) = 0
		[Toggle(_RECEIVE_VOLUMETRIC_SHADOWS)]_ReceiveVolumetricShadows("(variant) Receive Volumetric Shadows (slower)", Float) = 0
		[KeywordEnum(_128, _64, _32, _16)]_MARCH("(variant) Step To Draw The Volumetric Shadows ( more is slower)", Float) = 0
		
		_ShadowOpacity("Shadow Opacity", Range(0,1)) = 1
		_DispIntensity("Shadow Displacement Intensity", Float) = 0


		[Header(Caustic Setup)][Space]

		[Toggle(_DRAW_CAUSTIC)]_DrawCaustic("(variant) Draw Caustic", Float) = 1
		_CausticBrightness("Caustic Brightness", Float) = 1
		_CausticColor("Caustic Color Multiplier", Color) = (1,1,1,1)
		_CausticSpeed("Pan Speed (xy) Caustic (zw) Deform Map", Vector) = (1,-1,-1,0.5)
		_CausticShadowBias("Caustic Shadow Bias" ,Float) = 0
		[Header(Triplanar Caustic Setup)][Space]
		_CausticScaleMin("Caustic Minimum Tilling", Float) = 9.5
		_CausticDeformScale("Caustic Deform Map Tilling",Float) = 6.5
		_CausticDeformIntensityMin("Caustic Deform Intensity Min", Float) = 0
		_CausticDeformIntensityMax("Caustic Deform Intensity Max", Float) = 1.1
		[Header(Projection Caustic Setup)][Space]
		[Toggle(_PROJ_CAUSTIC)]_ProjCaustic("(variant) Use Sun Projection For The Caustics", Float) = 0

		_CausticProjScaleMin("Caustic Projection Minimum Tilling", Float) = 9.5
		_CausticProjScaleMax("Caustic Projection Maximum Tilling", Float) = 9.5
		_CausticProjDeformScale("Caustic Projection Deform Map Tilling",Float) = 6.5
		_CausticProjDeformIntensityMin("Caustic Projection Deform Intensity Min", Float) = 0
		_CausticProjDeformIntensityMax("Caustic Projection Deform Intensity Max", Float) = 1.1
	[Space]
		[Toggle(_DEBUG_CAUSTIC_RG)]_DebugCausticRG("DEBUG : Visualize Caustic Deform (RG)", Float) = 0

		//_CausticScaleMax("_CausticScaleMax",Float) = 1

		[Header(Under Setup)]
		_LiquidIndice("Sun Disc Refraction Indice", Range(0, 2)) = 1.05
		_ShadowDisp("Sun Disc Shadow Displacement", Float) = 0.5
		_UnderBumpAmt("Sun Disc Bump Boost", Float) = 1
		_UnderGrabAmt("Refraction Multiplier", Float) = 1

			[Header(Post Effect Specific Setup)]
		_PEGrabScale("Refraction Bump Map Scale", Float) = 1
			_PEGrabScaleProp("Second Bump Map Proportional Scale", Float) = 1
			_PEGrabAmt("Refraction Amplitude", Float) = 1


		[Header(Depth Gradient and Mask Setup)]
	[Space]
	[Header(Depth Alpha Mask)]

	_DepthPos("Depth Mask Offset", Float) = 0
		_DepthFalloff("Depth Mask Falloff", Float) = -0.4
		[Toggle(_REFRACT_ALPHA_MASK)]_RefractAlpha("(variant) Refract The Alpha Mask", Float) = 1
		[Toggle(_DEBUG_MASK_DEPTH)]_DebugMaskDepth("DEBUG : Visualize Depth Alpha Mask", Float) = 0

		[Space]
	[Space]
	[Header(Depth Color Gradient (Obsolete))]

	

	_DistancePos("Depth Color Offset", Float) = 0
		_DistanceFalloff("Depth Color Falloff", Float) = -17.5
		_DistancePower("Depth Color Power", Float) = 0.4
		[Toggle(_DEBUG_COLOR_DEPTH)]_DebugColorDepth("DEBUG : Visualize Depth Color Mask", Float) = 0

		[Space]
	[Space]
	[Header(Depth Reflection Mask)]

	_ReflMaskPos("Reflection Mask Offset", Float) = 4
		_ReflMaskFalloff("Reflection Mask Falloff", Float) = -12.5
		[Toggle(_DEBUG_REFLECTION_DEPTH)]_DebugReflectionDepth("DEBUG : Visualize Reflection Mask", Float) = 0

		[Header(Luminance Reflection Mask)]

	_ReflMaskMin("Reflection Mask by Luminance Offset", Float) = -1
		_ReflMaskMax("Reflection Mask Falloff", Float) = 0
		[Toggle(_DEBUG_REFLECTION_LUMINANCE)]_DebugReflectionLuminance("DEBUG : Visualize Reflection Luminance Mask", Float) = 0

		[Space]
	[Space]
	[Header(Depth Caustic Top Mask)]

	_CausticOffset("Caustic Top Offset", Float) = 0
		_CausticFalloff("Caustic Top FallOff", Float) = -6
		[Toggle(_DEBUG_CAUSTIC_DEPTH)]_DebugCausticDepth("DEBUG : Visualize Caustic Top Mask", Float) = 0
		[Space]

		[Header(Depth Caustic Bottom Gradient)]

	_CausticBotOffset("Caustic Bottom Offset", Float) = -10
		_CausticBotFalloff("Caustic Bottom FallOff", Float) = 10
		[Toggle(_DEBUG_CAUSTICBOT_DEPTH)]_DebugCausticBotDepth("DEBUG : Visualize Caustic Bottom Mask", Float) = 0

		[Space]


		[Space]
		[Header(Depth Caustic Scale Gradient)]

	_CausticScaleDistance("Caustic Scale Offset", Float) = 0
		_CausticScaleFalloff("Caustic Scale FallOff", Float) = -6
		[Toggle(_DEBUG_CAUSTIC_SCALE_DEPTH)]_DebugCausticScaleDepth("DEBUG : Visualize Caustic Scale Mask", Float) = 0

		[Space]

	[Header(Depth Caustic Deform Gradient)]

	_CausticDeformOffset("Caustic Depth Deform Offset", Float) = 0
		_CausticDeformFalloff("Caustic Depth Deform FallOff", Float) = -7
		[Toggle(_DEBUG_DEFORM_DEPTH)]_DebugDeformDepth("DEBUG : Visualize Caustic Depth Deform Gradient", Float) = 0
		[Space]

	[Header(Depth Blur Mask)]

		_BlurOffset("Blur Mask Offset" , Float) = 0
		_BlurFalloff("Blur Mask Falloff", Float) = -4
		_BlurPower("Blur Mask Power", Float) = 1
		[Toggle(_DEBUG_BLUR_DEPTH)]_DebugBlurDepth("DEBUG : Visualize Depth Blur Mask", Float) = 0


			_WaterPosition("_WaterPosition", Vector) = (0, 0, 0, 1)
			_SimulationPosition("_SimulationPosition", Vector) = (0,0,0,1)

		[HideInInspector][HDR] _ReflectionTex("", 2D) = "white" {}

	//[HideInInspector][HDR] _DirShadowMap("", 2D) = "black" {}



	}
	SubShader{

	GrabPass{}
	Tags{ "Queue" = "Transparent-1" "ForceNoShadowCasting" = "True" "LightMode" = "ForwardBase" }
		Pass
	{
		Tags {"Queue" = "Transparent-2" "RenderType" = "Transparent"}
		Stencil{
		Ref 2
		Comp Always
		Pass Replace
	}
		ZWrite On
		ColorMask 0

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma shader_feature _USE_DYNAMIC_WAVES


#include "UnityCG.cginc"
#include "Water.cginc"

		sampler2D _DynamicHeight;
	float4 _SimulationPosition;
	float _Displacement;
		struct appdata
		{
			float4 vertex : POSITION;
			float4 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
				float4 pos : SV_POSITION;
		};

		v2f vert(appdata v)
		{
			v2f o;
			fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
			//
			//WaveDisplace(worldPos.x * 0.1, worldPos, worldNormal);
			//WaveDisplace((worldPos.z + worldPos.x) / 2, worldPos, worldNormal);
			//WaveDisplace(worldPos.z*1.8, worldPos, worldNormal);
			//WaveDisplace(0, worldPos, worldNormal);
			//worldNormal = normalize(UnityObjectToWorldNormal(v.normal));


#ifdef _USE_DYNAMIC_WAVES

			float2 simUV = float2(InverseLerp(_SimulationPosition.x - 0.5f * _SimulationPosition.w, _SimulationPosition.x + 0.5f * _SimulationPosition.w, worldPos.x), InverseLerp(_SimulationPosition.z - 0.5f * _SimulationPosition.w, _SimulationPosition.z + 0.5f * _SimulationPosition.w, worldPos.z));
			DynamicDisplace(_DynamicHeight, simUV, worldNormal, _Displacement, worldPos);


#endif


			o.pos = mul(UNITY_MATRIX_VP, worldPos);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			// sample the texture
			float4 col = float4(0,0,0,0);

		return col;
		}
			ENDCG
		}
		Pass{
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent"}

			Stencil{
			Ref 2
			Comp GEqual
			Pass Keep
		}
		//Name "FORWARD"
		ZWrite Off


		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// compile directives
#pragma vertex vert
#pragma fragment frag
#pragma target 5.0

#pragma shader_feature _DEFERRED_RENDERING
#pragma shader_feature _USE_REFLECTION_PROBE
#pragma shader_feature _BOX_PROJECTION
#pragma shader_feature _DRAW_CAUSTIC
#pragma shader_feature _PROJ_CAUSTIC
#pragma shader_feature _USE_FLOW_VERTEX
#pragma shader_feature _DRAW_SUN_DISC
#pragma shader_feature _BLUR_REFRACTION
#pragma shader_feature _REFRACT_ALPHA_MASK
#pragma shader_feature _RECEIVE_SHADOWS
#pragma shader_feature _RECEIVE_VOLUMETRIC_SHADOWS
#pragma shader_feature _USE_FOG_EXPONENTIAL
#pragma shader_feature _MARCH__128 _MARCH__64 _MARCH__32 _MARCH__16
#pragma shader_feature _USE_DYNAMIC_WAVES

			


		//Shader Debug Feature, shouldn't be used in game and therefore shouldn't be generate when building the game
#pragma shader_feature _DEBUG_CAUSTICBOT_DEPTH
#pragma shader_feature _DEBUG_CAUSTIC_SCALE_DEPTH
#pragma shader_feature _DEBUG_DEFORM_DEPTH
#pragma shader_feature _DEBUG_CAUSTIC_DEPTH
#pragma shader_feature _DEBUG_REFLECTION_DEPTH
#pragma shader_feature _DEBUG_COLOR_DEPTH
#pragma shader_feature _DEBUG_MASK_DEPTH
#pragma shader_feature _DEBUG_CAUSTIC_RG
#pragma shader_feature _DEBUG_FRESNEL
#pragma shader_feature _DEBUG_BLUR_DEPTH
#pragma shader_feature _DEBUG_VOLUMETRIC_SHADOW
#pragma shader_feature _DEBUG_REFLECTION_LUMINANCE
			

#include "UnityCG.cginc"

#include "Water.cginc"



		CBUFFER_START(WaterParam) //Change every frame
	//	uniform sampler2D_float _CameraDepthTexture;
	float4 _CameraDepthTexture_ST;
#ifndef _USE_REFLECTION_PROBE
	uniform sampler2D_float _ReflectionTex;
#endif
	sampler2D _DynamicHeight;
	sampler2D _DynamicBump;
	float4 _GrabTexture_TexelSize;
	sampler2D _GrabBlurTexture;


	//Matrix we get from a script
	float4x4 _ProjectInverse;
	float4x4 _ViewInverse;
	CBUFFER_END // WaterParam

		CBUFFER_START(WaterParamRare) //Never change during runtime
		sampler2D _BumpMap;


#ifdef _USE_FLOW_VERTEX
	half _FlowSpeed;
	half _FlowIntensity;
#endif
	float _Displacement, _NormalPower;
	float4 _BumpMap_ST;
	float4 _Color;

	float4 _Speed;
	float4 _SunColor;
	float4 _SpecularColor;

	float4 _SimulationPosition;


#ifdef _DRAW_SUN_DISC
	float _SunDiscScale, _SunDiscPow;

#endif


#if _BLUR_REFRACTION || _DEBUG_BLUR_DEPTH
	float _BlurFalloff, _BlurOffset, _BlurPower;
#endif
	float _NormalPropScale;
	float _GlobalBrightness;
float _ReflectionDensity;
	float _Smoothness;
	float _ReflMaskMin, _ReflMaskMax;
	float _GrabPropScale, _GrabPropSpeed;
	float _RefractionOffset;
	float _RefractionBias;
	float _BlurDist;
	float _ReflMaskFalloff, _ReflMaskPos;
	float _GlobalSpeed;
	float _WaterOpacity;
	float _ReflBoost;
	float _ReflPow;
	float _GrabBoost;
	float _BumpGrabAmt, _MaxGrab;
	float _BumpAmt, _NormalMapAmt, _NormalMapFresnelAmt;
	float _FresnelIndice, _ReflMin, _ReflMax;
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

		float4 screenUV : ATTR0;
		float4 pos : SV_POSITION;
		float4 tSpace0 : TEXCOORD1;
		float4 tSpace1 : TEXCOORD2;
		float4 tSpace2 : TEXCOORD3;
		fixed4 color : COLOR0;
		float2 pack0 : TEXCOORD0;
		float eyeD : TEXCOORD4;

	};

	// Vertex shader
	v2f vert(appdata v) {

		v2f o;
		UNITY_INITIALIZE_OUTPUT(v2f,o);


		fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
		float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

#ifdef _USE_DYNAMIC_WAVES

		float2 simUV = float2(InverseLerp(_SimulationPosition.x - 0.5f * _SimulationPosition.w, _SimulationPosition.x + 0.5f * _SimulationPosition.w, worldPos.x), InverseLerp(_SimulationPosition.z - 0.5f * _SimulationPosition.w, _SimulationPosition.z + 0.5f * _SimulationPosition.w, worldPos.z));
		if (simUV.x < 0.0f || simUV.x > 1.0f || simUV.y < 0.0f || simUV.y > 1.0f)
			simUV = 0;
		else
		{
			DynamicDisplace(_DynamicHeight, simUV, worldNormal, _Displacement, worldPos);
		}

#endif
		//WaveDisplace(worldPos.x * 0.1, worldPos, worldNormal);
		//WaveDisplace((worldPos.z + worldPos.x) / 2, worldPos, worldNormal);
		//WaveDisplace(worldPos.z*1.8, worldPos, worldNormal);

		//worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

		o.pos = mul(UNITY_MATRIX_VP,worldPos);
		o.screenUV = ComputeScreenPos(o.pos);

		//Transform uv using the Unity Inspector
		o.pack0.xy = TRANSFORM_TEX(v.texcoord, _BumpMap);
	//	o.uv.xy = v.texcoord;



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
	//	o.viewNormal = screenNormal;
		o.color = v.color;

		o.eyeD = -mul(UNITY_MATRIX_V, worldPos).z;


		return o;
	}

	// Fragment shader
	fixed4 frag(v2f i) : SV_Target{


		//------------------------------------------//
		//------------------SHADER------------------//
		//------------------------------------------//


		fixed4 o;

	//redistribute the values packed earlier
	float3 worldTan = float3(i.tSpace0.x, i.tSpace1.x, i.tSpace2.x);
	float3 worldBin = float3(i.tSpace0.y, i.tSpace1.y, i.tSpace2.y);
	float3 worldNor = float3(i.tSpace0.z, i.tSpace1.z, i.tSpace2.z);
	float3 worldPos = float3(i.tSpace0.w, i.tSpace1.w, i.tSpace2.w);

	float time = _Time.x;

	//Premultiplied speed and setup uvPan
	//_Speed is a float4 xy is for the first map and zw for the second
	_Speed = _Speed *  _GlobalSpeed;



	float2 grabBumpUV = i.pack0 *_GrabPropScale;
	float4 bumpT = time * _Speed;
	float4 grabT = bumpT * _GrabPropSpeed;

#ifdef _USE_FLOW_VERTEX
	//Setting up flow using the vertex colors
	float phase1 = frac(_Time.y * _FlowSpeed);
	float phase2 = frac(_Time.y * _FlowSpeed + 0.5);

	float2 flow = (i.color.rg * 2 - 1) * _FlowIntensity;

	float lerpFactor = abs(0.5 - phase1) / 0.5;


	float2 flowT1 = flow * phase1;
	float2 flowT2 = flow * phase2;

	half secFact = _NormalPropScale;

	//We pack the uvs for both sampling in a single float4 to optimize the computation
	float4 flowBumpUV = fmod((float4(i.pack0, i.pack0) + bumpT) * float4(1, 1, secFact, secFact), 50.0f);
	float4 flowGrabUV = fmod((float4(grabBumpUV, grabBumpUV) + grabT) * float4(1, 1, secFact, secFact),50.0f);

	//Fetch normal map
	//Add them
	fixed2 bump = tex2D(_BumpMap, flowBumpUV.xy - flowT1).ag * 2 - 1;
	bump += (tex2D(_BumpMap, flowBumpUV.zw - flowT1).ag * 2 - 1);
	fixed2 bumpSec = tex2D(_BumpMap, flowBumpUV.xy - flowT2).ag * 2 - 1;
	bumpSec += (tex2D(_BumpMap, flowBumpUV.zw - flowT2).ag * 2 - 1);

	fixed2 grabBump = tex2D(_BumpMap, flowGrabUV.xy - flowT1).ag * 2 - 1;
	grabBump += (tex2D(_BumpMap, flowGrabUV.zw - flowT1).ag * 2 - 1);
	fixed2 grabBumpSec = tex2D(_BumpMap, flowGrabUV.xy - flowT2).ag * 2 - 1;
	grabBumpSec += (tex2D(_BumpMap, flowGrabUV.zw - flowT2).ag * 2 - 1);

	//Lerp using the flow lerpfactor
	fixed2 doubleBump = lerp(bump.rg, bumpSec.rg, lerpFactor);
	fixed2 grabDoubleBump = lerp(grabBump.rg, grabBumpSec.rg, lerpFactor);


#else
	//Fetch normal map, we dont need the z component
	//We don't need a precise normal map so we can just generate the third component later
	fixed2 bump = UnpackNormal(tex2D(_BumpMap, fmod(float2(i.pack0 + bumpT.xy),50.0f))).xy;
	fixed2 bumpSec = UnpackNormal(tex2D(_BumpMap, fmod(float2(i.pack0 + bumpT.zw)*_NormalPropScale, 50.0f))).xy;

	fixed2 grabBump = UnpackNormal(tex2D(_BumpMap, fmod(float2(grabBumpUV + grabT.xy), 50.0f))).xy;
	fixed2 grabBumpSec = UnpackNormal(tex2D(_BumpMap, fmod(float2(grabBumpUV + grabT.zw)*_NormalPropScale, 50.0f))).xy;

	//Combine bump just add them for the moment
	fixed2 doubleBump = bump.rg + bumpSec.rg;
	fixed2 grabDoubleBump = grabBump.rg + grabBumpSec.rg;
#endif


	//Using the normal map we compute the new UV to sample the depth and the grabPass
	float2 uv = i.screenUV.xy / i.screenUV.w;


	float2 grabOffset = grabDoubleBump * _BumpGrabAmt;
	//i.uvgrab.xy = grabOffset * i.uvgrab.z + i.uvgrab.xy;

	float2 refrUV = uv + grabOffset / i.screenUV.w;
	float2 refrBiasUV = uv + (grabOffset*(1 + _RefractionBias)) / i.screenUV.w;

	half3 grab;
	float depth, depth2;
	float depthEye, depthRefrEye;

	GetGrabDepth_Corrected(i.eyeD, uv, refrUV, refrBiasUV,grab,depth, depth2,depthEye, depthRefrEye);




#if defined(UNITY_REVERSED_Z)
	depth = 1.0f - depth;
	depth2 = 1.0f - depth2;
#endif

	//Compute world position using the depth buffer
	float3 depthWP = DepthToWorldPos(uv.xy, depth, _ProjectInverse, _ViewInverse);
#ifdef _RECEIVE_SHADOWS
	float3 depthWP2 = DepthToWorldPos(uv.xy, depth2, _ProjectInverse, _ViewInverse);
#endif


	float wT = depthEye - i.eyeD;

	float mask;
#ifdef _REFRACT_ALPHA_MASK
	mask = InverseLerp(_DepthPos ,_DepthPos + _DepthFalloff, wT) * i.color.a;
#else
	float wT2 = depthRefrEye - i.eyeD;
	mask = InverseLerp(_DepthPos, _DepthPos + _DepthFalloff, wT2) * i.color.a;
#endif



	
	//Setup gradient and mask for later blending
	float depthTest;
	float blurTest = 0;
#ifdef _USE_FOG_EXPONENTIAL
	depthTest = 1 / pow(exp(wT*_Density),2);
	depthTest = 1 - depthTest;
#else
	depthTest = pow(smoothstep(_DistancePos , _DistancePos +  _DistanceFalloff, wT), _DistancePower);
#endif
	float reflectionTest;
	//float reflectionTest = InverseLerp(_ReflMaskPos, _ReflMaskPos + _ReflMaskFalloff, wT);
	reflectionTest = 1 / pow(exp(wT*_ReflectionDensity), 2);
	reflectionTest = 1 - reflectionTest;
#if _BLUR_REFRACTION || _DEBUG_BLUR_DEPTH
	blurTest = pow(InverseLerp(_BlurOffset, _BlurOffset + _BlurFalloff, wT),_BlurPower);
#endif
#if _DRAW_CAUSTIC || _DEBUG_CAUSTIC_SCALE_DEPTH || _DEBUG_CAUSTIC_DEPTH || _DEBUG_DEFORM_DEPTH || _DEBUG_CAUSTIC_RG



#endif

	//DEBUG

#ifdef _DEBUG_REFLECTION_DEPTH
	return float4(reflectionTest.xxx, 1);
#endif
#ifdef _DEBUG_COLOR_DEPTH
	return float4(depthTest.xxx, 1);
#endif
#ifdef _DEBUG_MASK_DEPTH
	return float4(mask.xxx, 1);
#endif
#ifdef _DEBUG_BLUR_DEPTH
	return float4(blurTest.xxx, 1);
#endif
	//END DEBUG


	/// ------- CAUSTIC --------- ///


#if _DRAW_CAUSTIC || _DEBUG_CAUSTIC_SCALE_DEPTH || _DEBUG_CAUSTIC_DEPTH || _DEBUG_DEFORM_DEPTH || _DEBUG_CAUSTIC_RG || _DEBUG_CAUSTICBOT_DEPTH

	float3 causticFinal = DrawCaustic(depthWP, refrUV, worldPos.y, unity_ObjectToWorld, blurTest, grab, time);


#if _DEBUG_CAUSTIC_SCALE_DEPTH || _DEBUG_CAUSTIC_DEPTH || _DEBUG_DEFORM_DEPTH || _DEBUG_CAUSTIC_RG || _DEBUG_CAUSTICBOT_DEPTH
	return float4(causticFinal, 1);
#endif


#ifdef _RECEIVE_SHADOWS
	float causticAtten = GetSunShadowsAttenuation_PCF3x3(depthWP2.xyz, depthRefrEye, _CausticShadowBias);
	causticFinal *= causticAtten;
#endif

	grab += causticFinal * grab;
#endif

	/// ------- NORMAL MAP --------- ///



	float dBump = 1;

	//Reconstruct the normal map using the sum of both initial normal map
	float3 finalNM = normalize(float3(doubleBump*_NormalMapAmt, dBump));
	float3 fresnelNM = normalize(float3(doubleBump*_NormalMapFresnelAmt, dBump));

#ifdef _USE_DYNAMIC_WAVES
	float2 simUV = float2(InverseLerp(_SimulationPosition.x - 0.5f * _SimulationPosition.w, _SimulationPosition.x + 0.5f * _SimulationPosition.w, worldPos.x), InverseLerp(_SimulationPosition.z - 0.5f * _SimulationPosition.w, _SimulationPosition.z + 0.5f * _SimulationPosition.w, worldPos.z));

	if (!(simUV.x == 0.0f || simUV.x == 1.0f || simUV.y == 0.0f || simUV.y == 1.0f))
	{
		float3 dynamicNM = UnpackNormal(tex2D(_DynamicBump, simUV));

		dynamicNM.xy *= _NormalPower;
		dynamicNM = normalize(dynamicNM);

		finalNM = finalNM * 0.5 + 0.5;
		fresnelNM = fresnelNM * 0.5 + 0.5;
		dynamicNM = dynamicNM * 0.5 + 0.5;

		float3 t = dynamicNM*float3(2, 2, 2) + float3(-1, -1, 0);
		float3 u = finalNM*float3(-2, -2, 2) + float3(1, 1, -1);
		float3 r = t*dot(t, u) / t.z - u;
		//return r*0.5 + 0.5;

		float3 uu = fresnelNM*float3(-2, -2, 2) + float3(1, 1, -1);
		float3 rr = t*dot(t, uu) / t.z - uu;


		finalNM = normalize(r);
		//return float4(dynamicNM * 0.5 + 0.5, 1);
		fresnelNM = normalize(rr);
	}



#endif

	//Compute the world normal 
	float3 worldNormal = normalize(worldBin * finalNM.y + (worldTan * finalNM.x + worldNor));
	float3 worldNormalFresnel = normalize(worldBin * fresnelNM.y + (worldTan * fresnelNM.x + worldNor));

	//Compute the view direction
	float3 V = normalize(_WorldSpaceCameraPos - worldPos);

	//We compute the dot product for fresnel and lighting
	float NdotVnormal = saturate(dot(worldNormal, V));
	float NdotVfresnel = saturate(dot(worldNormalFresnel, V));

	float NdotL = saturate(dot(_WorldSpaceLightPos0, worldNormal));
	//We compute the reflection vector
	float3 reflDir = reflect(-V, worldNormal);

	//We draw the sun if needed
#ifdef _DRAW_SUN_DISC
	float sunDisc = pow(smoothstep(1 - _SunDiscScale,1,dot(normalize(reflDir), _WorldSpaceLightPos0)), _SunDiscPow);
	sunDisc = saturate(sunDisc);
	sunDisc = pow(sunDisc, _SunDiscPow);
	sunDisc *= _SunDiscScale;
	float3 sunImpact = sunDisc*_LightColor0;
#endif


#ifdef _USE_REFLECTION_PROBE
#ifdef _BOX_PROJECTION
	// We compute the new reflection vector if needed
	reflDir = BoxProjection(
		reflDir, worldPos,
		unity_SpecCube0_ProbePosition,
		unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
		);
#endif
	// We sample mipmap of the probe if we want the water to be rough
	half mipOffset = saturate(1 - _Smoothness);
	float4 reflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, mipOffset * 7);
	reflection.xyz = DecodeHDR(reflection, unity_SpecCube0_HDR);

#else
	//Compute the reflection ( sample ReflectionTex )
	float2 offset = doubleBump * _BumpAmt;
	fixed4 reflection = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.screenUV + float4(offset, 0, 0)));

#endif


	//Schlick's approximation implementation
	//Used to control the fresnel blending between refraction and reflexion
	float r0 = (1 - _FresnelIndice) / (1 + _FresnelIndice);
	r0 *= r0;

	float spec = r0 + (1 - r0)*((NdotVfresnel));
	spec = pow(spec, 1);

	//We provide way to tweak the result
	//return float4(spec.xxx, 1);
	spec = (1 - spec) * reflectionTest;
	spec = (1 - spec);
	spec = lerp(_ReflMax, _ReflMin, spec);
	spec = saturate(1-spec);

	

#ifdef _DEBUG_FRESNEL
	return float4(spec.xxx, 1);
#endif

	//If we need the blurred grabPass 
#ifdef _BLUR_REFRACTION

	half3 grabBlur = tex2D(_GrabBlurTexture, refrUV);

#endif		




	//We separate here two cases, one where we want the grabPass seven in the depth
	//another where we just want the color ( picture a deep well )


	float3 shadingFinal =  _LightColor0;
	float3 shadinGrabFinal = _LightColor0 ;


	float sunAtten = 1;
	shadingFinal = DrawShadow(worldPos, -V, grabDoubleBump, wT, _Density, _LightColor0, sunAtten);
	
#ifdef _BLUR_REFRACTION
	grab = lerp(grab, grabBlur, blurTest);
#endif

	float3 grabOpaque = lerp(grab, _Color+shadingFinal, depthTest);

	float3 reflFinal = pow(reflection* _ReflBoost, _ReflPow) * _SpecularColor;
	float3 grabFinal = lerp(grab + shadingFinal, grabOpaque, _WaterOpacity) * _GrabBoost;






	//We lerp between the reflection and the refraction using the spec we computed earlier and the reflection mask
	float lRefl = Luminance(reflFinal);


	float lumiTest = InverseLerp(_ReflMaskMin, _ReflMaskMin+_ReflMaskMax,lRefl);
#ifdef _DEBUG_REFLECTION_LUMINANCE
	
	return float4(lumiTest.xxx, 1);
#endif
	float3 grabRefl = lerp(grabFinal, reflFinal, spec*lumiTest);

	//We add the lighting
	fixed3 finalEmi = grabRefl;

	//We draw the caustic computed earlier


	//We draw the sun computed earlier
#ifdef _DRAW_SUN_DISC

	finalEmi.xyz += sunImpact.xyz * sunAtten;
#endif


	//Output
	o.rgb = finalEmi.xyz * _GlobalBrightness;
	o.a = mask;
	return o;

	//------------------------------------------//
	//----------------END-SHADER----------------//
	//------------------------------------------//



	}

		ENDCG

	}

	Pass{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque"  "ForceNoShadowCasting" = "True"  "LightMode" = "ForwardBase" }
		Cull Front
		ZWrite Off
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
	float _UnderBumpAmt, _UnderGrabAmt;
	float _BumpGrabAmt,_NormalMapAmt;
	float _LiquidIndice;
	float4 _BumpMap_ST;
	float _NormalPropScale;

	float4 _MainTex_ST, _Color;
	float4 _Speed;
	float4 _GrabTexture_TexelSize;
	sampler2D _BumpMap;
	sampler2D _MainTex;
	float _GrabPropScale, _GrabPropSpeed;


#ifdef _USE_FLOW_VERTEX
	half _FlowSpeed;
	half _FlowIntensity;
#endif
	float _GlobalSpeed;


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


		fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
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


	_Speed = _Speed *  _GlobalSpeed;

	float time = _Time.x;


	float2 grabBumpUV = i.uvbump *_GrabPropScale;
	float4 grabT = time * _Speed * _GrabPropSpeed;

#ifdef _USE_FLOW_VERTEX
	//Setting up flow using the vertex colors
	float phase1 = frac(_Time.y * _FlowSpeed);
	float phase2 = frac(_Time.y * _FlowSpeed + 0.5);

	float2 flow = (i.color.rg * 2 - 1) * _FlowIntensity;

	float lerpFactor = abs(0.5 - phase1) / 0.5;


	float2 flowT1 = flow * phase1;
	float2 flowT2 = flow * phase2;

	half secFact = _NormalPropScale;

	float4 flowGrabUV = fmod((float4(grabBumpUV, grabBumpUV) + grabT) * float4(1, 1, secFact, secFact), 50.0f);


	fixed2 grabBump = tex2D(_BumpMap, flowGrabUV.xy - flowT1).ag * 2 - 1;
	grabBump += (tex2D(_BumpMap, flowGrabUV.zw - flowT1).ag * 2 - 1);
	fixed2 grabBumpSec = tex2D(_BumpMap, flowGrabUV.xy - flowT2).ag * 2 - 1;
	grabBumpSec += (tex2D(_BumpMap, flowGrabUV.zw - flowT2).ag * 2 - 1);


	fixed2 grabDoubleBump = lerp(grabBump.rg, grabBumpSec.rg, lerpFactor);


#else


	fixed2 grabBump = UnpackNormal(tex2D(_BumpMap, fmod(float2(grabBumpUV + grabT.xy), 50.0f))).xy;
	fixed2 grabBumpSec = UnpackNormal(tex2D(_BumpMap, fmod(float2(grabBumpUV + grabT.zw)*_NormalPropScale, 50.0f))).xy;

	//Combine bump just add them for the moment
	fixed2 grabDoubleBump = grabBump.rg + grabBumpSec.rg;
#endif

	//Using the normal map we compute the new UV to sample the depth and the grabPass
	float2 uv = i.screenUV.xy / i.screenUV.w;




	float3 viewVector = _WorldSpaceCameraPos - worldPos;
	float eyeD = length(viewVector);
	float3 V = viewVector / eyeD;
	V = -V;

	float2 grabOffset = grabDoubleBump * _BumpGrabAmt * _UnderGrabAmt;
	//i.uvgrab.xy = grabOffset * i.uvgrab.z + i.uvgrab.xy;

	float2 refrUV = uv + grabOffset / i.screenUV.w;
	float2 refrBiasUV = uv + (grabOffset*(1 + _RefractionBias)) / i.screenUV.w;

	half3 grab;
	float depth, depth2;
	float depthEye, depthRefrEye;

	GetGrabDepth_Corrected(eyeD, uv, refrUV, refrBiasUV, grab, depth, depth2, depthEye, depthRefrEye);




	//Reconstruct the normal map using the sum of both initial normal map
	float3 finalNM = normalize(float3(grabDoubleBump * _UnderBumpAmt, 1)) * 0.5 + 0.5;


	//Compute the world normal 
	float3 worldNormal = -normalize(worldBin * finalNM.y + (worldTan * finalNM.x + worldNor));


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
	float3 shadowRefract = grabDoubleBump.xyx * float3(1,1,0) * _ShadowDisp;
	float atten = GetSunShadowsAttenuation_PCF3x3(worldPos + shadowRefract, eyeD, 0);
	atten = lerp(1, atten, _ShadowOpacity);
	sunImpact *= atten;
	//	return float4(t.xxx, 1);
#endif

	o.rgb = grab  + sunImpact;
	o.a = 1;
	return o;
	}
		ENDCG
	}





	}
		FallBack "Diffuse"
}
