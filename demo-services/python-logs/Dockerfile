FROM python:3.10.1-slim-bullseye as compile-image

# Install depedencies
ADD requirements.txt /tmp
RUN pip install --no-cache -r /tmp/requirements.txt

FROM python:3.10.1-slim-bullseye as runtime-image

COPY --from=compile-image /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
ADD main.py /opt/main.py

WORKDIR /opt

ENTRYPOINT [ "python" ]
CMD ["main.py"]
