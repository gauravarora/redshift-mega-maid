FROM centos:centos7
MAINTAINER ReturnPath EFP Core <@ReturnPath>

RUN yum clean all && \
    yum -y install epel-release && \
    yum makecache all && \
    yum -y groups mark convert && \
    yum -y groups mark install "Development Tools" && \
    yum -y groups mark convert "Development Tools" && \
    yum -y groupinstall "Development Tools" && \
    yum -y upgrade glibc nscd && \
    yum -y install libffi-devel openssl-devel && \
    yum -y install git python-pip postgresql postgresql-devel python-devel && \
    pip install --upgrade pip && \
    pip install requests[security] && \
    pip install PyGreSQL wheel && \
    yum -y groupremove "Development tools" && \
    yum -y autoremove && \
    git --version || yum -y install git && \
    yum clean all && rm -rf /var/cache/yum

RUN git clone https://github.com/awslabs/amazon-redshift-utils.git /opt/amazon-redshift-utils
ADD ./bin /opt/mega-maid/bin
RUN chmod +x /opt/mega-maid/bin/*
#RUN pip install -r /opt/amazon-redshift-utils/src/requirements.txt

ENV MM_DB_SCHEMA public
ENV MM_DB_PORT 5439
ENV MM_OUTPUT_FILE /dev/stdout
ENV MM_DEBUG True
ENV MM_IGNORE_ERRORS False
ENV MM_SLOT_COUNT 2
ENV MM_MIN_UNSORTED_PCT 5
ENV MM_MAX_UNSORTED_PCT 50
ENV MM_DELETED_PCT 15
ENV MM_STATS_OFF_PCT 10
ENV MM_MAX_TABLE_SIZE_MB 700*1024

ENTRYPOINT ["/bin/sh", "-c", "/opt/mega-maid/bin/analyze-vacuum-schema.sh"]
