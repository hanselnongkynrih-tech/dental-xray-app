from fastapi import APIRouter, HTTPException
from app.schemas import DoctorProfileCreate, DoctorProfileResponse
from app.crud import create_doctor_profile, get_doctor_profile_by_user_id
from app.crud import get_images_for_doctor

router = APIRouter(prefix="/doctor")

@router.post("/profile")
async def create_profile(profile: DoctorProfileCreate):
    user_id = profile.user_id
    profile_data = profile.dict(exclude={"user_id"})
    profile_id = await create_doctor_profile(user_id, profile_data)
    if not profile_id:
        raise HTTPException(status_code=400, detail="Failed to create doctor profile")
    return {"profile_id": profile_id}

@router.get("/profile/{user_id}", response_model=DoctorProfileResponse)
async def read_profile(user_id: int):
    profile = await get_doctor_profile_by_user_id(user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Doctor profile not found")
    return profile

@router.get("/{doctor_user_id}/images")
async def read_doctor_images(doctor_user_id: int):
    """
    Returns all X-rays uploaded by patients assigned to doctor
    """

    images = await get_images_for_doctor(doctor_user_id)
    return images