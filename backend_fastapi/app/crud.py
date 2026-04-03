from sqlalchemy import select

from app.database import database
from app.models import users, doctor_profiles, patient_profiles, lab_profiles
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# === USERS ===
async def create_user(full_name: str, mobile_number: str, email: str, password: str, role: str) -> int:
    hashed_password = hash_password(password)
    query = users.insert().values(
        full_name=full_name,
        mobile_number=mobile_number,
        email=email,
        password_hash=hashed_password,
        role=role
    )
    user_id = await database.execute(query)
    return user_id

async def get_user_by_mobile(mobile_number: str):
    query = users.select().where(users.c.mobile_number == mobile_number)
    return await database.fetch_one(query)

async def authenticate_user(mobile_number: str, password: str):
    user = await get_user_by_mobile(mobile_number)
    if user and verify_password(password, user.password_hash):
        return user
    return None

async def get_doctors():
    """
    Return all users with role='doctor' for dropdown in patient registration.
    """
    query = (
        select(
            users.c.id,
            users.c.full_name,
            users.c.mobile_number,
            users.c.email,
            users.c.role,
        )
        .where(users.c.role == "doctor")
    )
    rows = await database.fetch_all(query)
    return rows

# === DOCTOR PROFILE ===
async def create_doctor_profile(user_id: int, profile_data: dict):
    data = {"user_id": user_id}
    data.update(profile_data)
    query = doctor_profiles.insert().values(**data)
    return await database.execute(query)

async def get_doctor_profile_by_user_id(user_id: int):
    query = doctor_profiles.select().where(doctor_profiles.c.user_id == user_id)
    return await database.fetch_one(query)

# === PATIENT PROFILE ===
async def create_patient_profile(user_id: int, profile_data: dict):
    data = {"user_id": user_id}
    data.update(profile_data)
    query = patient_profiles.insert().values(**data)
    return await database.execute(query)

async def get_patient_profile_by_user_id(user_id: int):
    query = patient_profiles.select().where(patient_profiles.c.user_id == user_id)
    return await database.fetch_one(query)

async def get_patients_for_doctor(doctor_user_id: int):
    """
    Return a list of patients assigned to a doctor, including user.full_name.
    Used by the doctor dashboard.
    """
    query = (
        select(
            patient_profiles.c.user_id.label("user_id"),
            patient_profiles.c.doctor_user_id.label("doctor_user_id"),
            patient_profiles.c.age.label("age"),
            patient_profiles.c.gender.label("gender"),
            patient_profiles.c.address.label("address"),
            users.c.full_name.label("full_name"),
        )
        .select_from(
            patient_profiles.join(users, patient_profiles.c.user_id == users.c.id)
        )
        .where(patient_profiles.c.doctor_user_id == doctor_user_id)
    )
    rows = await database.fetch_all(query)
    return [dict(row) for row in rows]

# === LAB PROFILE ===
async def create_lab_profile(user_id: int, profile_data: dict):
    data = {"user_id": user_id}
    data.update(profile_data)
    query = lab_profiles.insert().values(**data)
    return await database.execute(query)

async def get_lab_profile_by_user_id(user_id: int):
    query = lab_profiles.select().where(lab_profiles.c.user_id == user_id)
    return await database.fetch_one(query)
# ======= ******* Images upload ********** ===========

async def get_images_for_doctor(doctor_id: int):
    query = """
    SELECT 
        i.id,
        i.user_id,
        i.image_path,
        i.status,
        u.full_name
    FROM images i
    JOIN users u ON i.user_id = u.id
    WHERE i.doctor_user_id = :doctor_id
    """

    rows = await database.fetch_all(
        query=query,
        values={"doctor_id": doctor_id}
    )

    return [dict(row) for row in rows]

# ========== ********* Lab Results ********** ===========
async def get_lab_results_for_doctor(doctor_id: int):

    query = """
    SELECT * FROM lab_results
    WHERE doctor_user_id = :doctor_id
    """

    rows = await database.fetch_all(
        query=query,
        values={"doctor_id": doctor_id}
    )

    return [dict(row) for row in rows]

# ========== ********* Token Generation ********** =========== 
from datetime import date

async def generate_token_for_patient(user_id: int):

    today = date.today()

    # get patient
    patient = await get_patient_profile_by_user_id(user_id)

    if not patient:
        return None

    # if token already exists today → keep it
    if patient["token_date"] == today:
        return patient["token_number"]

    # 🔥 get max token today
    query = """
    SELECT MAX(token_number) as max_token
    FROM patient_profiles
    WHERE token_date = :today
    """

    row = await database.fetch_one(query=query, values={"today": today})

    next_token = (row["max_token"] or 0) + 1

    # update patient
    update_query = patient_profiles.update().where(
        patient_profiles.c.user_id == user_id
    ).values(
        token_number=next_token,
        token_date=today
    )

    await database.execute(update_query)

    return next_token

# === (OPTIONAL) Add update and delete functions here for advanced features ===
