# stage 1: install dependencies into an isolated venv
FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN python -m venv /venv && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt

# stage 2: lean runtime image — build toolchain not included
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /venv /venv
COPY app.py .
RUN useradd -r -u 1001 appuser
USER appuser
ENV PATH="/venv/bin:$PATH"
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]
