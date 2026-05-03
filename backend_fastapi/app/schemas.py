from typing import Optional, List, Dict, Any
from pydantic import BaseModel, EmailStr

# User schemas
class UserCreate(BaseModel):
    full_name: str
    mobile_number: str
    email: Optional[EmailStr] = None
    password: str
    role: str

    class Config:
        from_attributes = True

class UserOut(BaseModel):
    id: int
    full_name: str
    mobile_number: str
    email: Optional[EmailStr]
    role: str

    class Config:
        from_attributes = True

class DoctorProfileCreate(BaseModel):
    user_id: int
    clinic_name: Optional[str] = None
    clinic_address: Optional[str] = None
    specialization: Optional[str] = None
    years_of_experience: Optional[int] = None
    dci_registration_number: Optional[str] = None
    qualification: Optional[str] = None
    consultation_fee_online: Optional[float] = None
    consultation_fee_offline: Optional[float] = None
    dci_certificate_path: Optional[str] = None
    govt_id_path: Optional[str] = None
    clinic_image_path: Optional[str] = None
    availability: Optional[List[Dict[str, Any]]] = None
    online_consultation: Optional[str] = None
    services: Optional[List[str]] = None
    bank_account_holder: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_ifsc_code: Optional[str] = None
    upi_id: Optional[str] = None

class DoctorProfileResponse(DoctorProfileCreate):
    id: int

    class Config:
        from_attributes = True

class PatientProfileCreate(BaseModel):
    user_id: int
    doctor_user_id: Optional[int] = None          # <-- NEW
    age: Optional[int] = None
    gender: Optional[str] = None
    address: Optional[str] = None
    profile_picture_path: Optional[str] = None
    clinical_profile: Optional[Dict[str, Any]] = None
    consent: Optional[str] = None

class PatientProfileResponse(PatientProfileCreate):
    id: int

    class Config:
        from_attributes = True

class LabProfileCreate(BaseModel):
    user_id: int
    lab_name: Optional[str] = None
    owner_name: Optional[str] = None
    lab_type: Optional[str] = None
    mobile_number: Optional[str] = None
    email: Optional[str] = None
    lab_address: Optional[str] = None
    city_state: Optional[str] = None
    maps_location_pin: Optional[str] = None
    working_hours: Optional[List[Dict[str, Any]]] = None
    license_number: Optional[str] = None
    registration_certificate_path: Optional[str] = None
    lab_photo_path: Optional[str] = None
    gst_number: Optional[str] = None
    services_offered: Optional[List[str]] = None
    order_handling: Optional[Dict[str, Any]] = None
    report_handling: Optional[Dict[str, Any]] = None
    logistics: Optional[Dict[str, Any]] = None
    bank_account_holder: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_ifsc_code: Optional[str] = None
    upi_id: Optional[str] = None
    settlement_frequency: Optional[str] = None

class LabProfileResponse(LabProfileCreate):
    id: int

    class Config:
        from_attributes = True

class UploadResultRequest(BaseModel):
    image_id: int
    label: str
    confidence: float
    mask_data: Optional[dict] = None

class OTPVerifyRequest(BaseModel):
    mobile_number: str
    otp: str

class FirebaseLoginRequest(BaseModel):
    mobile_number: str
    role: str   # 🔥 REQUIRED

class AppointmentCreate(BaseModel):
    date: str
    time: str
    doctor_id: int 


class AppointmentOut(BaseModel):
    id: int
    date: str
    time: str
    status: str

    class Config:
        from_attributes = True