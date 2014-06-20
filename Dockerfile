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

# Install gems
RUN /usr/local/rbenv/shims/gem -i bundler --no-rdoc --no-ri
RUN /usr/local/rbenv/shims/gem -i passenger --no-rdoc --no-ri --version '=4.0.45'
RUN /usr/local/rbenv/bin/rbenv rehash

# Install apache
RUN yum install -y httpd

# Install passenger module
RUN yum install -y gcc-c++ libcurl-devel httpd-devel
RUN yes | /usr/local/rbenv/shims/passenger-install-apache2-module

RUN echo 'LoadModule passenger_module /usr/local/rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so' >> /etc/httpd/conf.d/passenger.conf
RUN echo '<IfModule mod_passenger.c>'                                      >> /etc/httpd/conf.d/passenger.conf
RUN echo '  PassengerRoot /usr/local/rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/passenger-4.0.45' >> /etc/httpd/conf.d/passenger.conf
RUN echo '  PassengerDefaultRuby /usr/local/rbenv/versions/2.1.2/bin/ruby' >> /etc/httpd/conf.d/passenger.conf
RUN echo '</IfModule>'                                                     >> /etc/httpd/conf.d/passenger.conf
RUN echo '<VirtualHost *:80>'                            >> /etc/httpd/conf.d/passenger.conf
RUN echo '   ServerName 127.0.0.1'                       >> /etc/httpd/conf.d/passenger.conf
RUN echo '   DocumentRoot /var/www/myapp/current/public' >> /etc/httpd/conf.d/passenger.conf
RUN echo '</VirtualHost>'                                >> /etc/httpd/conf.d/passenger.conf

RUN service httpd start
