# docker-flask-webserver

Docker image with **uWSGI** and **Nginx** for running a **Flask** (Python 3.5) web application in a single container.

Image is based of the offical Python image, installs uWSGI and the latest mainline version of Nginx. Both processes run as there own user. Communication between them is established via the socket file `var/run/uwsgi/socket.sock`. The container exposes port `8080` for http communication with Nginx webserver.

**Supervisord** is used to start and monitor uWSGI and Nginx. In case one of the processes the failed to start up multiple times or stopped working in normal operations, supervisord initiates the `supervisord-kill.py` script to stop itself and therefore also stop the container from running. This is done to prevent the container from running when it has entered a non-operable state.

```sh
docker run -p 80:8080 --name flask-webserver -it --rm lmmdock/flask-webserver
```
