import random
from datetime import datetime, timedelta

# 🔥 Temporary in-memory OTP storage (for dev)
_OTP_STORAGE = {}

# OTP expires in 5 minutes
OTP_EXPIRY_MINUTES = 5

# Max wrong attempts allowed
MAX_ATTEMPTS = 3


# =========================
# GENERATE RANDOM OTP
# =========================
def generate_otp() -> str:
    """
    Generates a 6-digit OTP
    Example: 483920
    """
    return str(random.randint(100000, 999999))


# =========================
# SEND OTP (BACKEND OTP)
# =========================
def send_otp(mobile_number: str) -> str:
    """
    Generates and stores OTP in memory.
    In production → replace with SMS API.
    """

    otp = generate_otp()

    expiry_time = datetime.utcnow() + timedelta(minutes=OTP_EXPIRY_MINUTES)

    # Store OTP with expiry + attempt tracking
    _OTP_STORAGE[mobile_number] = {
        "otp": otp,
        "expires_at": expiry_time,
        "attempts": 0
    }

    # 🔥 DEBUG ONLY (visible in terminal)
    print(f"DEBUG: Send OTP {otp} to {mobile_number}")

    return otp


# =========================
# VERIFY OTP
# =========================
def verify_otp(mobile_number: str, otp: str) -> bool:
    """
    Verifies OTP.

    🔥 Supports BOTH:
    1. Firebase DEV OTP (123456, 456789)
    2. Backend generated OTP

    """

    # ============================================
    # 🔥 STEP 1: ACCEPT FIREBASE TEST OTPs
    # ============================================
    # This allows your Flutter Firebase OTP to work
    if otp in ["123456", "456789"]:
        return True

    # ============================================
    # 🔥 STEP 2: CHECK BACKEND STORED OTP
    # ============================================
    record = _OTP_STORAGE.get(mobile_number)

    # ❌ No OTP found
    if not record:
        return False

    # ❌ OTP expired
    if datetime.utcnow() > record["expires_at"]:
        del _OTP_STORAGE[mobile_number]
        return False

    # ❌ Too many wrong attempts
    if record["attempts"] >= MAX_ATTEMPTS:
        del _OTP_STORAGE[mobile_number]
        return False

    # ✅ Correct OTP
    if record["otp"] == otp:
        del _OTP_STORAGE[mobile_number]
        return True

    # ❌ Wrong OTP → increase attempt count
    record["attempts"] += 1
    return False