from app.schemas import UserOut
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
            """
                SELECT COUNT(*)
                FROM lab_results
                WHERE patient_user_id = :id
            """,
            {"id": user_id},
        )

    except:
        reports_count = reports_count or 0

    try:
        appointments_count = await database.fetch_val(
            "SELECT COUNT(*) FROM appointments WHERE patient_id = :id",
            {"id": user_id}
    )
    except:
        appointments_count = 0

    # ───────── RECENT ACTIVITY ─────────
    try:
        recent = await database.fetch_all(
            """
            SELECT
                id AS image_id,
                status,
                CASE
                    WHEN status = 'uploaded' THEN '📤 X-Ray Uploaded'
                    WHEN status = 'pending' THEN '🧪 Sent to Lab'
                    WHEN status = 'completed' THEN '📄 Lab Report Ready'
                    ELSE '📋 Status Updated'
                END AS title,
                created_at
            FROM images
            WHERE user_id = :id
            ORDER BY id DESC
            LIMIT 5
            """,
            {"id": user_id},
        )
    except Exception:
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
                "time": str(r["created_at"]),
                "image_id": r["image_id"],
                "status": r["status"]
            } for r in recent
        ]
    }

#==========================================
#PATIENT REPORT DETAILS
#==========================================
@router.get("/reports")
async def get_patient_reports(
    current_user: UserOut = Depends(get_current_user)
):
    query = """
                SELECT
                    i.id AS image_id,
                    pp.token_number,
                    i.status
                FROM images i
                LEFT JOIN patient_profiles pp
                ON pp.user_id = i.user_id
                WHERE i.user_id = :user_id
                AND i.status = 'completed'
                ORDER BY i.id DESC
        """

    reports = await database.fetch_all(
        query=query,
        values={"user_id": current_user.id},
    )

    return [dict(r) for r in reports]