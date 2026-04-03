from fastapi import Depends, APIRouter
from sqlalchemy.orm import Session
from app.database import database
from app.services.profile_services import ProfileService

router = APIRouter(prefix="/doctor")

async def get_db():
    # Async session creation here or your database access
    # For demo using database object (adjust per your setup)
    yield database

@router.post("/profile")
async def create_profile(user_id: int, profile_data: dict, db: Session = Depends(get_db)):
    ps = ProfileService(db)
    profile_id = await ps.add_doctor_profile(user_id, profile_data)
    return {"profile_id": profile_id}
