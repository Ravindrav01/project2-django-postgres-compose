# ---- Django application image ----
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /code

# Install Python dependencies first (layer caching)
COPY requirements.txt /code/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project source
COPY . /code/

RUN chmod +x /code/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/code/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
