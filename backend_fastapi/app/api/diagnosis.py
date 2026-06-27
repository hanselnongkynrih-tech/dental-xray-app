from fastapi import APIRouter, Depends, HTTPException
from app.api.auth import get_current_user
from app.schemas import (
    UserOut,
    ManualDiagnosisCreate,
)
from app.database import database

router = APIRouter(
    prefix="/diagnosis",
    tags=["Diagnosis"],
)


# =====================================
# SAVE MANUAL DIAGNOSIS
# =====================================
@router.post("/manual")
async def save_manual_diagnosis(
    data: ManualDiagnosisCreate,
    current_user: UserOut = Depends(get_current_user),
):

    if current_user.role != "doctor":
        raise HTTPException(
            status_code=403,
            detail="Only doctors can save diagnoses.",
        )

    image = await database.fetch_one(
        """
        SELECT id
        FROM images
        WHERE id = :image_id
        """,
        {
            "image_id": data.image_id,
        },
    )

    if image is None:
        raise HTTPException(
            status_code=404,
            detail="Image not found.",
        )

    await database.execute(
        """
        INSERT INTO diagnosis_reports
        (
            image_id,
            diagnosis_type,
            diagnosis,
            prescription,
            treatment_plan,
            notes,
            doctor_user_id,
            reviewed,
            status
        )
        VALUES
        (
            :image_id,
            'manual',
            :diagnosis,
            :prescription,
            :treatment_plan,
            :notes,
            :doctor_user_id,
            TRUE,
            'completed'
        )
        """,
        {
            "image_id": data.image_id,
            "diagnosis": data.diagnosis,
            "prescription": data.prescription,
            "treatment_plan": data.treatment_plan,
            "notes": data.notes,
            "doctor_user_id": current_user.id,
        },
    )

    return {
        "message": "Manual diagnosis saved successfully."
    }


# =====================================
# GET DIAGNOSIS HISTORY
# =====================================
@router.get("/{image_id}")
async def get_diagnosis_history(
    image_id: int,
    current_user: UserOut = Depends(get_current_user),
):

    reports = await database.fetch_all(
        """
        SELECT *
        FROM diagnosis_reports
        WHERE image_id = :image_id
        ORDER BY created_at DESC
        """,
        {
            "image_id": image_id,
        },
    )

    return [dict(r) for r in reports]