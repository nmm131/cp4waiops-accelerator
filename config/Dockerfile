FROM python
WORKDIR /code
COPY ./config/requirements.sh ./aiops-install-ansible/ ./
RUN ./requirements.sh
RUN ./10_install_ai_manager.sh -t $IBM_ENTITLEMENT_KEY