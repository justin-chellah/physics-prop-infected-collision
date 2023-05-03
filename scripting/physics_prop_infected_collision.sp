#include <sourcemod>

#define REQUIRE_EXTENSIONS
#include <dhooks>

#define GAMEDATA_FILE "physics_prop_infected_collision"

DynamicHook g_hDHook_CBaseEntity_PhysicsSolidMaskForEntity = null;

void CheckClassAndHook( int iEntity )
{
	char szClassname[64];
	GetEntityNetClass( iEntity, szClassname, sizeof( szClassname ) );

	if ( !strcmp( szClassname, "CPhysicsProp" ) )
	{
		g_hDHook_CBaseEntity_PhysicsSolidMaskForEntity.HookEntity( Hook_Post, iEntity, DHook_CBaseEntity_PhysicsSolidMaskForEntity );
	}
}

public MRESReturn DHook_CBaseEntity_PhysicsSolidMaskForEntity( int iEntity, DHookReturn hReturn )
{
	hReturn.Value |= CONTENTS_MONSTERCLIP;

	return MRES_Supercede;
}

public void OnEntityCreated( int iEntity, const char[] szClassname )
{
	CheckClassAndHook( iEntity );
}

public void OnPluginStart()
{
	GameData hGameData = new GameData( GAMEDATA_FILE );

	if ( hGameData == null )
	{
		SetFailState( "Unable to load gamedata file \"" ... GAMEDATA_FILE ... "\"" );
	}

	int nOffset = hGameData.GetOffset( "CBaseEntity::PhysicsSolidMaskForEntity" );

	if ( nOffset == -1 )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata offset entry for \"CBaseEntity::PhysicsSolidMaskForEntity\"" );
	}

	delete hGameData;

	g_hDHook_CBaseEntity_PhysicsSolidMaskForEntity = new DynamicHook( nOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity );

	int iEntity = INVALID_ENT_REFERENCE;

	while ( ( iEntity = FindEntityByClassname( iEntity, "prop_*" ) ) != INVALID_ENT_REFERENCE )
	{		
		CheckClassAndHook( iEntity );
	}
}

public Plugin myinfo =
{
	name = "[L4D/2] Physics Prop Infected Collision",
	author = "Justin \"Sir Jay\" Chellah",
	description = "Prevents physics props from flying outside the playable area for the infected team, mainly for the Tank",
	version = "1.0.0",
	url = "https://justin-chellah.com"
};