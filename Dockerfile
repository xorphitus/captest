FROM tianon/centos

EXPOSE 22

# Install utility packages
RUN yum install -y git vi

# Activate as ssh server
RUN yum install -y openssh-server
RUN service sshd start

# Install packages for building ruby
RUN yum install -y openssl-devel tar gcc

# Install rbenv and ruby-build
ENV RBENV_ROOT /usr/local/rbenv

RUN git clone https://github.com/sstephenson/rbenv.git ${RBENV_ROOT}
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN /usr/local/rbenv/plugins/ruby-build/install.sh

ENV PATH ${RBENV_ROOT}/bin:${PATH}
RUN eval "$(/usr/local/rbenv/bin/rbenv init -)"

# Install  ruby
RUN ${RBENV_ROOT}/bin/rbenv install 2.1.2
RUN ${RBENV_ROOT}/bin/rbenv global  2.1.2

# Install gems
RUN ${RBENV_ROOT}/shims/gem i bundler --no-rdoc --no-ri
RUN ${RBENV_ROOT}/shims/gem i passenger --no-rdoc --no-ri --version '=4.0.45'
RUN ${RBENV_ROOT}/bin/rbenv rehash

# Install apache
RUN yum install -y httpd

# Install passenger module
RUN yum install -y gcc-c++ libcurl-devel httpd-devel
RUN yes | ${RBENV_ROOT}/shims/passenger-install-apache2-module

RUN echo "LoadModule passenger_module ${RBENV_ROOT}/versions/2.1.2/lib/ruby/gems/2.1.0/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so" >> /etc/httpd/conf.d/passenger.conf
RUN echo '<IfModule mod_passenger.c>'                      >> /etc/httpd/conf.d/passenger.conf
RUN echo "  PassengerRoot ${RBENV_ROOT}/versions/2.1.2/lib/ruby/gems/2.1.0/gems/passenger-4.0.45" >> /etc/httpd/conf.d/passenger.conf
RUN echo "  PassengerDefaultRuby ${RBENV_ROOT}/shims/ruby" >> /etc/httpd/conf.d/passenger.conf
RUN echo '</IfModule>'                                     >> /etc/httpd/conf.d/passenger.conf
RUN echo '<VirtualHost *:80>'                              >> /etc/httpd/conf.d/passenger.conf
RUN echo '  ServerName localhost'                          >> /etc/httpd/conf.d/passenger.conf
RUN echo '  RailsEnv production'                           >> /etc/httpd/conf.d/passenger.conf
RUN echo '  DocumentRoot /var/www/myapp/current/public'    >> /etc/httpd/conf.d/passenger.conf
RUN echo '</VirtualHost>'                                  >> /etc/httpd/conf.d/passenger.conf

RUN service httpd start

# Install packages for gems
RUN yum install -y sqlite-devel

# Stand by for deploy
RUN groupadd deploy
RUN useradd deploy -g deploy
RUN echo 'deploy:hogehoge9' | chpasswd
RUN mkdir /var/www/myapp
RUN chown deploy /var/www/myapp
RUN chgrp deploy /var/www/myapp
