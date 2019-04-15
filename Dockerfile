# docker build -t irisbot_ros .
# docker run -it --rm --name bot irisbot_ros

FROM python
WORKDIR /usr/src


COPY . .

CMD ["python"]
