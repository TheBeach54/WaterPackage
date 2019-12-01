
#ifdef _RECEIVE_SHADOWS
#include "Shadows.cginc"
#endif
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityDeferredLibrary.cginc"
#include "WaterUtils.cginc"
sampler2D _CameraGBufferTexture2, _VolumetricShadowTex;

float _DispIntensity;
float _ShadingDensity, _ShadowMaxDepth;
float _SunShading, _AmbientShading, _ShadowOpacity;
float _VolumetricOffset, _VolumetricFalloff, _VolumetricPower, _SunVolumetricShading;
float _Density;

float _CausticProjScaleMin, _CausticProjScaleMax, _CausticProjDeformScale;
float _CausticProjDeformIntensityMax, _CausticProjDeformIntensityMin;


float _CausticScaleMin, _CausticScaleMax, _CausticDeformScale;
float _CausticDeformIntensityMax, _CausticDeformIntensityMin;


sampler2D _CausticMap;
float4 _CausticSpeed, _CausticColor;


float _CausticFalloff, _CausticOffset, _CausticDeformFalloff, _CausticDeformOffset, _CausticScaleFalloff;
float _CausticBotFalloff, _CausticBotOffset;
float _CausticShadowBias;
float _CausticScaleDistance;
float _CausticBrightness;
//	uniform sampler2D_float _CameraDepthTexture;

float _GSteepness;
float4 _GAmplitude, _GWavelength, _GPhase;

float4 _GWaves[6]; //x: amp y: wavelength z: phase w:angle
float4 _GWavesPos[6];

float4 _GDirection, _GDirection2;
float _GNormal;

inline bool IsUnderGerstnerWave(float3 wPos, float waterLevel, float time)
{
	float3 inWP = wPos.xyz;
	wPos = wPos.zxy;


	const int count = 6;
	float factor = 1 / (float)count;

	float Xp = 0;
	float Yp = 0;
	float Zp = 0;

	float A, w, p, Q;
	float2 D;

	for (int i = 0; i <count; i++)
	{
		A = _GWaves[i].x;
		w = _GWaves[i].y;
		p = _GWaves[i].z;

		if (_GWaves[i].w > 450.0f)
		{
			D = GetCircularDirection(inWP, _GWavesPos[i].xy);


		}
		else
		{

		D = float2(cos(_GWaves[i].w), sin(_GWaves[i].w));
		}



		float3 offWp;
		offWp.z = inWP.y;
		offWp.xy = inWP.zx - _GWavesPos[i].xy;


		Q = saturate(_GSteepness) / (w * A);



		Xp += Q * A * D.x * cos(dot(w * D, float2(wPos.x, wPos.y)) + p * time);
		Yp += Q * A * D.y * cos(dot(w * D, float2(wPos.x, wPos.y)) + p * time);
		Zp += A * sin(dot(w * D, float2(wPos.x, wPos.y)) + p * time);
	}

	float wPX = wPos.x + Xp *factor;
	float wPY = wPos.y + Yp *factor;
	float wPZ = waterLevel + Zp *factor;

	float3 wP = float3(wPX, wPY, wPZ);


	return wP.z > wPos.z;

}

inline void GerstnerWave(inout float3 wPos, inout float3 wNormal, float time)
{
	float3 inWP = wPos.xyz;
	wPos = wPos.zxy;

	const int count = 6;

	float factor = 1 / (float)count;

	float Xp = 0;
	float Yp = 0;
	float Zp = 0;

	float A, w, p, Q;
	float2 D;

	for (int i = 0; i < count; i++)
	{
		
		A = _GWaves[i].x;
		w = _GWaves[i].y;
		p = _GWaves[i].z;
		if (_GWaves[i].w > 450.0f)
		{
			
			D = GetCircularDirection(inWP, _GWavesPos[i].xy);


		}
		else
		{

			D = float2(cos(_GWaves[i].w), sin(_GWaves[i].w));
		}



		Q = saturate(_GSteepness) / (w * A);

		float3 offWp;
		offWp.z = inWP.y;
		offWp.xy = inWP.zx - _GWavesPos[i].xy;

		Xp += Q * A * D.x * cos(dot(w * D, float2(offWp.x,offWp.y)) + p * time);
		Yp += Q * A * D.y * cos(dot(w * D, float2(offWp.x,offWp.y)) + p * time);
		Zp += A * sin(dot(w * D, float2(offWp.x, offWp.y)) + p * time);
	}

	float wPX = wPos.x + Xp *factor;
	float wPY = wPos.y + Yp *factor;
	float wPZ = wPos.z + Zp *factor;

	float3 wP = float3(wPX, wPY, wPZ);

	float Xn = 0;
	float Yn = 0;
	float Zn = 0;

	float WA, S, C;

	for (int j = 0; j < count; j++)

	{
		A = _GWaves[j].x;
		w = _GWaves[j].y;
		p = _GWaves[j].z;
		if (_GWaves[j].w > 450.0f)
		{
			D = GetCircularDirection(inWP, _GWavesPos[j].xy);

			
		}
		else
		{

			D = float2(cos(_GWaves[j].w), sin(_GWaves[j].w));
		}

		float3 offWp;
		offWp.z = wP.z;
		offWp.xy = wP.xy - _GWavesPos[j].xy;


		Q = saturate(_GSteepness) / (w * A);

		WA = w * A;
		S = sin(w * dot(D, offWp) + p * time);
		C = cos(w * dot(D, offWp) + p * time);

		Xn += D.x * WA * C;
		Yn += D.y * WA * C;
		Zn += Q * WA * S;


	}



	float2 Nxy = float2(-(Xn *factor), -(Yn *factor));
	//float Ny = -(D.y * WA * C);
	float Nz = 1 - (Zn *factor);


	wPos = float3(wPY, wPZ, wPX);
	wNormal = normalize(float3(Nxy.y, Nz, Nxy.x));

}

half _wavAmp, _wavFreq, _wavSpeed, _wavNorm;
void WaveDisplace(float angle, inout float4 pos, inout half3 normal)
{
	angle = (angle + _Time.x * _wavSpeed) * _wavFreq;
	half sinAngle, cosAngle;
	sincos(angle, sinAngle, cosAngle);
	half waveDisplace = sinAngle *0.5f * _wavAmp;
	pos += half4 (normal, 0) * waveDisplace;
	half ddx = cosAngle * _wavAmp;
	normal.x += ddx * _wavNorm;
}


#ifdef _PROJ_CAUSTIC
inline float DrawCausticOnProjection(float3 depthWP, float2 refrUV, float causticDeformTest, float causticScaleTest, float blurTest, float time)
{
	float caustic = 0;

	float3 origin = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);

	// We fetch the normal buffer if needed
#ifdef _DEFERRED_RENDERING
	float4 normalBuffer = tex2D(_CameraGBufferTexture2, refrUV) * 2 - 1;
#endif
	float causMipOff = 0;
#ifdef _BLUR_REFRACTION
	causMipOff = pow(blurTest, 1.5) * 3;
#endif


	float4 lightCookie = mul(unity_WorldToLight, depthWP - origin);
	float lightScale = lerp(_CausticProjScaleMin, _CausticProjScaleMax, causticScaleTest);
	float2 lightUV = lightCookie.xy / (lightScale);

	//fetch caustic deform map
	float2 causticDeform = tex2D(_CausticMap, lightCookie.xy * _CausticProjDeformScale + time * _CausticSpeed.zw).rg * 2 - 1;
	causticDeform += tex2D(_CausticMap, (lightCookie.xy * 0.7) * _CausticProjDeformScale + time * _CausticSpeed.wz).rg * 2 - 1;
	//END DEBUG

#ifdef _DEBUG_CAUSTIC_RG
	return float4((causticDeform* causticDeformTest)*0.5 + 0.5, 0, 1);
#endif
	causticDeform *= lerp(_CausticProjDeformIntensityMin, _CausticProjDeformIntensityMax, causticDeformTest);


	float2 causticUV = (lightUV + causticDeform) + time * _CausticSpeed.xy*0.2;
	float causticProj = tex2Dlod(_CausticMap, float4(causticUV, 0, causMipOff)).z;
	//return float4(causticProj.xxx, 1);
	caustic = causticProj;

	return caustic;
}
#else
inline float DrawCausticOnWorldPos(float3 depthWP, float2 refrUV, float3 normalBuffer, float causticDeformTest, float blurTest, float time)
{
	float caustic = 0;


	float3 origin = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);

	// We fetch the normal buffer if needed

	float causMipOff = 0;
#ifdef _BLUR_REFRACTION
	causMipOff = pow(blurTest, 1.5) * 3;
#endif


	float uvCausticFactor = _CausticScaleMin;

	//DEBUG
	float3 causticWP = depthWP - origin;
	float2 causticDeform = tex2D(_CausticMap, (depthWP.xz) / _CausticDeformScale + time * _CausticSpeed.zw).rg * 2 - 1;
	causticDeform += tex2D(_CausticMap, (depthWP.xz * 0.7) / _CausticDeformScale + time * _CausticSpeed.wz).rg * 2 - 1;
#ifdef _DEBUG_CAUSTIC_RG
	return float4((causticDeform* causticDeformTest)*0.5 + 0.5, 0, 1);
#endif
	causticDeform *= lerp(_CausticDeformIntensityMin, _CausticDeformIntensityMax, causticDeformTest);



	float causticMaskY = tex2Dlod(_CausticMap, float4((causticWP.xz + causticDeform) / uvCausticFactor + time * _CausticSpeed.xy, float2(0, causMipOff))).b;

	caustic = causticMaskY;

#ifdef _DEFERRED_RENDERING
	float causticMaskX = tex2Dlod(_CausticMap, float4((causticWP.yz + causticDeform) / uvCausticFactor + time * _CausticSpeed.xy, float2(0, causMipOff))).b;
	float causticMaskZ = tex2Dlod(_CausticMap, float4((causticWP.yx + causticDeform) / uvCausticFactor + time * _CausticSpeed.xy, float2(0, causMipOff))).b;

	float3 causticMask = float3(causticMaskX, causticMaskY, causticMaskZ);

	float3 normalBufAbs = abs(pow(normalBuffer.xyz, 4));
	float3 blendedCausticMask = normalBufAbs * causticMask;
	caustic = blendedCausticMask.x + blendedCausticMask.y + blendedCausticMask.z;

#endif

	return caustic;



}
#endif

inline half3 DrawCaustic(float3 depthWP, float2 refrUV, float wPosY, float4x4 unity_ObjectToWorld, float blurTest, half3 grab, float time)
{
	float causticAtten = 1;

	float caustic = 0;

	float3 normalBuffer = 0;

	float causticTest = InverseLerp(_CausticOffset + wPosY, _CausticOffset + wPosY + _CausticFalloff, depthWP.y);
	float causticBotTest = InverseLerp(_CausticBotOffset + wPosY, _CausticBotOffset + wPosY + _CausticBotFalloff, depthWP.y);
	float causticDeformTest = InverseLerp(_CausticDeformOffset + wPosY, _CausticDeformOffset + wPosY + _CausticDeformFalloff, depthWP.y);
	float causticScaleTest = InverseLerp(_CausticScaleDistance + wPosY, _CausticScaleDistance + wPosY + _CausticScaleFalloff, depthWP.y);

#if _DEBUG_CAUSTICBOT_DEPTH && _DEBUG_CAUSTIC_DEPTH 
	return float4(causticBotTest.xxx * causticTest, 1);
#endif
#ifdef _DEBUG_CAUSTIC_SCALE_DEPTH
	return float4(causticScaleTest.xxx, 1);
#endif
#ifdef _DEBUG_CAUSTIC_DEPTH
	return float4(causticTest.xxx, 1);
#endif
#ifdef _DEBUG_CAUSTICBOT_DEPTH
	return float4(causticBotTest.xxx, 1);
#endif
#ifdef _DEBUG_DEFORM_DEPTH
	return float4(causticDeformTest.xxx, 1);
#endif


#ifdef _DEBUG_CAUSTIC_RG

#ifdef _PROJ_CAUSTIC
	float3 origin = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
	//fetch caustic deform map
	float4 lightCookie = mul(unity_WorldToLight, depthWP - origin);
	float lightScale = lerp(_CausticProjScaleMin, _CausticProjScaleMax, causticScaleTest);
	float2 lightUV = lightCookie.xy / (lightScale);

	float2 causticDeform = tex2D(_CausticMap, lightCookie.xy * _CausticProjDeformScale + time * _CausticSpeed.zw).rg * 2 - 1;
	causticDeform += tex2D(_CausticMap, (lightCookie.xy * 0.7) * _CausticProjDeformScale + time * _CausticSpeed.wz).rg * 2 - 1;
	//END DEBUG

#else
	float2 causticDeform = tex2D(_CausticMap, (depthWP.xz) / _CausticDeformScale + time * _CausticSpeed.zw).rg * 2 - 1;
	causticDeform += tex2D(_CausticMap, (depthWP.xz * 0.7) / _CausticDeformScale + time * _CausticSpeed.wz).rg * 2 - 1;

#endif

	return float3((causticDeform* causticDeformTest)*0.5 + 0.5, 0);

#endif

#ifdef _DEFERRED_RENDERING
	normalBuffer = tex2D(_CameraGBufferTexture2, refrUV) * 2 - 1;
#endif


#ifdef _PROJ_CAUSTIC

	caustic = DrawCausticOnProjection(depthWP, refrUV, causticDeformTest, causticScaleTest, blurTest, time);
#else
	caustic = DrawCausticOnWorldPos(depthWP, refrUV, normalBuffer, causticDeformTest, blurTest, time);
#endif


	caustic *= causticTest * causticBotTest;

	float NdotLdepth = 1;
#ifdef _DEFERRED_RENDERING
	NdotLdepth = smoothstep(0, 0.1, dot(normalBuffer.xyz, _WorldSpaceLightPos0));
#endif

	float3 causticFinal = caustic * NdotLdepth * _CausticBrightness * _LightColor0  * _CausticColor;





	return causticFinal;
}


//SHADOWS


#ifdef _RECEIVE_SHADOWS
inline float3 DrawVolumetricShadows(float3 worldPos, float3 viewDir, float2 bump, float wT, float density, float3 lightColor, inout float sunAtten)
{

	float3 shadingFinal = 0;
#ifdef _MARCH__128
	const int marchStep = 128;

#elif _MARCH__64
	const int marchStep = 64;

#elif _MARCH__32
	const int marchStep = 32;

#elif _MARCH__16
	const int marchStep = 16;

#else
	const int marchStep = 0;
#endif

	float waterThickness = min(wT, _ShadowMaxDepth);
	float stepThick = (waterThickness / marchStep);// waterThickness / (float)marchStep;
	float marchFactor = stepThick / 32;
	//float maxStep = marchStep / stepThick;

	float volumeAccum;
	float3 marchWP;
	float marchWT;
	float marchZ;
	float marchAtten;
	float fogMask;
	float marchStopper;
	float3 VV = viewDir;
	float depthMarchTest;
	float fullBrightAccum = 0;
	float volumeAccumTemp;



	for (int j = 0; j < marchStep; j++)
	{


		marchWT = (stepThick * (float)j);

		//if (marchWT > wT)
		//	break;

		marchZ = marchWT;
		marchWP = worldPos + VV * marchWT + float3(bump.xy * _DispIntensity, 0);


		fogMask = 1 / pow(exp(marchWT*density), 2);


		marchAtten = lerp(1.0f, GetSunShadowsAttenuation_PCF3x3(marchWP, marchZ), _ShadowOpacity);
		volumeAccumTemp = marchAtten * (marchFactor)*fogMask;
		volumeAccum += volumeAccumTemp;



	}
	volumeAccum = saturate(volumeAccum);
	shadingFinal = volumeAccum * (lightColor)*_SunVolumetricShading + unity_AmbientSky * _AmbientShading * 0.5f;
	sunAtten = GetSunShadowsAttenuation_PCF3x3(worldPos, wT, 0);

#ifdef _DEBUG_VOLUMETRIC_SHADOW

	return float4(volumeAccum.xxx*_SunVolumetricShading * _LightColor0, 1);
#endif
	return shadingFinal;
}

inline float3 DrawClassicShadows(float3 worldPos, float2 bump, float wT, float3 lightColor, inout float sunAtten)
{

	float atten = GetSunShadowsAttenuation_PCF5x5(worldPos + float3(0, 1, 0)*normalize(float3(bump, 1)).x*_DispIntensity, wT, 0);
	float depthShadowTest = pow(InverseLerp(_VolumetricOffset + worldPos.y, _VolumetricOffset + worldPos.y + _VolumetricFalloff, worldPos.y), _VolumetricPower);

	atten = lerp(1, atten, _ShadowOpacity);
	sunAtten = atten;
	//return float4(volumeAccum.xxx, 1);
	lightColor *= atten;
	lightColor *= _SunShading;
	lightColor += unity_AmbientSky * _AmbientShading * 0.5f;
	return lightColor;

}
#endif

inline float3 DrawShadow(float3 worldPos, float3 viewDir, float2 bump, float wT, float density, float3 lightColor, out float sunAtten)
{
	float3 shadingFinal;
	sunAtten = 1;
#ifdef _RECEIVE_SHADOWS
#ifdef _RECEIVE_VOLUMETRIC_SHADOWS
	shadingFinal = DrawVolumetricShadows(worldPos, viewDir, bump, wT, density, lightColor, sunAtten);
#else
	shadingFinal = DrawClassicShadows(worldPos, bump, wT, lightColor, sunAtten);

#endif


#else
	shadingFinal = lightColor * _SunShading;
	shadingFinal += unity_AmbientSky * _AmbientShading * 0.5f;
#endif

	return shadingFinal;
}
