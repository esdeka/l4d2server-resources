#if defined _ThirdPersonShoulder_Detect_included
	#endinput
#endif
#define _ThirdPersonShoulder_Detect_included

/**
 * Called when a client's combined third-person state changes.
 *
 * @param iClient         Client index.
 * @param bIsThirdPerson  True when the client is in third-person shoulder view.
 */
forward void TP_OnThirdPersonChanged(int iClient, bool bIsThirdPerson);

/**
 * Returns the effective third-person state exposed to other plugins.
 *
 * @param iClient  Client index.
 * @return         True when the client is considered in third-person shoulder view.
 */
native bool TP_IsThirdPerson(int iClient);

/**
 * Returns whether third-person is currently forced by game mechanics or stagger logic.
 *
 * @param iClient  Client index.
 * @return         True when third-person is forced regardless of client preference.
 */
native bool TP_IsForcedThirdPerson(int iClient);

/**
 * Returns whether the client has voluntarily enabled third-person via c_thirdpersonshoulder.
 *
 * @param iClient  Client index.
 * @return         True when the client convar indicates third-person and suppression is inactive.
 */
native bool TP_IsClientThirdPerson(int iClient);

public SharedPlugin __pl_ThirdPersonShoulder_Detect =
{
	name = "ThirdPersonShoulder_Detect",
	file = "ThirdPersonShoulder_Detect.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_ThirdPersonShoulder_Detect_SetNTVOptional()
{
	MarkNativeAsOptional("TP_IsThirdPerson");
	MarkNativeAsOptional("TP_IsForcedThirdPerson");
	MarkNativeAsOptional("TP_IsClientThirdPerson");
}
#endif
