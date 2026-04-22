from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from pathlib import Path
from uuid import uuid4

from app.database import database
from app.models import images
from app.api.auth import get_current_user
from app.crud import get_images_for_doctor
from app.schemas import UserOut

router = APIRouter(prefix="/images")

# ===============================
# CREATE UPLOAD FOLDER
# ===============================
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


# ===============================
# ✅ PATIENT UPLOAD XRAY
# ===============================
@router.post("/upload")
async def upload_image(
    file: UploadFile = File(...),
    current_user: UserOut = Depends(get_current_user)
):
    # 🔐 Only patient can upload
    if current_user.role != "patient":
        raise HTTPException(status_code=403, detail="Only patients can upload")

    try:
        # ✅ Generate file path
        file_name = f"{uuid4()}_{file.filename}"
        file_location = UPLOAD_DIR / file_name

        # ✅ Save file
        with open(file_location, "wb") as f:
            f.write(await file.read())

        # ✅ ADD THIS LINE (IMPORTANT)
        image_path = f"uploads/{file_name}"

        # ✅ Get doctor and lab assignment for this patient
        patient = await database.fetch_one(
        query="""
            SELECT doctor_user_id, lab_user_id
            FROM patient_profiles
            WHERE user_id = :user_id
            """,
            values={"user_id": current_user.id}
            )

        if not patient:
                raise HTTPException(status_code=404, detail="Patient profile not found")

        doctor_id = patient["doctor_user_id"]
        lab_id = patient["lab_user_id"]

        # ✅ Insert into DB
        image_id = await database.execute(
        query="""
                INSERT INTO images (user_id, doctor_user_id, lab_user_id, image_path, status, assigned_to)
                VALUES (:user_id, :doctor_id, :lab_id, :image_path, :status, :assigned_to)
                RETURNING id
            """,
            values={
                "user_id": current_user.id,
                "doctor_id": doctor_id,
                "lab_id": lab_id,
                "image_path": image_path,
                "status": "uploaded",
                "assigned_to": "lab"
            }
        )

        # ✅ REPORT CREATION
        await database.execute(
        query="""
        INSERT INTO diagnosis_reports (image_id, status)
         VALUES (:image_id, :status)
            """,
            values={
                "image_id": image_id,
                "status": "pending"
            }
        )

        return {
            "message": "Upload successful",
            "file_path": image_path,
            "image_id": image_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {e}")


# ===============================
# ✅ DOCTOR: GET PATIENT XRAYS
# ===============================
@router.get("/doctor/{doctor_id}")
async def doctor_images(
    doctor_id: int,
    current_user: UserOut = Depends(get_current_user)
):
    if current_user.role != "doctor":
        raise HTTPException(status_code=403)

    results = await get_images_for_doctor(doctor_id)
    return results


# ===============================
# ✅ ADMIN: GET ALL IMAGES
# ===============================
@router.get("/all")
async def get_all_images(current_user: UserOut = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    rows = await database.fetch_all(images.select())
    return [dict(r) for r in rows]


# ===============================
# ✅ ADMIN: DELETE IMAGE
# ===============================
@router.delete("/{image_id}")
async def delete_image(
    image_id: int,
    current_user: UserOut = Depends(get_current_user)
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    query = images.delete().where(images.c.id == image_id)
    await database.execute(query)

    return {"message": "Image deleted"}


# ===============================
# ✅ DOCTOR: SEND IMAGE TO LAB
# ===============================
@router.post("/send-to-lab")
async def send_to_lab(
    image_id: int,
    lab_user_id: int,   # ✅ changed
    current_user: UserOut = Depends(get_current_user)
):
    if current_user.role != "doctor":
        raise HTTPException(status_code=403, detail="Only doctors can send to lab")

    # 🔥 Validate lab user exists AND is actually a lab
    lab_user = await database.fetch_one(
        query="""
        SELECT id FROM users
        WHERE id = :lab_user_id AND role = 'lab'
        """,
        values={"lab_user_id": lab_user_id}
    )

    if not lab_user:
        raise HTTPException(status_code=400, detail="Invalid lab user")

    # 🔥 Update image
    query = images.update().where(images.c.id == image_id).values(
        lab_user_id=lab_user_id,
        assigned_to="lab",
        status="sent_to_lab"
    )

    await database.execute(query)

    return {"message": "Image sent to lab"}


# ===============================
# ✅ LAB: GET ASSIGNED IMAGES
# ===============================
@router.get("/lab/{lab_id}")
async def get_lab_images(
    lab_id: int,
    current_user: UserOut = Depends(get_current_user)
):
    if current_user.role != "lab":
        raise HTTPException(status_code=403)

    query = """
    SELECT id, user_id, image_path, status
    FROM images
    WHERE lab_user_id = :lab_id
    """

    rows = await database.fetch_all(
        query=query,
        values={"lab_id": lab_id}
    )

    return [dict(row) for row in rows]

    # ===============================
# ✅ GET REPORT
# ===============================
@router.get("/my-reports")
async def get_my_reports(current_user: UserOut = Depends(get_current_user)):

    query = """
    SELECT 
        i.id AS image_id,
        i.image_path,
        d.status,
        d.result,
        d.confidence
    FROM images i
    JOIN diagnosis_reports d ON i.id = d.image_id
    WHERE i.user_id = :user_id
    """

    rows = await database.fetch_all(
        query=query,
        values={"user_id": current_user.id}
    )

    return [dict(row) for row in rows]

# ===============================
# ✅ REPORT UPDATION
# ===============================
@router.post("/update-report")
async def update_report(
    image_id: int,
    result: str,
    confidence: float
):
    query = """
    UPDATE diagnosis_reports
    SET result = :result,
        confidence = :confidence,
        status = 'completed'
    WHERE image_id = :image_id
    """

    await database.execute(
        query=query,
        values={
            "image_id": image_id,
            "result": result,
            "confidence": confidence
        }
    )

    return {"message": "Report updated successfully"}

# ===============================
@router.get("/labs")
async def get_labs():
    query = """
    SELECT 
        u.id AS user_id,
        u.full_name,
        lp.lab_name
    FROM users u
    JOIN lab_profiles lp ON u.id = lp.user_id
    WHERE u.role = 'lab'
    """

    rows = await database.fetch_all(query)
    return [dict(row) for row in rows]