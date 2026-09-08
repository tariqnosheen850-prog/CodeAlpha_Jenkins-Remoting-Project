# CodeAlpha_JenkinsRemoting

**CodeAlpha DevOps Internship — Task 2: Jenkins Remoting**

## Objective

Set up Jenkins Remoting to connect remote Jenkins nodes (agents), distribute build loads securely across multiple machines, run jobs on various architectures remotely, and improve security using node isolation.

## Architecture Overview

| Component | Role |
|---|---|
| **Controller (Master)** | Central Jenkins server — hosts the UI, schedules jobs, and manages configuration |
| **Agent (Node)** | Remote machine that connects to the controller and executes build jobs |
| **Remoting Protocol** | Jenkins' built-in TCP-based communication channel between controller and agents |

The controller never runs builds directly on agent-labeled jobs — it delegates execution to agents, which report results back over the remoting channel.

## Setup Steps

### 1. Install the Jenkins Controller
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
sudo apt install jenkins -y
sudo systemctl start jenkins
```
Access the controller at `http://<controller-ip>:8080` and complete the setup wizard (unlock key, recommended plugins, admin user).

### 2. Prepare the Agent Machine
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
sudo useradd -m -s /bin/bash jenkins-agent
```
Java is required on every agent since the Jenkins agent process (`agent.jar`) runs on the JVM.

### 3. Configure SSH-Based Secure Connection
On the agent:
```bash
sudo -u jenkins-agent ssh-keygen -t ed25519 -f /home/jenkins-agent/.ssh/id_ed25519
```
Add the **public key** to `/home/jenkins-agent/.ssh/authorized_keys` on the agent.
Add the **private key** to Jenkins: `Manage Jenkins → Credentials → Add Credentials → SSH Username with private key`.

### 4. Add the Node in Jenkins
`Manage Jenkins → Nodes and Clouds → New Node`

| Field | Value |
|---|---|
| Node name | `agent-linux-x86` (example) |
| Type | Permanent Agent |
| Remote root directory | `/home/jenkins-agent/workspace` |
| Labels | `linux-x86`, `build-node` |
| Launch method | Launch agents via SSH |
| Host | agent's IP address |
| Credentials | the SSH credential added in step 3 |
| Usage | Only build jobs with label matching this node |

Repeat this for additional agents with different labels (e.g. `arm64-node`, `windows-node`) to support multiple architectures.

### 5. Run Jobs on Specific Architectures

See `Jenkinsfile` in this repo — the `agent { label '...' }` directive pins a stage or whole pipeline to a specific node/architecture.

### 6. Node Isolation & Security Measures

| Measure | Purpose |
|---|---|
| Dedicated non-root user (`jenkins-agent`) per machine | Limits blast radius if an agent is compromised |
| SSH key-based auth (no passwords) | Prevents credential brute-forcing |
| Agent-to-controller access control (`Manage Jenkins → Security → Agents`) | Restricts what an agent is allowed to execute on the controller |
| One executor per agent (or limited executors) | Prevents resource contention / abuse |
| Docker-based ephemeral agents (see `Jenkinsfile`) | Full filesystem/process isolation per build, agent destroyed after job |
| Firewall rules restricting agent inbound/outbound traffic | Reduces lateral movement risk |

## Files in this Repository

- `Jenkinsfile` — sample declarative pipeline demonstrating label-based agent selection and a Docker-isolated stage
- `node-config-example.xml` — example exported Jenkins node configuration
- `setup-agent.sh` — script to prepare a fresh agent machine
- `README.md` — this file

## Outcome

This project demonstrates a working Jenkins controller-agent (remoting) setup capable of distributing builds securely across multiple, isolated remote nodes of different architectures.

## Author

Nosheen Tariq — CodeAlpha DevOps Internship
