FROM python:3.10 as base

WORKDIR /app

COPY ./src ./
COPY ./requirements ./requirements

FROM base as test
RUN pip install -r /app/requirements/test.pip
CMD ["python", "-m", "pytest"]

FROM base as production
RUN pip install -r /app/requirements/prod.pip

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0", "whats_my_ip.application:app"]