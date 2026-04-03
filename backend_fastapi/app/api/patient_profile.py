from fastapi import APIRouter, HTTPException
from app.schemas import PatientProfileCreate, PatientProfileResponse
from app.crud import (
    create_patient_profile,
    get_patient_profile_by_user_id,
    get_patients_for_doctor,
    generate_token_for_patient,
)

router = APIRouter(prefix="/patient")

@router.post("/profile")
async def create_profile(profile: PatientProfileCreate):
    user_id = profile.user_id
    profile_data = profile.dict(exclude={"user_id"})

    # ✅ create profile
    profile_id = await create_patient_profile(user_id, profile_data)

    if not profile_id:
        raise HTTPException(status_code=400, detail="Failed to create patient profile")

    # 🔥 GENERATE TOKEN
    token = await generate_token_for_patient(user_id)

    return {
        "message": "Patient profile created successfully",
        "profile_id": profile_id,
        "token_number": token
    }

@router.get("/profile/{user_id}", response_model=PatientProfileResponse)
async def read_profile(user_id: int):
    profile = await get_patient_profile_by_user_id(user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Patient profile not found")
    return profile

@router.get("/doctor/{doctor_user_id}/patients")
async def read_doctor_patients(doctor_user_id: int):
    """
    Returns all patients assigned to the given doctor.
    Used by the doctor dashboard.
    """
    patients = await get_patients_for_doctor(doctor_user_id)
    return patients
