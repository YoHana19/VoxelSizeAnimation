Shader "Geometry/VoxelSizeAnimation"
{
	Properties
	{
		[Header(Shared)]
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)

		[Header(Unity Chan)]
		_ShadowColor("Shadow Color", Color) = (0.8, 0.8, 1, 1)
		_FalloffSampler("Falloff Control", 2D) = "white" {}
		_RimLightSampler("RimLight Control", 2D) = "white" {}

		[Header(Voxel Animation)]
		[HDR] _EmissionColor("Emission Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Size("Size", Range(0.0, 2.0)) = 0.2
		_Distance("Distance", Range(-1.0, 1.0)) = 0.0
		_Density("Density", Range(0.0, 1.0)) = 0.1
		_Speed("Speed", Range(0.0, 10.0)) = 1.0
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma target 4.0

			#include "UnityCG.cginc"
			#include "ShaderTools.cginc"
			#include "VoxelSizeAnimation.cginc"
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull Back
			ZTest LEqual
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			float4 _EffectVector;
			float4 _EmissionColor;

			#include "UnityChan/CharaSkin.cg"
			ENDCG

			/*
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _EffectVector;
			float4 _EmissionColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 wpos : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float param = dot(_EffectVector.xyz, i.wpos) - _EffectVector.w;
				param = clamp(-1, 0, 1 - param);
				if (param == 0) discard;
				fixed4 col = tex2D(_MainTex, i.uv);
				float bparam = smoothstep(0, 0.1, param * -1);
				col = col * bparam + _EmissionColor * (1 - bparam);
				return col;
			}
			ENDCG
			*/
		}
	}
}
