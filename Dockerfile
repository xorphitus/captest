FROM tianon/centos

# Install utility packages
RUN yum install -y git vi

# Activate as ssh server
RUN yum install -y openssh-server
RUN service sshd start
RUN echo 'root:hogehoge9' | chpasswd

# Install packages for building ruby
RUN yum install -y openssl-devel tar gcc

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN /usr/local/rbenv/plugins/ruby-build/install.sh

RUN echo export RBENV_ROOT="/usr/local/rbenv"          >> /etc/profile.d/rbenv.sh
RUN echo export PATH="${RBENV_ROOT}/bin:${PATH}"       >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(/usr/local/rbenv/bin/rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN source /etc/profile.d/rbenv.sh

# Install  ruby
RUN /usr/local/rbenv/bin/rbenv install 2.1.2
RUN /usr/local/rbenv/bin/rbenv global  2.1.2
