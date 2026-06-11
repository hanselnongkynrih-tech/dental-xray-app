import databases
import sqlalchemy
from sqlalchemy.ext.asyncio import create_async_engine
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://postgres:ethel123@localhost:5432/dental_app_db"
)

print("Current DATABASE_URL:", DATABASE_URL)

# For crud.py → fetch_all / fetch_one / execute
database = databases.Database(DATABASE_URL)

# For main.py → async table creation
engine = create_async_engine(DATABASE_URL, echo=True)

# For models.py → table definitions
metadata = sqlalchemy.MetaData()