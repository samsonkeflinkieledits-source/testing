{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Base Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;  // Object space position
                float3 normalOS : NORMAL;      // Object space normal
                float2 uv : TEXCOORD0;         // Texture UV
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Homogeneous clip-space position
                float3 normalWS : TEXCOORD1;      // World space normal
                float2 uv : TEXCOORD0;             // UV for texturing
            };

            // Declare the base texture and sampler
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)

                float4 _BaseColor;   // Base color

            CBUFFER_END

            // Vertex Shader
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Transform object position to clip space
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Transform the normal from object space to world space
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                // Pass the UV to the fragment shader
                OUT.uv = IN.uv;

                return OUT;
            }

            // Fragment Shader
            half4 frag(Varyings IN) : SV_Target
            {
                // Sample the base texture
                half4 texColor = SAMPLE_TEXTURE2D(
                    _MainTex,
                    sampler_MainTex,
                    IN.uv
                );

                // Get the main directional light
                Light mainLight = GetMainLight();

                // Get the light direction
                half3 lightDir = normalize(mainLight.direction);

                // Normalize the world space normal
                half3 normalWS = normalize(IN.normalWS);

                // Calculate Lambert diffuse lighting
                half NdotL = saturate(dot(normalWS, lightDir));

                // Calculate ambient lighting
                half3 ambientSH = SampleSH(normalWS);

                // Combine texture, color and direct light
                half3 diffuse =
                    texColor.rgb *
                    _BaseColor.rgb *
                    NdotL *
                    mainLight.color.rgb;

                // Combine direct light and ambient light
                half3 finalColor =
                    diffuse +
                    ambientSH *
                    texColor.rgb *
                    _BaseColor.rgb;

                // Return the final color
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }

    FallBack Off
}