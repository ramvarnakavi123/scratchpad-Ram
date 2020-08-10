# Build an image that can do training and inference in SageMaker
# This is a Python 3 image that uses the nginx, gunicorn, flask stack
# for serving inferences in a stable way.

FROM ubuntu:16.04

MAINTAINER <rama.varnakavi@bkfs.com>


RUN apt-get -y update && apt-get install -y --no-install-recommends \
         wget \
         python3.5 \
         nginx \
		 libgcc-5-dev \
         ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Here we get all python packages.
# There's substantial overlap between scipy and numpy that we eliminate by
# linking them together. Likewise, pip leaves the install caches populated which uses
# a significant amount of space. These optimizations save a fair amount of space in the
# image, which reduces start up time.
RUN wget https://bootstrap.pypa.io/3.3/get-pip.py && python3.5 get-pip.py && \
    pip3 install --upgrade pip grpcio==1.09 tensorflow==2.0.0b1 numpy==1.14.3 scipy scikit-learn==0.19.1 pandas==0.22.0 cloudpickle pytz flask gunicorn && \
        (cd /usr/local/lib/python3.5/dist-packages/scipy/.libs; rm *; ln ../../numpy/.libs/* .) && \
        rm -rf /root/.cache
# gevent skipped


# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the train and serve programs are found when the container is invoked.



# Set up the program in the image
COPY tensorflow /opt/program
WORKDIR /opt/program


RUN chmod +x /opt/program/nginx.conf
RUN chmod +x /opt/program/predictor.py
RUN chmod +x /opt/program/serve
RUN chmod +x /opt/program/wsgi.py

ENTRYPOINT ["echo", "'hello world'"]


