import asyncio
from app.crud import create_user
from app.database import database   # 👈 IMPORTANT

async def main():
    await database.connect()   # 👈 START DB

    await create_user(
        full_name="Admin",
        mobile_number="9999999999",
        email="admin@test.com",
        password="admin123",
        role="admin"
    )

    print("✅ Admin created successfully!")

    await database.disconnect()   # 👈 CLOSE DB

asyncio.run(main())