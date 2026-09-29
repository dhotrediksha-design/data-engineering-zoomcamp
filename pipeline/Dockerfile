FROM python:3.13.15-slim

#We can copy uv from other docker impage 
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# Set working directory
WORKDIR /code

# Add virtual environment to PATH so we can use installed packages
ENV PATH="/code/.venv/bin:$PATH"

# Copy dependency files first (better layer caching)
COPY "pyproject.toml" "uv.lock" ".python-version" ./

# Install dependencies from lock file (ensures reproducible builds)
RUN uv sync --locked

#no need to run this packages separately as we are copying uv
#RUN pip install pandas pyarrow

# Copy application code
COPY pipeline.py pipeline.py

# Set entry point
ENTRYPOINT ["python","pipeline.py"]