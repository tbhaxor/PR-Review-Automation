FROM python:3.14-alpine

WORKDIR /app

RUN pip install -U pip --root-user-action ignore
COPY ./requirements.txt ./
RUN pip install -r requirements.txt

COPY ./app.py ./

ENTRYPOINT [ "python" ]

EXPOSE 5000

CMD [ "-m", "gunicorn", "app:app", "--bind", "0.0.0.0:5000" ]