import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from .database import engine, metadata, database
from .api import (
    auth, users, doctor_profile, patient_profile, lab_profile,
    results, images, lab_results, ml_predict,
    patient_dashboard, doctor_dashboard, appointments
)

app = FastAPI()

# Routers
app.include_router(auth.router)
app.include_router(patient_dashboard.router)
app.include_router(doctor_dashboard.router)
app.include_router(users.router)
app.include_router(doctor_profile.router)
app.include_router(patient_profile.router)
app.include_router(lab_profile.router)
app.include_router(results.router)
app.include_router(images.router)
app.include_router(lab_results.router)
app.include_router(ml_predict.router)
app.include_router(appointments.router)

# Serve uploaded images
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


@app.on_event("startup")
async def startup():
    # Connect databases library (for crud.py)
    await database.connect()
    # Create all tables via async engine
    async with engine.begin() as conn:
        await conn.run_sync(metadata.create_all)


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()
    await engine.dispose()


@app.get("/")
async def root():
    return {"message": "Backend is running!"}