import socket

from django.db import connection
from django.http import HttpResponse, JsonResponse


def home(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            db_version = cursor.fetchone()[0]
        db_status = f"Connected ✅ — {db_version}"
    except Exception as exc:  # pragma: no cover
        db_status = f"Not connected ❌ — {exc}"

    html = f"""
    <html><head><title>Django + Postgres</title>
    <style>
      body {{ font-family: Arial, sans-serif; background:#092e20; color:#fff;
             display:flex; align-items:center; justify-content:center; height:100vh; margin:0; }}
      .card {{ background:#0c4b33; padding:40px; border-radius:12px; max-width:700px; text-align:center; }}
      h1 {{ color:#44b78b; margin-top:0; }}
    </style></head>
    <body><div class="card">
      <h1>Project 2 is Live 🚀</h1>
      <p>Django + PostgreSQL via <b>Docker Compose</b>, deployed by <b>Jenkins</b>.</p>
      <p><b>Container:</b> {socket.gethostname()}</p>
      <p><b>Database:</b> {db_status}</p>
      <p>Admin: <code>/admin</code> &nbsp;|&nbsp; Health: <code>/health</code></p>
    </div></body></html>
    """
    return HttpResponse(html)


def health(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1;")
        return JsonResponse({"status": "UP", "database": "UP"})
    except Exception:
        return JsonResponse({"status": "DOWN", "database": "DOWN"}, status=503)
