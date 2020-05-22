#include <raylib.h>

void _wDrawTextureV(
	const Texture2D* texture, const Vector2* position, const Color* tint
)
#ifdef workaround_implementation
{
	DrawTextureV(*texture, *position, *tint);
}
#else
;
#endif

void _wGetScreenToWorld2D(
	const Vector2* position, const Camera2D* camera, Vector2* out
)
#ifdef workaround_implementation
{
	*out = GetScreenToWorld2D(*position, *camera);
}
#else
;
#endif