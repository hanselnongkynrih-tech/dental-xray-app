from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from app import crud, schemas

SECRET_KEY = "your_secret_key_here"  # same as in auth.py
ALGORITHM = "HS256"

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

router = APIRouter()

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    return username

@router.post("/upload-result")
async def upload_result(data: schemas.UploadResultRequest, current_user: str = Depends(get_current_user)):
    image_id = await crud.create_image(data.user_id, data.image_path)
    await crud.create_classification_results(image_id, [r.dict() for r in data.results])
    return {"message": "Results uploaded successfully"}

@router.get("/results/{user_id}")
async def get_results(user_id: int, current_user: str = Depends(get_current_user)):
    results = await crud.get_results_by_user(user_id)
    if not results:
        raise HTTPException(status_code=404, detail="No results found")
    return results
