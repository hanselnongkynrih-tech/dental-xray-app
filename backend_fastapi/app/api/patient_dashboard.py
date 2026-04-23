from fastapi import APIRouter, Depends
from app.database import database
from app.api.auth import get_current_user

router = APIRouter()


@router.get("/patient/dashboard")
async def get_patient_dashboard(user=Depends(get_current_user)):

    # ✅ Correct way to access user (Pydantic object)
    user_id = user.id
    mobile = user.mobile_number
    name = getattr(user, "full_name", None)
    # ───────── COUNTS ─────────
    images_count = await database.fetch_val(
        "SELECT COUNT(*) FROM images WHERE user_id = :id",
        {"id": user_id}
    )

    try:
        reports_count = await database.fetch_val(
            "SELECT COUNT(*) FROM reports WHERE user_id = :id",
            {"id": user_id}
        )
    except:
        reports_count = 0

    try:
        appointments_count = await database.fetch_val(
            "SELECT COUNT(*) FROM appointments WHERE user_id = :id",
            {"id": user_id}
        )
    except:
        appointments_count = 0

    # ───────── RECENT ACTIVITY ─────────
    try:
        recent = await database.fetch_all(
            """
            SELECT 'X-ray Uploaded' AS title, created_at
            FROM images
            WHERE user_id = :id
            ORDER BY created_at DESC
            LIMIT 5
            """,
            {"id": user_id}
        )
    except:
        recent = []

    # ───────── RESPONSE ─────────
    return {
        "name": name.capitalize() if name else "Patient",
        "images": images_count or 0,
        "reports": reports_count or 0,
        "appointments": appointments_count or 0,
        "recent_activity": [
            {
                "title": r["title"],
                "time": str(r["created_at"])
            } for r in recent
        ]
    }