FROM python:3.14


# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive


# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser


# Set work directory
WORKDIR /app


# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# Add entrypoint script to handle migrations and startup
COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh && \
    chown appuser:appuser entrypoint.sh


# Copy project files
COPY MyDjangoSite .


# Create directories with correct permissions
RUN mkdir -p /app/staticfiles && \
    chown -R appuser:appuser /app && \
    chmod -R 755 /app/staticfiles


# Switch to non-root user
USER appuser


# Add healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
        CMD curl -f http://localhost:8000/ || exit 1


# Expose port
EXPOSE 8000


# Use the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]


# CMD ["tail", "-f", "/dev/null"]
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "MyDjangoProject.wsgi"]
