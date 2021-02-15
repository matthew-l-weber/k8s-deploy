
These files define the use of the https://github.com/cloudposse/bastion
Docker as a bastion host within a k8s cluster. It assumes a node port is
used to expose a external cluster interface for clusterIP subnet access.
The default deploys two replicas and disables two factor.

------------------------------------------
Steps to deploy
------------------------------------------
0) Generate the ConfigMap containing the public key.  It takes an optional
   argument of a authorized_keys file or by default picks up id_rsa.pub and
   then authorized_keys if it exists.
  $ ./gen-cfg-map.sh

1) Edit the yml/02-deploy.yaml to enable duo or google-authenticator (per
   https://github.com/cloudposse/bastion env variables)

2) Apply the yml to create the bastion namespace and pod
  $ kubectl apply -f yml

3) The deployed resources can be tailored in the yml and for the most part
   just reapplied with step 2). To tear down the configuration, run this cmd.
  $ kubectl delete -f yml

   Tear down and re-deploy
  $ kubectl delete -f yml && kubectl apply -f yml

4) Check that you can ssh to the container's IP while on a node.  If this
   works and is the first time, you'll be prompted for a google authenticator
   setup if that was enabled. First find one of the replicas IPs.

  $ kubectl describe pod -n bastion | grep IP:

Annotations:  cni.projectcalico.org/podIP: 192.168.140.93/32
IP:           192.168.140.93
  IP:           192.168.140.93
Annotations:  cni.projectcalico.org/podIP: 192.168.140.92/32
IP:           192.168.140.92
  IP:           192.168.140.92

  $ ssh root@192.168.140.92  # from a node in the cluster

   More details can be found by describing the pod
  $ kubectl describe pod -n bastion

5) Check which node's IP to use for testing it out
  $ kubectl get services -n bastion

NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
bastion-service   NodePort   10.109.107.5   <none>        22:32502/TCP   2m17s

   More details can be found by describing the service
  $ kubectl describe service bastion-service -n bastion

5) Try to ssh to nodeIP:32502 and that's it.


------------------------------------------
FAQ
------------------------------------------
 * Tailoring of the pod, would need `kubectl delete -f yml/02-pod.yaml` and
   then re-apply 2).

 * Get a shell by finding the pod `kubectl get pods -n bastion`
 $ kubectl exec --stdin --tty <pod name> -n bastion -- /bin/bash

 * Checking logs `kubectl logs bastion -n bastion` which should look like
   the following example

     Initializing duo
     Initializing enforcer
     - Enabling Enforcer
     - Enabling Clean Home
     Initializing google-authenticator
     - Enabling Google Authenticator MFA
     Initializing hostname
     Initializing rate-limit
     - Enabling Rate Limits
     - Users will be locked for 300s after 5 failed logins
     - Fail delay of 3000000 micro-seconds
     Initializing secure-proc
     - Locking down /proc
     Initializing slack
     Initializing ssh-audit
     - Enabling SSH Audit Logs
     Initializing ssh-authorized-keys-command
     Initializing ssh-host-key
     Generating public/private rsa key pair.
     Your identification has been saved in /etc/ssh/ssh_host_rsa_key.
     Your public key has been saved in /etc/ssh/ssh_host_rsa_key.pub.
     The key fingerprint is:
     SHA256:<finger printing hash HERE> root@bastion
     The key's randomart image is:
     +---[RSA 2048]----+
     | FOOBAR KEY HERE |
     |                 |
     +----[SHA256]-----+
     Server listening on :: port 22.
     Server listening on 0.0.0.0 port 22.

