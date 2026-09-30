import os
import shutil
import tempfile
import cv2
import numpy as np
from fastapi import UploadFile


def cleanup_temp_dir(path: str):
    """Elimina de forma segura un directorio temporal y su contenido."""
    if os.path.exists(path):
        shutil.rmtree(path, ignore_errors=True)


def resize_frame(frame: np.ndarray, width: int = 1000) -> np.ndarray:
    """Redimensiona la imagen proporcionalmente si su ancho excede el límite."""
    h, w = frame.shape[:2]
    if w <= width:
        return frame
    new_h = int(h * (width / w))
    return cv2.resize(frame, (width, new_h))


def crop_black_edges(image: np.ndarray) -> np.ndarray:
    """Detecta y recorta los bordes negros resultantes del proceso de stitching."""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    _, thresh = cv2.threshold(gray, 1, 255, cv2.THRESH_BINARY)
    
    x, y, w, h = cv2.boundingRect(thresh)
    margin_x = int(w * 0.05)
    margin_y = int(h * 0.05)
    
    x1 = x + margin_x
    y1 = y + margin_y
    x2 = x + w - margin_x
    y2 = y + h - margin_y
    
    if x2 > x1 and y2 > y1:
        return image[y1:y2, x1:x2]
    return image[y:y + h, x:x + w]


async def load_uploaded_images(files: list[UploadFile], max_width: int = 1000) -> list[np.ndarray]:
    """Lee los archivos de imagen subidos en memoria y los convierte en matrices OpenCV."""
    frames = []
    for file in files:
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is not None:
            img = resize_frame(img, width=max_width)
            frames.append(img)
            
    if len(frames) < 2:
        raise ValueError("No se pudieron leer suficientes imágenes válidas.")
        
    return frames


def extract_frames_from_video(video_path: str, max_frames: int = 25, max_width: int = 1000) -> list[np.ndarray]:
    """Muestra e imágenes extraídas progresivamente de un video para unirlas."""
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise ValueError("No se pudo abrir el archivo de video.")

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0

    if total_frames <= 0:
        cap.release()
        raise ValueError("El video está vacío o no es válido.")

    # Muestreo cada ~0.3 segundos o según la duración para evitar fotogramas idénticos
    min_step = max(1, int(fps * 0.3))
    step = max(min_step, total_frames // max_frames)

    frames = []
    frame_idx = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        if frame_idx % step == 0:
            resized = resize_frame(frame, width=max_width)
            frames.append(resized)
            if len(frames) >= max_frames:
                break
        frame_idx += 1

    cap.release()

    if len(frames) < 2:
        raise ValueError("No se pudieron extraer suficientes fotogramas del video para generar la panorámica.")

    return frames


def stitch_frames(frames: list[np.ndarray]) -> np.ndarray:
    """
    Fusiona una lista de fotogramas en una panorámica.
    Intenta primero el modo SCANS (deslizamiento) y si falla prueba el modo esférico estándar.
    """
    stitcher_scans = cv2.Stitcher_create(cv2.Stitcher_SCANS)
    status, pano = stitcher_scans.stitch(frames)

    if status != cv2.Stitcher_OK:
        stitcher_normal = cv2.Stitcher_create()
        status, pano = stitcher_normal.stitch(frames)
        
        if status != cv2.Stitcher_OK:
            raise RuntimeError(
                "Fallo al fusionar. El contenido necesita al menos 30% a 40% de elementos en común."
            )

    return crop_black_edges(pano)


async def create_panorama(files: list[UploadFile]) -> tuple[str, str]:
    """Crea una panorámica a partir de múltiples fotos."""
    temp_dir = tempfile.mkdtemp()
    try:
        frames = await load_uploaded_images(files)
        pano = stitch_frames(frames)

        image_path = os.path.join(temp_dir, "panorama.jpg")
        cv2.imwrite(image_path, pano, [int(cv2.IMWRITE_JPEG_QUALITY), 95])
        
        return image_path, temp_dir
    except Exception:
        cleanup_temp_dir(temp_dir)
        raise


async def create_panorama_from_video(video_file: UploadFile) -> tuple[str, str]:
    """Extrae imágenes de un video y crea la panorámica."""
    temp_dir = tempfile.mkdtemp()
    try:
        temp_video_path = os.path.join(temp_dir, video_file.filename or "input_video.mp4")
        contents = await video_file.read()
        with open(temp_video_path, "wb") as f:
            f.write(contents)

        frames = extract_frames_from_video(temp_video_path)
        pano = stitch_frames(frames)

        image_path = os.path.join(temp_dir, "panorama.jpg")
        cv2.imwrite(image_path, pano, [int(cv2.IMWRITE_JPEG_QUALITY), 95])

        return image_path, temp_dir
    except Exception:
        cleanup_temp_dir(temp_dir)
        raise