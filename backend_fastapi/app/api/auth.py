from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from datetime import datetime, timedelta
from app.crud import authenticate_user, get_user_by_mobile
from app.schemas import UserOut,OTPVerifyRequest
from app.services.otp_service import send_otp, verify_otp

SECRET_KEY = "your_super_secret_jwt_key_here"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

router = APIRouter(prefix="/auth")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


# =========================
# CREATE JWT TOKEN
# =========================
def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# =========================
# STEP 1: PASSWORD LOGIN
# =========================
@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    print(" NEW OTP LOGIN FUNCTION CALLED")
    user = await authenticate_user(form_data.username, form_data.password)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect mobile number or password"
        )

    # Password correct → Send OTP
    otp = send_otp(user.mobile_number)

    return {
        "message": "Password verified. OTP sent to registered mobile.",
        "mobile_number": user.mobile_number,
        "role": user.role,   # 🔥 ADD THIS LINE
        "dev_otp": otp
    }


# =========================
# STEP 2: VERIFY OTP
# =========================
@router.post("/verify-otp")
async def verify_otp_login(data: OTPVerifyRequest):

    mobile_number = data.mobile_number
    otp = data.otp

    if not verify_otp(mobile_number, otp):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP"
        )

    user = await get_user_by_mobile(mobile_number)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    access_token = create_access_token(
    data={
            "sub": user.mobile_number,
            "role": user.role   # 🔥 ADD THIS
        }
    )

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }

# =========================
# GET CURRENT USER (Protected Routes)
# =========================
async def get_current_user(token: str = Depends(oauth2_scheme)) -> UserOut:

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        mobile_number: str = payload.get("sub")
        role: str = payload.get("role") 

        if mobile_number is None:
            raise credentials_exception

        user = await get_user_by_mobile(mobile_number)

        if user is None:
            raise credentials_exception

        return UserOut.from_orm(user) 

    except JWTError:
        raise credentials_exception

# =========================
# FIREBASE LOGIN (NEW)
# =========================

from pydantic import BaseModel

class FirebaseLoginRequest(BaseModel):
    mobile_number: str
    role: str   # 🔥 ADD THIS LINE


@router.post("/firebase-login")
async def firebase_login(data: FirebaseLoginRequest):

    db = SessionLocal()

    mobile_number = data.mobile_number
    role = data.role.lower()

    user = await get_user_by_mobile(mobile_number)

    # ✅ AUTO CREATE USER
    if not user:
        user = User(
            mobile_number=mobile_number,
            role=role
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # ✅ UPDATE ROLE IF USER CHANGES ROLE
    elif user.role != role:
        user.role = role
        db.commit()

    # ✅ CREATE TOKEN
    access_token = create_access_token(
    data={
        "sub": user.mobile_number,
        "role": user.role   # 🔥 ADD THIS
        }
    )

    db.close()

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }

    