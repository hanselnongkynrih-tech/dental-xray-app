from fastapi import APIRouter, Depends
from app.database import database
from app.models import appointments
from app.api.auth import get_current_user
from app.schemas import AppointmentCreate

router = APIRouter()


@router.post("/appointments/create")
async def create_appointment(
    data: AppointmentCreate,
    current_user=Depends(get_current_user)
):
    query = appointments.insert().values(
        patient_id=current_user.id,
        doctor_id=data.doctor_id,   # ✅ ADD THIS
        date=data.date,
        time=data.time,
        status="pending"
    )

    await database.execute(query)

    return {"message": "Appointment booked"}


@router.get("/appointments/my")
async def get_my_appointments(current_user=Depends(get_current_user)):
    query = appointments.select().where(
        appointments.c.patient_id == current_user.id
    )
    result = await database.fetch_all(query)

    return result

@router.get("/appointments/doctor")
async def get_doctor_appointments(current_user=Depends(get_current_user)):
    query = appointments.select().where(
        appointments.c.doctor_id == current_user.id
    )
    result = await database.fetch_all(query)
    return result