FROM sonatype/nexus3:latest

# [Opzionale] Esempio: aggiungi un file di configurazione custom
# COPY nexus-default.properties /opt/sonatype/nexus/etc/

# [Opzionale] Esempio: installa strumenti extra dentro il container
# ATTENZIONE: Nexus usa un'immagine minimale, quindi pacchetti limitati
USER root
RUN microdnf install -y zip unzip && microdnf clean all
USER nexus

# [Opzionale] Plugin custom o script automatici
# COPY my-plugin/ /opt/sonatype/nexus/deploy/

# Porta esposta (default 8081)
EXPOSE 8081

# Entry point (già gestito dalla base image)
