from fastapi import FastAPI, File, UploadFile, BackgroundTasks, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from utils import create_panorama, create_panorama_from_video, cleanup_temp_dir

app = FastAPI(title="Stitch Images & Video API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/stitch-images/")
async def stitch_images(
    files: list[UploadFile] = File(...), 
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    if len(files) < 1:
        raise HTTPException(status_code=400, detail="Se necesita al menos 1 imagen.")

    try:
        image_path, temp_dir = await create_panorama(files)
        background_tasks.add_task(cleanup_temp_dir, temp_dir)
        return FileResponse(image_path, media_type="image/jpeg", filename="resultado.jpg")
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/stitch-video/")
async def stitch_video(
    file: UploadFile = File(...),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    try:
        image_path, temp_dir = await create_panorama_from_video(file)
        background_tasks.add_task(cleanup_temp_dir, temp_dir)
        return FileResponse(image_path, media_type="image/jpeg", filename="resultado_video.jpg")
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))