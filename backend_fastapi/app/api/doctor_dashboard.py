from fastapi import APIRouter, Depends, HTTPException
from app.api.auth import get_current_user
from app.database import database

router = APIRouter()


@router.get("/doctor/dashboard")
async def get_doctor_dashboard(current_user=Depends(get_current_user)):

    if current_user.role != "doctor":
        raise HTTPException(status_code=403, detail="Not authorized")

    from app.database import database

    # ===============================
    # ✅ PATIENT COUNT (ASSIGNED TO DOCTOR)
    # ===============================
    patients = await database.fetch_all("""
    SELECT DISTINCT patient_id
    FROM appointments
    WHERE doctor_id = :id
""", {"id": current_user.id})

    # ===============================
    # ✅ CASES (IMAGES FOR DOCTOR)
    # ===============================
    images = await database.fetch_all("""
        SELECT *
        FROM images
        WHERE doctor_user_id = :id
    """, {"id": current_user.id})

    # ===============================
    # ✅ REPORTS (JOIN)
    # ===============================
    reports = await database.fetch_all("""
        SELECT lr.*
        FROM lab_results lr
        WHERE lr.doctor_user_id = :id
        """, {"id": current_user.id})

    return {
        "patients": len(patients),
        "cases": len(images),
        "reports": len(reports)
    }

@router.get("/doctor/patients")
async def get_doctor_patients(current_user=Depends(get_current_user)):

    if current_user.role != "doctor":
        raise HTTPException(status_code=403)

    rows = await database.fetch_all("""
        SELECT DISTINCT
            u.id,
            u.full_name,
            u.mobile_number
        FROM appointments a
        JOIN users u ON a.patient_id = u.id
        WHERE a.doctor_id = :id
    """, {"id": current_user.id})

    return [dict(r) for r in rows]