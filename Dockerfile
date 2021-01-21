FROM python:3.8-slim-buster as common-base


EXPOSE 80
ENV PYTHONUNBUFFERED=1 \
  PORT=80 \
  POETRY_VERSION=1.1.4


FROM common-base as base-builder
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -U pip && pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org "poetry==$POETRY_VERSION"
RUN mkdir -p /build
WORKDIR /build


FROM base-builder as py-builder
COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt --output requirements.txt
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-warn-script-location -r requirements.txt


FROM py-builder as docs-builder
COPY docs/  docs
COPY mkdocs.yml .
RUN mkdocs build


FROM nginx:alpine
COPY --from=docs-builder /build/site /usr/share/nginx/html