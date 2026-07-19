Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader =
{
	Samplers =
	{
		DiffuseTexture =
		{
			Index = 0
			MipMapLodBias = -0.4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
	}
}

ConstantBuffer( 1, 32 )
{
	float4 Transp_OffsetX;
};

VertexStruct VS_INPUT
{
	float3 vPosition : POSITION;
	float2 vTexCoord : TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
	float4 vPosition : PDX_POSITION;
	float3 vPrepos   : TEXCOORD0;
	float2 vTexCoord : TEXCOORD1;
};

VertexShader =
{
	MainCode VertexShader
	[[
		VS_OUTPUT main( const VS_INPUT v )
		{
			VS_OUTPUT Out;

			float4 vPos = float4( v.vPosition, 1.0f );
			vPos.x += Transp_OffsetX.y;
			float4 vDistortedPos = vPos - float4( vCamLookAtDir * 0.5f, 0.0f );

			vPos = mul( ViewProjectionMatrix, vPos );

			float vNewZ = dot( vDistortedPos, float4(
				GetMatrixData( ViewProjectionMatrix, 2, 0 ),
				GetMatrixData( ViewProjectionMatrix, 2, 1 ),
				GetMatrixData( ViewProjectionMatrix, 2, 2 ),
				GetMatrixData( ViewProjectionMatrix, 2, 3 ) ) );

			Out.vPosition = float4( vPos.xy, vNewZ, vPos.w );
			Out.vPrepos = v.vPosition.xyz;
			Out.vTexCoord = v.vTexCoord;

			return Out;
		}
	]]
}

PixelShader =
{
	MainCode PixelShader
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			float4 vSample = tex2D( DiffuseTexture, v.vTexCoord );

			// fwidth keeps the halo close to one screen pixel at every map zoom.
			float2 vHaloStep = max( fwidth( v.vTexCoord ) * 1.15f, float2( 0.0001f, 0.0001f ) );
			float vNearbyAlpha = 0.0f;
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + float2(  vHaloStep.x, 0.0f ) ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + float2( -vHaloStep.x, 0.0f ) ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + float2( 0.0f,  vHaloStep.y ) ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + float2( 0.0f, -vHaloStep.y ) ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + vHaloStep ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord - vHaloStep ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + float2( vHaloStep.x, -vHaloStep.y ) ).a );
			vNearbyAlpha = max( vNearbyAlpha, tex2D( DiffuseTexture, v.vTexCoord + float2( -vHaloStep.x, vHaloStep.y ) ).a );

			float vGlowAlpha = saturate( vNearbyAlpha - vSample.a ) * 0.34f;
			float vOutputAlpha = saturate( vSample.a + vGlowAlpha );
			float vCoreWeight = saturate( vSample.a / max( vOutputAlpha, 0.0001f ) );
			float3 vGlowColor = float3( 0.96f, 0.97f, 1.0f );
			float3 vOutputColor = lerp( vGlowColor, vSample.rgb, vCoreWeight );

			float vNightShade = 1.0f - ( DayNightFactor( CalcGlobeNormal( v.vPrepos.xz ) ) * 0.35f );
			vOutputColor *= vNightShade;
			vOutputAlpha *= Transp_OffsetX.x;

			return float4( vOutputColor, vOutputAlpha );
		}
	]]
}

BlendState BlendState
{
	BlendEnable = yes
	AlphaTest = no
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
	DepthWriteMask = "depth_write_all"
	DepthFunction = "comparison_less_equal"
	StencilEnable = yes
	FrontStencilFailOp = "stencil_op_keep"
	FrontStencilDepthFailOp = "stencil_op_keep"
	FrontStencilPassOp = "stencil_op_keep"
	FrontStencilFunc = "comparison_not_equal"
	StencilRef = 4
	StencilReadMask = 4
}

Effect mapname
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	DepthStencilState = "DepthStencilState"
}
