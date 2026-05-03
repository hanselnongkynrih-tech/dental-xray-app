from app.api import images
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from .database import engine, database, metadata
from .api import auth, users, doctor_profile, patient_profile, lab_profile, results, images, lab_results, ml_predict, patient_dashboard, doctor_dashboard, appointments

metadata.create_all(bind=engine)

app = FastAPI()

# routers
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
# serve uploaded images
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


@app.on_event("startup")
async def startup():
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


@app.get("/")
async def root():
    return {"message": "Backend is running!"}