﻿Shader "Unity Shaders Book/Chapter 7/Ramp Texture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_RampTex("Ramp Tex",2D) = "white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}	
	
	Subshader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			float4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			float4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f
			{
			
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float halfLambert = 0.5+dot(worldNormal,worldLightDir)*0.5;
				float3 diffuseColor = tex2D(_RampTex,float2(halfLambert,halfLambert)).rgb*_Color.rgb;
				float3 diffuse = diffuseColor*_LightColor0.rgb;
				
				 float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				 float3 halfDir = normalize(viewDir + worldLightDir);
				 float3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,worldNormal)),_Gloss) ;
				 return fixed4(diffuse+specular+ambient,1.0);
			}
			ENDCG
		}
	}
}