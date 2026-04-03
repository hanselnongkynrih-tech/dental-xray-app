from fastapi import APIRouter, HTTPException, Depends
from app.schemas import UserCreate, UserOut
from app.crud import create_user, get_doctors
from app.api.auth import get_current_user

router = APIRouter(prefix="/users")


# ===============================
# REGISTER USER
# ===============================
@router.post("/", response_model=UserOut)
async def register_user(user: UserCreate):
    try:
        # 🚨 Prevent admin creation via API
        if user.role == "admin":
            raise HTTPException(
                status_code=403,
                detail="Admin creation not allowed via API"
            )

        user_id = await create_user(
            user.full_name,
            user.mobile_number,
            user.email,
            user.password,
            user.role,
        )

        return {
            "id": user_id,
            "full_name": user.full_name,
            "mobile_number": user.mobile_number,
            "email": user.email,
            "role": user.role,
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ===============================
# CURRENT USER
# ===============================
@router.get("/me", response_model=UserOut)
async def get_logged_in_user(current_user: UserOut = Depends(get_current_user)):
    return current_user


# ===============================
# LIST DOCTORS
# ===============================
@router.get("/doctors")
async def list_doctors(current_user: UserOut = Depends(get_current_user)):
    rows = await get_doctors()
    return [dict(r) for r in rows]


# ===============================
# 🔥 ADMIN: GET ALL USERS
# ===============================
@router.get("/all")
async def get_all_users(current_user: UserOut = Depends(get_current_user)):

    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    from app.database import database
    from app.models import users

    rows = await database.fetch_all(users.select())
    return [dict(r) for r in rows]


# ===============================
# 🔥 ADMIN: DELETE USER
# ===============================
@router.delete("/{user_id}")
async def delete_user(user_id: int, current_user: UserOut = Depends(get_current_user)):

    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    from app.database import database
    from app.models import users

    query = users.delete().where(users.c.id == user_id)
    await database.execute(query)

    return {"message": "User deleted successfully"}


# ===============================
# 🔥 ADMIN: UPDATE USER ROLE
# ===============================
@router.put("/{user_id}")
async def update_user_role(
    user_id: int,
    role: str,
    current_user: UserOut = Depends(get_current_user)
):

    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    from app.database import database
    from app.models import users

    query = users.update().where(users.c.id == user_id).values(role=role)
    await database.execute(query)

    return {"message": "User role updated"}