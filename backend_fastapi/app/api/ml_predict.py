from fastapi import APIRouter
from pydantic import BaseModel

from app.ml.predict import predict_image

router = APIRouter(prefix="/ml", tags=["ML"])


class PredictRequest(BaseModel):
    image_path: str


@router.post("/predict")
async def predict(data: PredictRequest):

    result = predict_image(data.image_path)

    return {
        "prediction": result
    }