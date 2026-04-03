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

        # ✅ TEMP: Assign doctor
        doctor_id = 2  # your doctor id

        # TEMP: Assign lab
        lab_id = 5  # your lab id

        # ✅ Insert into DB
        await database.execute(
        query="""
        INSERT INTO images (user_id, doctor_user_id, lab_user_id, image_path, status, assigned_to)
        VALUES (:user_id, :doctor_id, :lab_id, :image_path, :status, :assigned_to)
        """,
        values={
            "user_id": current_user.id,
            "doctor_id": doctor_id,
            "lab_id": lab_id,
            "image_path": str(file_location),
            "status": "uploaded",
            "assigned_to": "lab"
            }
        )

        return {
            "message": "Upload successful",
            "file_path": str(file_location)
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
    lab_id: int,
    current_user: UserOut = Depends(get_current_user)
):
    if current_user.role != "doctor":
        raise HTTPException(status_code=403, detail="Only doctors can send to lab")

    query = images.update().where(images.c.id == image_id).values(
        lab_user_id=lab_id,
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