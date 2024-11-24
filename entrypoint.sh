#!/bin/bash

# Exit on error
set -e

# Function to wait for database
wait_for_db() {
    echo "Waiting for database..."
    python manage.py check --database default
    while [ $? -ne 0 ]; do
        echo "Database is unavailable - sleeping"
        sleep 1
        python manage.py check --database default
    done
    echo "Database is up - continuing..."
}

# Wait for database to be ready
wait_for_db

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Create superuser if needed (optional)
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    python manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL || true
fi

# Collect static files if needed
if [ "$DJANGO_COLLECT_STATIC" = "1" ]; then
    echo "Collecting static files..."
    python manage.py collectstatic --noinput
fi

# Execute the main container command
exec "$@"
