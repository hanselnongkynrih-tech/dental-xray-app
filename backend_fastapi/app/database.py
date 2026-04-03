import databases
import sqlalchemy
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://dan:12345@localhost/dental_app_db")

print("Current DATABASE_URL:", DATABASE_URL)

database = databases.Database(DATABASE_URL)
metadata = sqlalchemy.MetaData()
engine = sqlalchemy.create_engine(DATABASE_URL)
