Shader "Unlit/water"
{
    Properties
    {
        _MainColor ("Water Color", Color) = (0, 0.5, 1, 1)
        _WaveColor ("Wave Color", Color) = (0.2, 0.8, 1, 1)
        _Speed ("Wave Speed", Float) = 0.5
        _WaveScale ("Wave Scale", Float) = 5
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)

                float4 _MainColor;
                float4 _WaveColor;
                float _Speed;
                float _WaveScale;

            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Get the UV coordinates
                float2 uv = IN.uv;

                // Move the wave over time
                uv.x += _Time.y * _Speed;

                // Create the wave
                float wave = sin(uv.x * _WaveScale);

                // Convert the wave from -1 to 1 into 0 to 1
                wave = wave * 0.5 + 0.5;

                // Blend the two water colors
                half4 water = lerp(_MainColor, _WaveColor, wave);

                return water;
            }

            ENDHLSL
        }
    }

    FallBack Off
}