ARG jenkins_tag
FROM jenkins/jenkins:$jenkins_tag
RUN /usr/local/bin/install-plugins.sh scm-api git-client git gradle workflow-aggregator dashboard-view snyk-security-scanner
COPY resources/io.snyk.jenkins.SnykStepBuilder.xml /var/jenkins_home
HEALTHCHECK --interval=10s --timeout=3s CMD curl -f http://localhost:8080/ || exit 1
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
