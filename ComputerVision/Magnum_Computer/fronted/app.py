import os
import base64
import requests
import flet as ft


def main(page: ft.Page):
    # -------------------------------------------------------------
    # CONFIGURACIÓN DE LA VENTANA Y TEMA
    # -------------------------------------------------------------
    page.title = "Panorama Studio • Creador de Panorámicas HD"
    page.theme_mode = ft.ThemeMode.DARK
    page.bgcolor = "#0B0F19"
    page.padding = 24
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    if hasattr(page, "window"):
        page.window.width = 680
        page.window.height = 820
        page.window.min_width = 540
        page.window.min_height = 640
        page.window.center()

    # Estado de la aplicación
    selected_photo_paths = []
    selected_video_path = [None]
    active_tab = [0]  # 0: Fotos, 1: Video
    last_saved_path = [None]

    # -------------------------------------------------------------
    # COMPONENTES VISUALES
    # -------------------------------------------------------------
    progress_bar = ft.ProgressBar(
        visible=False,
        color="#38BDF8",
        bgcolor="#1E293B",
        height=4
    )

    status_icon = ft.Icon(ft.Icons.INFO_OUTLINE_ROUNDED, color="#94A3B8", size=18)
    status_label = ft.Text("Selecciona al menos 2 fotos con solapamiento (30%-40%)", size=12, color="#94A3B8")
    status_card = ft.Container(
        content=ft.Row([status_icon, ft.Container(content=status_label, expand=True)], spacing=10),
        padding=ft.padding.symmetric(horizontal=14, vertical=10),
        bgcolor="#111827",
        border_radius=10,
        border=ft.border.all(1, "#1F2937"),
    )

    badge_counter = ft.Container(
        content=ft.Text("0 fotos seleccionadas", size=11, weight=ft.FontWeight.BOLD, color="#94A3B8"),
        padding=ft.padding.symmetric(horizontal=10, vertical=4),
        border_radius=20,
        bgcolor="#1F2937",
        border=ft.border.all(1, "#374151")
    )

    files_row = ft.Row(
        wrap=True,
        spacing=8,
    )

    files_container = ft.Container(
        content=files_row,
        visible=False,
        padding=6,
    )

    result_image = ft.Image(
        visible=False,
        fit=ft.ImageFit.CONTAIN,
        border_radius=ft.border_radius.all(10),
        height=200
    )

    result_card = ft.Container(
        content=ft.Column([
            ft.Row([
                ft.Row([
                    ft.Icon(ft.Icons.CHECK_CIRCLE_ROUNDED, color="#10B981", size=18),
                    ft.Text("Resultado Generado", weight=ft.FontWeight.BOLD, color="#F8FAFC", size=13),
                ], spacing=6),
                ft.Text("95% Calidad JPEG", size=11, color="#64748B")
            ], alignment=ft.MainAxisAlignment.SPACE_BETWEEN),
            ft.Divider(height=10, color="#1E293B"),
            ft.Container(
                content=result_image,
                alignment=ft.alignment.center,
                bgcolor="#0B0F19",
                border_radius=8,
                padding=6,
            )
        ], spacing=8),
        visible=False,
        padding=12,
        bgcolor="#111827",
        border_radius=12,
        border=ft.border.all(1, "#10B981")
    )

    # -------------------------------------------------------------
    # LÓGICA DE EVENTOS Y PROCESAMIENTO
    # -------------------------------------------------------------
    def set_status(text: str, state: str = "normal"):
        status_label.value = text
        if state == "loading":
            status_icon.name = ft.Icons.HOURGLASS_TOP_ROUNDED
            status_icon.color = "#38BDF8"
            status_card.bgcolor = "#0B2135"
            status_card.border = ft.border.all(1, "#0284C7")
            progress_bar.visible = True
            btn_process.disabled = True
            btn_select.disabled = True
        elif state == "success":
            status_icon.name = ft.Icons.CHECK_CIRCLE_ROUNDED
            status_icon.color = "#10B981"
            status_card.bgcolor = "#062E1F"
            status_card.border = ft.border.all(1, "#059669")
            progress_bar.visible = False
            btn_process.disabled = False
            btn_select.disabled = False
        elif state == "error":
            status_icon.name = ft.Icons.ERROR_OUTLINE_ROUNDED
            status_icon.color = "#F43F5E"
            status_card.bgcolor = "#30131B"
            status_card.border = ft.border.all(1, "#E11D48")
            progress_bar.visible = False
            btn_process.disabled = False
            btn_select.disabled = False
        else:
            status_icon.name = ft.Icons.INFO_OUTLINE_ROUNDED
            status_icon.color = "#94A3B8"
            status_card.bgcolor = "#111827"
            status_card.border = ft.border.all(1, "#1F2937")
            progress_bar.visible = False
            btn_process.disabled = False
            btn_select.disabled = False
        page.update()

    def update_chips():
        files_row.controls.clear()
        
        if active_tab[0] == 0:
            # OPCIÓN 1: FOTOS
            count = len(selected_photo_paths)
            if count == 0:
                badge_counter.content.value = "0 fotos seleccionadas"
                badge_counter.content.color = "#94A3B8"
                badge_counter.border = ft.border.all(1, "#374151")
                files_container.visible = False
                btn_process.disabled = True
            else:
                files_container.visible = True
                is_ready = count >= 2
                badge_counter.content.value = f"✓ {count} fotos listas" if is_ready else f"⚠️ {count} foto (mín. 2)"
                badge_counter.content.color = "#10B981" if is_ready else "#F59E0B"
                badge_counter.border = ft.border.all(1, "#10B981" if is_ready else "#F59E0B")
                btn_process.disabled = not is_ready

                for p in selected_photo_paths:
                    file_name = os.path.basename(p)
                    chip = ft.Container(
                        content=ft.Row([
                            ft.Icon(ft.Icons.IMAGE_OUTLINED, size=14, color="#38BDF8"),
                            ft.Text(file_name, size=11, color="#E2E8F0", max_lines=1, overflow=ft.TextOverflow.ELLIPSIS),
                            ft.IconButton(
                                icon=ft.Icons.CLOSE_ROUNDED,
                                icon_size=12,
                                icon_color="#94A3B8",
                                padding=0,
                                tooltip="Quitar foto",
                                on_click=lambda _, path_to_remove=p: remove_photo(path_to_remove)
                            )
                        ], spacing=4),
                        padding=ft.padding.symmetric(horizontal=8, vertical=3),
                        bgcolor="#1E293B",
                        border_radius=16,
                        border=ft.border.all(1, "#334155")
                    )
                    files_row.controls.append(chip)
        else:
            # OPCIÓN 2: VIDEO
            video_path = selected_video_path[0]
            if not video_path:
                badge_counter.content.value = "Sin video seleccionado"
                badge_counter.content.color = "#94A3B8"
                badge_counter.border = ft.border.all(1, "#374151")
                files_container.visible = False
                btn_process.disabled = True
            else:
                files_container.visible = True
                badge_counter.content.value = "✓ Video listo"
                badge_counter.content.color = "#10B981"
                badge_counter.border = ft.border.all(1, "#10B981")
                btn_process.disabled = False

                file_name = os.path.basename(video_path)
                chip = ft.Container(
                    content=ft.Row([
                        ft.Icon(ft.Icons.MOVIE_OUTLINED, size=14, color="#38BDF8"),
                        ft.Text(file_name, size=11, color="#E2E8F0", max_lines=1, overflow=ft.TextOverflow.ELLIPSIS),
                        ft.IconButton(
                            icon=ft.Icons.CLOSE_ROUNDED,
                            icon_size=12,
                            icon_color="#94A3B8",
                            padding=0,
                            tooltip="Quitar video",
                            on_click=lambda _: clear_video()
                        )
                    ], spacing=4),
                    padding=ft.padding.symmetric(horizontal=8, vertical=3),
                    bgcolor="#1E293B",
                    border_radius=16,
                    border=ft.border.all(1, "#334155")
                )
                files_row.controls.append(chip)

        page.update()

    def remove_photo(path_to_remove: str):
        if path_to_remove in selected_photo_paths:
            selected_photo_paths.remove(path_to_remove)
            update_chips()
            if len(selected_photo_paths) < 2:
                set_status("Selecciona al menos 2 fotos para habilitar la unión.", state="normal")

    def clear_video():
        selected_video_path[0] = None
        update_chips()
        set_status("Video removido. Selecciona un archivo de video para continuar.", state="normal")

    def clear_all(e=None):
        if active_tab[0] == 0:
            selected_photo_paths.clear()
            set_status("Selección de fotos restablecida.", state="normal")
        else:
            selected_video_path[0] = None
            set_status("Selección de video restablecida.", state="normal")
        update_chips()
        result_card.visible = False

    # Selector de archivos
    def pick_photos_result(e: ft.FilePickerResultEvent):
        if e.files:
            for f in e.files:
                if f.path and f.path not in selected_photo_paths:
                    selected_photo_paths.append(f.path)
            update_chips()
            if len(selected_photo_paths) >= 2:
                set_status(f"¡{len(selected_photo_paths)} fotos listas para fusionar! Haz clic en 'Generar Panorámica'.", state="normal")
            else:
                set_status("Se necesita al menos 1 foto más con área solapada.", state="normal")

    def pick_video_result(e: ft.FilePickerResultEvent):
        if e.files and len(e.files) > 0 and e.files[0].path:
            selected_video_path[0] = e.files[0].path
            update_chips()
            set_status("¡Video cargado con éxito! Haz clic en 'Generar Panorámica'.", state="normal")

    photo_picker = ft.FilePicker(on_result=pick_photos_result)
    video_picker = ft.FilePicker(on_result=pick_video_result)
    page.overlay.extend([photo_picker, video_picker])

    # Guardar resultado y procesar
    def save_file_result(e: ft.FilePickerResultEvent):
        if not e.path:
            return

        set_status("⏳ Analizando fotogramas y creando la panorámica...", state="loading")

        if active_tab[0] == 0:
            # Procesar Opción 1: Fotos
            file_objects = []
            try:
                files_payload = []
                for path in selected_photo_paths:
                    f = open(path, "rb")
                    file_objects.append(f)
                    files_payload.append(("files", (os.path.basename(path), f, "image/jpeg")))

                response = requests.post("http://localhost:8000/stitch-images/", files=files_payload, timeout=120)
                handle_response(response, e.path)
            except requests.exceptions.ConnectionError:
                set_status("No se pudo conectar con el servidor (http://localhost:8000).", state="error")
            except Exception as ex:
                set_status(f"Ocurrió un error inesperado: {str(ex)}", state="error")
            finally:
                for f in file_objects:
                    try: f.close()
                    except: pass
                page.update()
        else:
            # Procesar Opción 2: Video
            f = None
            try:
                video_p = selected_video_path[0]
                f = open(video_p, "rb")
                files_payload = {"file": (os.path.basename(video_p), f, "video/mp4")}

                response = requests.post("http://localhost:8000/stitch-video/", files=files_payload, timeout=300)
                handle_response(response, e.path)
            except requests.exceptions.ConnectionError:
                set_status("No se pudo conectar con el servidor (http://localhost:8000).", state="error")
            except Exception as ex:
                set_status(f"Ocurrió un error inesperado: {str(ex)}", state="error")
            finally:
                if f:
                    try: f.close()
                    except: pass
                page.update()

    def handle_response(response, save_path):
        if response.status_code == 200:
            if not (save_path.endswith(".jpg") or save_path.endswith(".jpeg") or save_path.endswith(".png")):
                save_path += ".jpg"

            with open(save_path, "wb") as output_file:
                output_file.write(response.content)

            last_saved_path[0] = save_path

            b64_img = base64.b64encode(response.content).decode("utf-8")
            result_image.src_base64 = b64_img
            result_image.visible = True
            result_card.visible = True

            set_status(f"¡Panorámica creada y guardada en: {os.path.basename(save_path)}! 🎉", state="success")
        else:
            try:
                error_detail = response.json().get("detail", "Error desconocido del servidor")
            except Exception:
                error_detail = response.text or "Error en el servidor backend"
            set_status(f"Error: {error_detail}", state="error")

    save_picker = ft.FilePicker(on_result=save_file_result)
    page.overlay.append(save_picker)

    def trigger_stitching(e=None):
        if active_tab[0] == 0 and len(selected_photo_paths) < 2:
            set_status("Por favor selecciona al menos 2 fotos primero.", state="error")
            return
        if active_tab[0] == 1 and not selected_video_path[0]:
            set_status("Por favor selecciona un video primero.", state="error")
            return

        save_picker.save_file(
            file_name="mi_panoramica.jpg",
            dialog_title="Guardar foto panorámica",
            allowed_extensions=["jpg", "jpeg", "png"]
        )

    def select_source(e=None):
        if active_tab[0] == 0:
            photo_picker.pick_files(
                allow_multiple=True,
                allowed_extensions=["jpg", "jpeg", "png", "webp"],
                dialog_title="Selecciona las fotos contiguas a unir"
            )
        else:
            video_picker.pick_files(
                allow_multiple=False,
                allowed_extensions=["mp4", "mov", "avi", "mkv", "webm"],
                dialog_title="Selecciona el video panorámico"
            )

    # Botones principales
    btn_select = ft.ElevatedButton(
        "Seleccionar Fotos",
        icon=ft.Icons.ADD_PHOTO_ALTERNATE_ROUNDED,
        style=ft.ButtonStyle(
            color="#FFFFFF",
            bgcolor="#0284C7",
            padding=ft.padding.symmetric(horizontal=18, vertical=12),
            shape=ft.RoundedRectangleBorder(radius=10)
        ),
        on_click=select_source,
        expand=True
    )

    btn_process = ft.ElevatedButton(
        "Generar Panorámica",
        icon=ft.Icons.AUTO_AWESOME_ROUNDED,
        disabled=True,
        style=ft.ButtonStyle(
            color="#FFFFFF",
            bgcolor="#10B981",
            padding=ft.padding.symmetric(horizontal=18, vertical=12),
            shape=ft.RoundedRectangleBorder(radius=10)
        ),
        on_click=trigger_stitching,
        expand=True
    )

    # Control de pestañas para cambiar de opción
    def on_tab_change(e):
        active_tab[0] = e.control.selected_index
        result_card.visible = False
        if active_tab[0] == 0:
            btn_select.text = "Seleccionar Fotos"
            btn_select.icon = ft.Icons.ADD_PHOTO_ALTERNATE_ROUNDED
            set_status("Selecciona al menos 2 fotos con solapamiento (30%-40%)", state="normal")
        else:
            btn_select.text = "Seleccionar Video"
            btn_select.icon = ft.Icons.VIDEO_CALL_ROUNDED
            set_status("Selecciona un video paneando horizontalmente la escena", state="normal")
        update_chips()

    tabs_control = ft.Tabs(
        selected_index=0,
        animation_duration=200,
        tabs=[
            ft.Tab(text="Opción 1: Fotos", icon=ft.Icons.PHOTO_LIBRARY_ROUNDED),
            ft.Tab(text="Opción 2: Video", icon=ft.Icons.VIDEO_LIBRARY_ROUNDED),
        ],
        on_change=on_tab_change,
        expand=False
    )

    # Contenedor principal estilo Glassmorphism
    main_card = ft.Container(
        content=ft.Column(
            controls=[
                ft.Row([
                    ft.Container(
                        content=ft.Icon(ft.Icons.PANORAMA_HORIZONTAL_ROUNDED, color="#38BDF8", size=26),
                        padding=10,
                        bgcolor="#1E293B",
                        border_radius=12,
                        border=ft.border.all(1, "#334155")
                    ),
                    ft.Column([
                        ft.Text("PANORAMA STUDIO", size=18, weight=ft.FontWeight.BOLD, color="#F8FAFC"),
                        ft.Text("Fusión inteligente desde fotos o video HD", size=11, color="#94A3B8"),
                    ], spacing=2, expand=True),
                    badge_counter
                ], alignment=ft.MainAxisAlignment.SPACE_BETWEEN),

                ft.Divider(height=10, color="#1E293B"),

                tabs_control,

                progress_bar,

                ft.Row([
                    btn_select,
                    btn_process,
                ], spacing=10),

                files_container,

                ft.Row([
                    ft.TextButton(
                        "Limpiar selección",
                        icon=ft.Icons.DELETE_SWEEP_ROUNDED,
                        style=ft.ButtonStyle(color="#64748B"),
                        on_click=clear_all
                    )
                ], alignment=ft.MainAxisAlignment.END),

                status_card,

                result_card,
            ],
            spacing=14,
            scroll=ft.ScrollMode.ADAPTIVE
        ),
        width=580,
        padding=24,
        bgcolor="#131D2E",
        border_radius=16,
        border=ft.border.all(1, "#202E44"),
        shadow=ft.BoxShadow(
            spread_radius=2,
            blur_radius=24,
            color=ft.Colors.with_opacity(0.45, "#000000"),
            offset=ft.Offset(0, 8)
        )
    )

    page.add(main_card)


if __name__ == "__main__":
    ft.app(target=main)