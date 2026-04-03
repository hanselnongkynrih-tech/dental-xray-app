from fastapi import APIRouter, HTTPException
from app.schemas import LabProfileCreate, LabProfileResponse
from app.crud import create_lab_profile, get_lab_profile_by_user_id

router = APIRouter(prefix="/lab")

@router.post("/profile")
async def create_profile(profile: LabProfileCreate):
    user_id = profile.user_id
    profile_data = profile.dict(exclude={"user_id"})
    profile_id = await create_lab_profile(user_id, profile_data)
    if not profile_id:
        raise HTTPException(status_code=400, detail="Failed to create lab profile")
    return {"profile_id": profile_id}

@router.get("/profile/{user_id}", response_model=LabProfileResponse)
async def read_profile(user_id: int):
    profile = await get_lab_profile_by_user_id(user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Lab profile not found")
    return profile
