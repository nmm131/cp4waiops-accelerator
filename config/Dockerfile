FROM python
WORKDIR /code
COPY ./config/requirements.sh ./aiops-install-ansible/ ./
RUN ./requirements.sh
CMD ./10_install_ai_manager.sh