# JAC Playground - Interactive JAC Language Development Environment

FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl ca-certificates python3-gdbm unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x for client-side dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Jac packages from PyPI
RUN pip install --no-cache-dir jaclang==0.10.5 jac-client==0.2.19 jac-scale==0.1.11

# Install Bun to /usr/local so it's accessible to all users
RUN curl -fsSL https://bun.sh/install | bash && \
    mv /root/.bun/bin/bun /usr/local/bin/bun && \
    chmod +x /usr/local/bin/bun

# Copy application code and build scripts
COPY jac_playground /app
COPY scripts/bundle_jaclang.py /tmp/bundle_jaclang.py

# Build jaclang.zip for Pyodide (browser-side JacLang, no llvmlite/native)
RUN python /tmp/bundle_jaclang.py -o /app/assets/jaclang.zip && \
    rm -f /tmp/bundle_jaclang.py

# Install client-side npm and project dependencies
RUN jac clean -a -f && jac add --npm && jac install

ENV PORT=8000 \
    HOST=0.0.0.0 \
    DEBUG=false \
    LOG_LEVEL=info \
    PYTHONUNBUFFERED=1

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

CMD ["jac", "start"]
