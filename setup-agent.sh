#!/bin/bash
# setup-agent.sh
# CodeAlpha DevOps Internship - Task 2: Jenkins Remoting
# Run this on a fresh machine to prepare it as a Jenkins remote agent.

set -e

echo "== Updating packages =="
sudo apt update

echo "== Installing Java (required for Jenkins agent.jar) =="
sudo apt install -y openjdk-17-jdk

echo "== Creating dedicated, unprivileged jenkins-agent user =="
if ! id "jenkins-agent" &>/dev/null; then
    sudo useradd -m -s /bin/bash jenkins-agent
fi

echo "== Generating SSH key pair for secure controller connection =="
sudo -u jenkins-agent mkdir -p /home/jenkins-agent/.ssh
if [ ! -f /home/jenkins-agent/.ssh/id_ed25519 ]; then
    sudo -u jenkins-agent ssh-keygen -t ed25519 -N "" -f /home/jenkins-agent/.ssh/id_ed25519
fi

echo "== Authorizing the generated public key =="
sudo -u jenkins-agent bash -c 'cat /home/jenkins-agent/.ssh/id_ed25519.pub >> /home/jenkins-agent/.ssh/authorized_keys'
sudo chmod 600 /home/jenkins-agent/.ssh/authorized_keys

echo "== Creating remote workspace directory =="
sudo -u jenkins-agent mkdir -p /home/jenkins-agent/workspace

echo "=================================================="
echo "Agent machine is ready."
echo "Next steps:"
echo "1. Copy the PRIVATE key (/home/jenkins-agent/.ssh/id_ed25519) into"
echo "   Jenkins Controller -> Manage Jenkins -> Credentials."
echo "2. Add this machine as a new Node in Manage Jenkins -> Nodes and Clouds,"
echo "   using 'Launch agents via SSH' and the credential above."
echo "=================================================="
