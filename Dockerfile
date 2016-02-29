FROM centos:centos7
MAINTAINER ReturnPath EFP Core <@ReturnPath>

RUN yum clean all && \
    yum -y install epel-release && \
    yum makecache all && \
    yum -y groups mark convert && \
    yum -y groups mark install "Development Tools" && \
    yum -y groups mark convert "Development Tools" && \
    yum -y groupinstall "Development Tools" && \
    yum -y install git python-pip postgresql postgresql-devel python-devel && \
    pip install --upgrade pip && \
    pip install requests[security] && \
    pip install PyGreSQL wheel && \
    yum -y groupremove "Development tools" && \
    yum -y autoremove && \
    yum clean all && rm -rf /var/cache/yum

RUN git clone https://github.com/awslabs/amazon-redshift-utils.git /opt/amazon-redshift-utils
RUN pip install -r /opt/amazon-redshift-utils/src/requirements.txt
