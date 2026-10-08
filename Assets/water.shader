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
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;
            float4 _WaveColor;
            float _Speed;
            float _WaveScale;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Move the UV coordinates over time
                float2 uv = i.uv;
                uv.x += _Time.y * _Speed;

                // Create a simple wave pattern
                float wave = sin(uv.x * _WaveScale);

                // Convert the wave into a 0-1 value
                wave = wave * 0.5 + 0.5;

                // Blend between the two water colors
                fixed4 water = lerp(_MainColor, _WaveColor, wave);

                return water;
            }

            ENDCG
        }
    }
}