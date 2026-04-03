from sqlalchemy import Table, Column, Integer, String, ForeignKey, Float, JSON, Date
from .database import metadata

users = Table(
    "users",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("full_name", String, nullable=False),
    Column("mobile_number", String, unique=True, nullable=False),
    Column("email", String, unique=True, nullable=True),
    Column("password_hash", String, nullable=False),
    Column("role", String, nullable=False),
)

doctor_profiles = Table(
    "doctor_profiles",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id")),
    # CHANGED/NEW FIELDS BELOW:
    Column("clinic_name", String, nullable=True),
    Column("clinic_address", String, nullable=True),
    Column("specialization", String, nullable=True),
    Column("years_of_experience", Integer, nullable=True),
    Column("dci_registration_number", String, nullable=True),
    Column("qualification", String, nullable=True),
    Column("consultation_fee_online", Float, nullable=True),
    Column("consultation_fee_offline", Float, nullable=True),
    Column("dci_certificate_path", String, nullable=True),
    Column("govt_id_path", String, nullable=True),
    Column("clinic_image_path", String, nullable=True),
    Column("availability", JSON, nullable=True),   # JSON list
    Column("online_consultation", String, nullable=True),
    Column("services", JSON, nullable=True),       # JSON list
    Column("bank_account_holder", String, nullable=True),
    Column("bank_account_number", String, nullable=True),
    Column("bank_ifsc_code", String, nullable=True),
    Column("upi_id", String, nullable=True),
)

patient_profiles = Table(
    "patient_profiles",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id")),

    # 🔥 doctor assignment
    Column("doctor_user_id", Integer, ForeignKey("users.id"), nullable=True),

    Column("age", Integer, nullable=True),
    Column("gender", String, nullable=True),
    Column("address", String, nullable=True),
    Column("profile_picture_path", String, nullable=True),
    Column("clinical_profile", JSON, nullable=True),
    Column("consent", String, nullable=True),

    # 🔥 NEW FIELDS (IMPORTANT)
    Column("illness_type", String, nullable=True),
    Column("other_illness", String, nullable=True),

    # 🔥 TOKEN SYSTEM
    Column("token_number", Integer, nullable=True),
    Column("token_date", Date, nullable=True),
)

lab_profiles = Table(
    "lab_profiles",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id")),
    Column("lab_name", String, nullable=True),
    Column("owner_name", String, nullable=True),
    Column("lab_type", String, nullable=True),
    Column("mobile_number", String, nullable=True),
    Column("email", String, nullable=True),
    Column("lab_address", String, nullable=True),
    Column("city_state", String, nullable=True),
    Column("maps_location_pin", String, nullable=True),
    Column("working_hours", JSON, nullable=True),
    Column("license_number", String, nullable=True),
    Column("registration_certificate_path", String, nullable=True),
    Column("lab_photo_path", String, nullable=True),
    Column("gst_number", String, nullable=True),
    Column("services_offered", JSON, nullable=True),
    Column("order_handling", JSON, nullable=True),
    Column("report_handling", JSON, nullable=True),
    Column("logistics", JSON, nullable=True),
    Column("bank_account_holder", String, nullable=True),
    Column("bank_account_number", String, nullable=True),
    Column("bank_ifsc_code", String, nullable=True),
    Column("upi_id", String, nullable=True),
    Column("settlement_frequency", String, nullable=True),
)

images = Table(
    "images",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id")),
    Column("image_path", String),

    # 🔥 ADD THESE
    Column("doctor_user_id", Integer, ForeignKey("users.id")),
    Column("lab_user_id", Integer, ForeignKey("users.id")),
    Column("status", String, default="uploaded"),
    Column("assigned_to", String, default="doctor"),
)

classification_results = Table(
    "classification_results",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("image_id", Integer, ForeignKey("images.id")),
    Column("label", String, nullable=False),
    Column("confidence", Float, nullable=False),
    Column("mask_data", JSON, nullable=True),
)

lab_results = Table(
    "lab_results",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("image_id", Integer, ForeignKey("images.id")),  # ✅ ADD THIS
    Column("lab_user_id", Integer, ForeignKey("users.id")),
    Column("patient_user_id", Integer, ForeignKey("users.id")),
    Column("doctor_user_id", Integer, ForeignKey("users.id")),
    Column("file_path", String, nullable=False),
)