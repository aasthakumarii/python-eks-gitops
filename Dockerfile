FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --disable-pip-version-check -r requirements.txt \
    && addgroup -S -g 10001 app \
    && adduser -S -D -H -u 10001 -G app app

COPY app ./app

USER app

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "4", "--access-logfile", "-", "--error-logfile", "-", "app.main:app"]
