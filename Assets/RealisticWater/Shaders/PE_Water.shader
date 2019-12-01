// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Beach/PE_Water" {
	Properties{

		[Toggle(_DEFERRED_RENDERING)]_DeferredRendering("_DEFERRED_RENDERING", Float) = 1
		[Header(Textures)][Space]
[HideInInspector]	_MainTex("",2D) = "black" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
	_CausticMap("Caustic Map (RG:DeformMap,B:Caustic Mask)", 2D) = "black" {}

	[Header(Procedural Waves Setup)]
	_wavAmp("_wavAmp", Float) = 1
		_wavFreq("_wavFreq", Float) = 1
		_wavSpeed("_wavSpeed", Float) = 1
		_wavNorm("_wavNormal", Float) = 1

	[Header(Normal Map Pan Setup)][Space]
		_GlobalSpeed("Global Speed", Float) = 5
		_NormalPropScale("Second Normal Map Proportional Scale", Float) = 0.7
		_Speed("Pan Speed (xy) Bump01 (zw) Bump02", Vector) = (1,0,-1,0.5)


		[Header(Water)][Space]
		_GlobalBrightness("_GlobalBrightness", Float) = 1
		[HDR]_Color("Water Color",Color) = (0,0,0,1)
		_WaterOpacity("Water Opacity", Range(0,1)) = 1
		[Toggle(_USE_FOG_EXPONENTIAL)]_UseFogExp("Use exponential fog instead of world space mask", Float) = 1
		[PowerSlider(3.0)]_Density("Fog Exponential Density", Range(0,10)) = 1

		[Header(Refraction)][Space]
		_GrabBoost("Refraction Brightness", Float) = 1
		_BumpGrabAmt("Grab Amplitude", Float) = 0.05
		_GrabPropScale("Normal Map Proportional Tilling", Float) = 0.7
		_GrabPropSpeed("Normal Map Proportional Speed", Float) = 0.5
		_RefractionOffset("Refraction Offset", Float) = 0
		_RefractionBias("Refraction Bias",Float) = 0.2
		[Space]

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



		[Header(Post Effect Specific Setup)]
			_PEGrabScale("Refraction Bump Map Scale", Float) = 1
		_PEGrabScaleProp("Second Bump Map Proportional Scale", Float) = 1
			_PEGrabAmt("Refraction Amplitude", Float) = 1

		//_CausticScaleMax("_CausticScaleMax",Float) = 1

		[Header(Depth Gradient and Mask Setup)]
	[Space]
	[Space]
	[Header(Depth Color Gradient)]

	

	_DistancePos("Depth Color Offset", Float) = 0
		_DistanceFalloff("Depth Color Falloff", Float) = -17.5
		_DistancePower("Depth Color Power", Float) = 0.4
		[Toggle(_DEBUG_COLOR_DEPTH)]_DebugColorDepth("DEBUG : Visualize Depth Color Mask", Float) = 0

		[Space]
	[Space]

	[Space]
	[Header(Depth Caustic Top Mask)]

	_CausticOffset("Caustic Top Offset", Float) = 0
		_CausticFalloff("Caustic Top FallOff", Float) = -6
		[Toggle(_DEBUG_CAUSTIC_DEPTH)]_DebugCausticDepth("DEBUG : Visualize Caustic Top Mask", Float) = 0
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


			[Header(Procedural Waves Setup)]
		[Toggle(_USE_GRESTNER_WAVE)]_UseGrestnerWaves("Use Grestner Procedural Waves (variant)", Float) = 0

			_GSteepness("Wave Steepness", Vector) = (0, 0, 0, 0)
			_GAmplitude("Wave Amplitude", Vector) = (0, 0, 0, 0)
			_GWavelength("Wavelength", Vector) = (0, 0, 0, 0)
			_GPhase("Wave Phase", Vector) = (0, 0, 0, 0)
			_GNormal("Wave Normal Multiplier", Float) = 1.0
			_GDirection("Wave Direction", Vector) = (0, 0, 0, 0)
			_GDirection2("Wave Direction", Vector) = (0, 0, 0, 0)

			[Header(Dynamic Waves Setup)]

		_DynamicHeight("D", 2D) = "grey" {}
		[HideInInspector]_DynamicBump("B", 2D) = "bump" {}

		[Toggle(_USE_DYNAMIC_WAVES)]_UseDynamicWaves("Use Dynamic Waves(variant)", Float) = 0
			_Displacement("_Displacement", Float) = 1
			_NormalPower("Displaced Normal Power", Float) = 1

			[Header(Tesselation)]
		_Tesselation("_Tesselation", Range(0, 50)) = 1
			_TessDistMin("_TessDistMin", Float) = 0
			_TessDistMax("_TessDistMax", Float) = 5
			_TessDistPow("_TessDistPow", Float) = 1

			_MinTess("_MinTess", Range(1, 39)) = 1
			_MaxTess("_MaxTess", Range(2, 100)) = 20


			_WaterPosition("_WaterPosition", Vector) = (0, 0, 0, 1)
			_SimulationPosition("_SimulationPosition", Vector) = (0, 0, 0, 1)


		[HideInInspector][HDR] _ReflectionTex("", 2D) = "white" {}

	//[HideInInspector][HDR] _DirShadowMap("", 2D) = "black" {}



	}
		SubShader{

		//GrabPass{}
		
		Pass{


		//Name "FORWARD"
		Cull Off ZWrite Off ZTest Always



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
#pragma shader_feature _DRAW_SUN_DISC
#pragma shader_feature _BLUR_REFRACTION
#pragma shader_feature _REFRACT_ALPHA_MASK
#pragma shader_feature _RECEIVE_SHADOWS
#pragma shader_feature _RECEIVE_VOLUMETRIC_SHADOWS
#pragma shader_feature _USE_FOG_EXPONENTIAL
#pragma shader_feature _MARCH__128 _MARCH__64 _MARCH__32 _MARCH__16
#pragma shader_feature _USE_GRESTNER_WAVE

			


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
			

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityDeferredLibrary.cginc"
#include "Water.cginc"




			CBUFFER_START(WaterParam) //Change every frame
			float4 _CameraDepthTexture_ST;
#ifndef _USE_REFLECTION_PROBE
		uniform sampler2D_float _ReflectionTex;
#endif

		float4 _GrabTexture_TexelSize;
		sampler2D _GrabBlurTexture;
		sampler2D _MainTex;

		//Matrix we get from a script
		float4x4 clipToWorld;
		CBUFFER_END // WaterParam

			CBUFFER_START(WaterParamRare) //Never change during runtime
			sampler2D _BumpMap;



		float4 _BumpMap_ST;
		float4 _Color;

		float4 _Speed;
		float4 _SunColor;
		float4 _SpecularColor;

#ifdef _DRAW_SUN_DISC
		float _SunDiscScale, _SunDiscPow;

#endif


#if _BLUR_REFRACTION || _DEBUG_BLUR_DEPTH
		float _BlurFalloff, _BlurOffset, _BlurPower;
#endif
		float3 _WaterPosition;
		float _GlobalBrightness;
		float _ReflectionDensity;
		sampler2D _DynamicHeight;
		float _Displacement;
		//
		float _GrabPropSpeed;
		float _PEGrabScaleProp, _PEGrabScale;
		float _RefractionBias;
		float _BlurDist;
		float4 _SimulationPosition;
		float _WaveTime;
		float _GlobalSpeed;
		float _WaterOpacity;

		float _GrabBoost;
		float _PEGrabAmt;

		float _DistancePos, _DistanceFalloff, _DistancePower;
		CBUFFER_END // WaterParamRare




	struct appdata {
		float4 color : COLOR0;
		float4 vertex : POSITION;
		float4 tangent : TANGENT;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
		//float4 ray : TEXCOORD1;

	};

	struct v2f {

		float4 screenUV : ATTR0;
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;
		float2 pack0 : TEXCOORD0;
		float3 wPos : TEXCOORD1;
		float3 interpolatedRay : TEXCOORD2;

	};



	// Vertex shader
	v2f vert(appdata v) {

		v2f o;
		UNITY_INITIALIZE_OUTPUT(v2f,o);

		float3 worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
		o.pos = mul(UNITY_MATRIX_VP, float4(worldPos,1));
		o.screenUV = ComputeScreenPos(o.pos);

		//Transform uv using the Unity Inspector
		o.pack0.xy = v.texcoord;

		fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
		o.wPos = worldPos;
		float4 clip = float4(o.pos.xy, 0.0, 1.0);
		o.interpolatedRay = mul(clipToWorld, clip) - _WorldSpaceCameraPos;


		o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1));


		fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
		fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;

		//Reconstruct binormal
		fixed3 worldBinormal = normalize(cross(worldNormal, worldTangent) * tangentSign);

		//We pack tangent binormal normal and world pos in three float4
		//Just like unity does in surface shader
		o.color = v.color;


		return o;
	}

	// Fragment shader
	fixed4 frag(v2f i) : SV_Target{


		//------------------------------------------//
		//------------------SHADER------------------//
		//------------------------------------------//


		fixed4 o;

	//redistribute the values packed earlier
	//float3 worldTan = float3(i.tSpace0.x, i.tSpace1.x, i.tSpace2.x);
	//float3 worldBin = float3(i.tSpace0.y, i.tSpace1.y, i.tSpace2.y);
	//float3 worldNor = float3(i.tSpace0.z, i.tSpace1.z, i.tSpace2.z);
	//float3 worldPos = i.wPos;// float3(i.tSpace0.w, i.tSpace1.w, i.tSpace2.w);

	float time = _Time.x;

	//Premultiplied speed and setup uvPan
	//_Speed is a float4 xy is for the first map and zw for the second
	_Speed = _Speed *  _GlobalSpeed;



	float2 grabBumpUV = i.pack0 *_PEGrabScale;
	float4 grabT = time * _Speed * _GrabPropSpeed;


	fixed2 grabBump = UnpackNormal(tex2D(_BumpMap, fmod(float2(grabBumpUV + grabT.xy), 50.0f))).xy;
	fixed2 grabBumpSec = UnpackNormal(tex2D(_BumpMap, fmod(float2(grabBumpUV + grabT.zw)*_PEGrabScaleProp, 50.0f))).xy;

	fixed2 grabDoubleBump = grabBump.rg + grabBumpSec.rg;


	
	//Using the normal map we compute the new UV to sample the depth and the grabPass
	float2 uv = i.pack0;

	float2 grabOffset = grabDoubleBump * _PEGrabAmt;

	float2 refrUV = uv + grabOffset;
	float2 refrBiasUV = uv + grabOffset*(1 + _RefractionBias);

	//If we need the blurred grabPass 
#ifdef _BLUR_REFRACTION

	half3 grabBlur = tex2D(_GrabBlurTexture, refrUV);

#endif		

	//We sample the GrabPass two times
	//One with the distorted screen uv computed earlier 
	//and one with the normal screen uv
	half3 grab = tex2D(_MainTex, refrUV);
	half3 grab2 = tex2D(_MainTex, uv);


	//We sample the depth three times 
	// Sample the depth with the screen uv distorted by the refraction
	float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, refrUV);
	// Sample the depth with the screen uv  more distorted by the refraction using a bias
	//float depthBias = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, refrBiasUV);
	// Sample the depth with the normal screen uv
	float depth2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
	//We check the distance of the more distorted depth buffer
	//float depthRefract = LinearEyeDepth(depthBias);
	float depthEye = LinearEyeDepth(depth);
	float depthRefrEye = LinearEyeDepth(depth2);



	//If the distoted depth is closer than the water we don't want it to be in the refraction
	//So we fallback to the undistorted version of the depth buffer and grabpass


	float3 worldPos = DepthToWorldPos_ImageEffect(uv, 1, i.interpolatedRay);



	float2 simUV = float2(InverseLerp(_SimulationPosition.x - 0.5f * _SimulationPosition.w, _SimulationPosition.x + 0.5f * _SimulationPosition.w, worldPos.x), InverseLerp(_SimulationPosition.z - 0.5f * _SimulationPosition.w, _SimulationPosition.z + 0.5f * _SimulationPosition.w, worldPos.z));
	float4 dispPos = float4(worldPos,1.0f);
		
		DynamicDisplace(_DynamicHeight, simUV, float3(0,1,0), -_Displacement, dispPos);
/*
#ifdef _USE_GRESTNER_WAVE
	if (!IsUnderGerstnerWave(dispPos, _WaterPosition.y, _WaveTime))
		return float4(grab2, 1);
#else
	if (worldPos.y > _WaterPosition.y)
		return float4(grab2, 1);
#endif*/

	//Compute world position using the depth buffer

	//float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.xy);
	float3 depthWP = DepthToWorldPos_ImageEffect(uv, depth, i.interpolatedRay);
	float3 depthWP2 = DepthToWorldPos_ImageEffect(uv, depth2, i.interpolatedRay);

	//if (depthWP.y > 0)
	//{
	//	grab = grab2;
	//	depth = depth2;
	//	depthEye = depthRefrEye;
	//	depthWP = depthWP2;
	//}
	//return float4(depthWP, 1);
	//return float4(depthWP, 1);


	//Compute the view direction
	float3 V = normalize(worldPos - depthWP);


	
//return float4(waterTopDepth.xxx/5, 1);








#ifdef _USE_GRESTNER_WAVE

	_WaterPosition += (_GAmplitude.x + _GAmplitude.y + _GAmplitude.z + _GAmplitude.w)*0.25f;


#endif

		float waterTopDepth = ComputeWaterTop(-V, worldPos, _WaterPosition.y);
		waterTopDepth = min(waterTopDepth, depthEye);


		depthEye = waterTopDepth;

		
	float wT = depthEye;
	//Setup gradient and mask for later blending
	float depthTest;
	float blurTest = 0;
#ifdef _USE_FOG_EXPONENTIAL
	depthTest = 1 / pow(exp(wT*_Density),2);
	depthTest = 1 - depthTest;
#else
	depthTest = pow(smoothstep(_DistancePos , _DistancePos +  _DistanceFalloff, wT), _DistancePower);
#endif

#if _BLUR_REFRACTION || _DEBUG_BLUR_DEPTH
	blurTest = pow(InverseLerp(_BlurOffset, _BlurOffset + _BlurFalloff, wT),_BlurPower);
#endif

	
	//DEBUG

#ifdef _DEBUG_COLOR_DEPTH
	return float4(depthTest.xxx, 1);
#endif

#ifdef _DEBUG_BLUR_DEPTH
	return float4(blurTest.xxx, 1);
#endif
	//END DEBUG





	/// ------- CAUSTIC --------- ///


#if _DRAW_CAUSTIC || _DEBUG_CAUSTICBOT_DEPTH || _DEBUG_CAUSTIC_DEPTH || _DEBUG_DEFORM_DEPTH || _DEBUG_CAUSTIC_RG || _DEBUG_CAUSTIC_SCALE_DEPTH

	float3 causticFinal = DrawCaustic(depthWP, refrUV, _WaterPosition.y, unity_ObjectToWorld, blurTest, grab, time);


#if _DEBUG_CAUSTICBOT_DEPTH || _DEBUG_CAUSTIC_DEPTH || _DEBUG_DEFORM_DEPTH || _DEBUG_CAUSTIC_RG || _DEBUG_CAUSTIC_SCALE_DEPTH
	return float4(causticFinal, 1);
#endif

#ifdef _RECEIVE_SHADOWS
	float causticAtten = GetSunShadowsAttenuation_PCF3x3(depthWP2.xyz, depthRefrEye, 0);
	causticFinal *= causticAtten;
#endif

	grab += causticFinal * grab;
#endif


	

	
	

	
	
	

	
	
	







	//We separate here two cases, one where we want the grabPass seven in the depth
	//another where we just want the color ( picture a deep well )


	float3 shadingFinal =  _LightColor0;
	float3 shadinGrabFinal = _LightColor0 ;


	float atten;

	//shadingFinal = DrawShadow(worldPos, -V, grabBump, wT, _Density, _LightColor0, atten);
	atten = tex2D(_VolumetricShadowTex, uv);
#ifdef _BLUR_REFRACTION
	grab = lerp(grab, grabBlur, blurTest);
#endif

	float3 grabTransp = lerp(grab, grab*_Color, depthTest);
	float3 grabOpaque = lerp(grab, _Color+_LightColor0 * atten, depthTest);

	float3 grabFinal = lerp(grabTransp, grabOpaque, _WaterOpacity) * _GrabBoost;








	//We add the lighting
	fixed3 finalEmi = grabFinal;

	//We draw the caustic computed earlier


	//Output
	o.rgb = finalEmi.xyz * _GlobalBrightness;
	o.a = 1;
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
