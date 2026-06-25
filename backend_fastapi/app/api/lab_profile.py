from fastapi import APIRouter, HTTPException
from app.schemas import LabProfileCreate, LabProfileResponse
from app.crud import create_lab_profile, get_lab_profile_by_user_id
from app.database import database

router = APIRouter(prefix="/lab")


# =====================================
# CREATE LAB PROFILE
# =====================================
@router.post("/profile")
async def create_profile(profile: LabProfileCreate):
    user_id = profile.user_id

    profile_data = profile.dict(exclude={"user_id"})

    profile_id = await create_lab_profile(
        user_id,
        profile_data
    )

    if not profile_id:
        raise HTTPException(
            status_code=400,
            detail="Failed to create lab profile"
        )

    return {
        "profile_id": profile_id
    }


# =====================================
# GET LAB PROFILE
# =====================================
@router.get("/profile/{user_id}",
            response_model=LabProfileResponse)
async def read_profile(user_id: int):

    profile = await get_lab_profile_by_user_id(
        user_id
    )

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Lab profile not found"
        )

    return profile


# =====================================
# LAB DASHBOARD STATS
# =====================================
@router.get("/dashboard/{lab_id}")
async def get_lab_dashboard(
        lab_id: int
):

    # Pending requests
    pending_query = """
    SELECT COUNT(*) AS total
    FROM images
    WHERE lab_user_id = :lab_id
    AND status = 'sent_to_lab'
    """

    pending_row = await database.fetch_one(
        query=pending_query,
        values={"lab_id": lab_id}
    )

    pending = (
        pending_row["total"]
        if pending_row
        else 0
    )

    # Completed reports
    completed_query = """
    SELECT COUNT(*) AS total
    FROM images
    WHERE lab_user_id = :lab_id
    AND status = 'completed'
    """

    completed_row = await database.fetch_one(
        query=completed_query,
        values={"lab_id": lab_id}
    )

    completed = (
        completed_row["total"]
        if completed_row
        else 0
    )

    # Total uploads
    uploads_query = """
    SELECT COUNT(*) AS total
    FROM lab_results
    WHERE lab_user_id = :lab_id
    """

    uploads_row = await database.fetch_one(
        query=uploads_query,
        values={"lab_id": lab_id}
    )

    uploads = (
        uploads_row["total"]
        if uploads_row
        else 0
    )

    return {
        "pending": pending,
        "completed": completed,
        "uploads": uploads
    }


# =====================================
# LAB HISTORY
# =====================================
@router.get("/history/{lab_id}")
async def get_lab_history(
        lab_id: int
):

    query = """
    SELECT
        i.id,
        i.user_id,
        i.image_path,
        i.status,
        lr.file_path
    FROM images i

    LEFT JOIN lab_results lr
        ON lr.image_id = i.id

    WHERE i.lab_user_id = :lab_id

    ORDER BY i.id DESC
    """

    rows = await database.fetch_all(
        query=query,
        values={"lab_id": lab_id}
    )

    return [dict(row) for row in rows]