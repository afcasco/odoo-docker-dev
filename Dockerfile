FROM python:3.10

# Env & Arg variables
ARG USERNAME=pythonssh
ARG USERPASS=sshpass

# Apt update & apt install required packages
# whois: required for mkpasswd
RUN apt update && apt -y install openssh-server whois git python3-pip wget python3-dev python3-venv python3-wheel libxml2-dev libpq-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libjpeg-dev libblas-dev libatlas-base-dev

# Add a non-root user & set password
RUN useradd -ms /bin/bash $USERNAME
# Save username on a file ¿?¿?¿?¿?¿?
#RUN echo "$USERNAME" > /.non-root-username

# Set password for non-root user
RUN usermod --password $(echo "$USERPASS" | mkpasswd -s) $USERNAME

# Remove no-needed packages
RUN apt purge -y whois && apt -y autoremove && apt -y autoclean && apt -y clean

# Clone odoo sources
RUN git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 odoo15

# Copy odoo.conf
COPY odoo.conf ./odoo15/odoo.conf

# Create custom addons dir
RUN mkdir ./odoo15/odoo-custom-addons

# Set permissions
RUN chown -R pythonssh:pythonssh ./odoo15

# Change to non-root user
#USER $USERNAME
#WORKDIR /home/$USERNAME

# Copy the entrypoint
COPY entrypoint.sh entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create the ssh directory and authorized_keys file
USER $USERNAME
RUN mkdir /home/$USERNAME/.ssh && touch /home/$USERNAME/.ssh/authorized_keys
USER root

# Set volumes
VOLUME /home/$USERNAME/.ssh
VOLUME /etc/ssh

# Run entrypoint
CMD ["/entrypoint.sh"]