# JAC Playground - Interactive JAC Language Development Environment
#
# This Dockerfile builds the JAC Playground application with Jaseci dependencies
# installed from the official jaseci-labs/jaseci GitHub repository.
#
# Build:
#   docker build -t jac-playground:latest .
#
# Run:
#   docker run -p 8000:8000 jac-playground:latest

FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    python3-gdbm \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (includes npm) for client-side dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && node -v && npm -v

# Install jaclang and jac-client from PyPI
RUN pip install --no-cache-dir jaclang jac-client

# Install additional Python dependencies
RUN pip install --no-cache-dir python-dotenv

# Copy application code
COPY jac_playground /app

# Install client-side npm dependencies
RUN jac add --cl

# Install project dependencies from jac.toml (this also ensures plugins are loaded)
RUN jac install

# Clean up unnecessary files but keep jac and jac-client sources
# They contain .jac and .impl.jac files needed at runtime
RUN rm -rf /tmp/jaseci/jac-byllm /tmp/jaseci/jac-streamlit /tmp/jaseci/jac-scale \
    /tmp/jaseci/docs /tmp/jaseci/.git /tmp/jaseci/.github

# Set environment variables
ENV PORT=8000
ENV HOST=0.0.0.0
ENV DEBUG=false
ENV LOG_LEVEL=info
ENV PYTHONUNBUFFERED=1

# Create non-root user for security
RUN useradd -m -u 1000 appuser \
    && chown -R appuser:appuser /app

USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Run the application
CMD ["jac", "serve", "src/app.jac"]
