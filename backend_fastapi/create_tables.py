from app.database import engine, metadata
import app.models  # Ensure model tables are registered in metadata

def create_tables():
    metadata.create_all(bind=engine)
    print("Database tables created successfully")

if __name__ == "__main__":
    create_tables()
