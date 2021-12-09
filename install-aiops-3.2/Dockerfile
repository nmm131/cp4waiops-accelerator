FROM python
WORKDIR /code
COPY ./requirements.sh ./aiops-install-ansible/ ./
RUN ./requirements.sh
RUN ./10_install_ai_manager.sh -t $IBM_ENTITLEMENT_KEY