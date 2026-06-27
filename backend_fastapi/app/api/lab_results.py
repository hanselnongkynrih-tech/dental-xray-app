from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException
from fastapi.responses import FileResponse
from pathlib import Path
from uuid import uuid4

from app.database import database
from app.api.auth import get_current_user
from app.models import images, lab_results

router = APIRouter(prefix="/lab-results")

UPLOAD_DIR = Path("uploads/lab")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


# ===============================
# LAB UPLOAD REPORT
# ===============================
@router.post("/upload")
async def upload_lab_result(
    image_id: int = Form(...),
    file: UploadFile = File(...),
    current_user=Depends(get_current_user)
):

    # 🔐 Only lab allowed
    if current_user.role != "lab":
        raise HTTPException(status_code=403, detail="Only lab can upload results")

    # 🔥 get image details
    image_query = images.select().where(images.c.id == image_id)
    image = await database.fetch_one(image_query)

    if not image:
        raise HTTPException(status_code=404, detail="Image not found")

    # 🔥 generate file
    filename = f"{uuid4()}_{file.filename}"
    file_path = UPLOAD_DIR / filename

    with open(file_path, "wb") as buffer:
        buffer.write(await file.read())

    # 🔥 insert lab result
    insert_query = lab_results.insert().values(
    image_id=image_id,  # ✅ LINK TO IMAGE
    lab_user_id=current_user.id,
    patient_user_id=image["user_id"],
    doctor_user_id=image["doctor_user_id"],
    file_path=f"uploads/lab/{filename}"  # ✅ FIX PATH
)

    result_id = await database.execute(insert_query)

    # 🔥 update image status
    update_query = images.update().where(images.c.id == image_id).values(
        status="completed",
        assigned_to="doctor"
    )

    await database.execute(update_query)

    return {
        "message": "Lab result uploaded successfully",
        "result_id": result_id,
        "file_path": str(file_path)
    }


# ===============================
# DOCTOR GET LAB RESULTS
# ===============================
@router.get("/doctor/{doctor_id}")
async def get_lab_results(
    doctor_id: int,
    current_user=Depends(get_current_user)
):

    if current_user.role != "doctor":
        raise HTTPException(status_code=403, detail="Only doctor allowed")

    query = """
    SELECT 
        i.user_id AS patient_user_id,
        u.full_name AS patient_name,
        pp.token_number
    FROM images i
    JOIN users u ON i.user_id = u.id
    LEFT JOIN patient_profiles pp ON pp.user_id = u.id
    WHERE i.doctor_user_id = :doctor_id
    GROUP BY i.user_id, u.full_name, pp.token_number
    """

    rows = await database.fetch_all(
        query=query,
        values={"doctor_id": doctor_id}
    )

    return [dict(row) for row in rows]


# ===============================
# DOCTOR GET SPECIFIC LAB RESULT
# ===============================
@router.get("/doctor-results/{doctor_id}")
async def get_lab_results_full(
    doctor_id: int,
    current_user=Depends(get_current_user)
):
    if current_user.role != "doctor":
        raise HTTPException(status_code=403, detail="Only doctor allowed")

    query = """
SELECT
    i.id AS image_id,
    i.user_id AS patient_user_id,
    u.full_name AS patient_name,
    pp.token_number,

    i.image_path,

    lr.file_path,

    i.status,

    i.request_type,

    i.priority,

    i.doctor_notes
    FROM images i
    JOIN users u ON i.user_id = u.id
    LEFT JOIN patient_profiles pp ON pp.user_id = u.id
    LEFT JOIN lab_results lr ON lr.image_id = i.id   -- ✅ FIXED
    WHERE i.doctor_user_id = :doctor_id
    """

    rows = await database.fetch_all(
        query=query,
        values={"doctor_id": doctor_id}
    )

    return [dict(row) for row in rows]

# ==========================================
# REPORT DETAILS (Doctor / Patient)
# ==========================================
@router.get("/report-details/{image_id}")
async def get_report_details(
    image_id: int,
    current_user=Depends(get_current_user)
):
    query = """
    SELECT
        i.id AS image_id,

        u.full_name AS patient_name,

        pp.token_number,

        i.image_path AS original_xray,

        lr.file_path AS lab_report,

        i.request_type,

        i.priority,

        i.doctor_notes,

        i.status,

        dr.result,

        dr.confidence

    FROM images i

    JOIN users u
        ON i.user_id = u.id

    LEFT JOIN patient_profiles pp
        ON pp.user_id = u.id

    LEFT JOIN lab_results lr
        ON lr.image_id = i.id

    LEFT JOIN diagnosis_reports dr
        ON dr.image_id = i.id

    WHERE i.id = :image_id
    """

    report = await database.fetch_one(
        query=query,
        values={
            "image_id": image_id
        }
    )

    if not report:
        raise HTTPException(
            status_code=404,
            detail="Report not found"
        )

    return dict(report)

# ==========================================
# DOWNLOAD LAB REPORT
# ==========================================
@router.get("/download/{image_id}")
async def download_lab_report(
    image_id: int,
    current_user=Depends(get_current_user)
):
    query = """
    SELECT file_path
    FROM lab_results
    WHERE image_id = :image_id
    ORDER BY id DESC
    LIMIT 1
    """

    report = await database.fetch_one(
        query=query,
        values={
            "image_id": image_id
        }
    )

    if not report:
        raise HTTPException(
            status_code=404,
            detail="Lab report not found"
        )

    file_path = Path(report["file_path"])

    if not file_path.exists():
        raise HTTPException(
            status_code=404,
            detail="File does not exist"
        )

    return FileResponse(
        path=file_path,
        filename=file_path.name,
        media_type="application/octet-stream",
    )