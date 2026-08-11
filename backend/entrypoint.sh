#!/bin/sh
set -e

until python -c "
import django, os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()
from django.db import connection
connection.ensure_connection()
" 2>/dev/null; do
  echo "Waiting for database..."
  sleep 2
done

echo "Database ready."

python manage.py migrate --noinput

# gunicorn does not serve static files the way runserver did; whitenoise serves
# them from STATIC_ROOT, which this populates (needed for the Django admin CSS).
python manage.py collectstatic --noinput

exec gunicorn config.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 3 \
  --timeout 120 \
  --access-logfile - \
  --error-logfile -
