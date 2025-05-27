# Minikube & Kubernetes: Beginner Test Commands

This guide provides a set of basic commands to test your Minikube installation and get familiar with fundamental Kubernetes operations.

---

## 1. Check Your Cluster and Node

* **Command:** `kubectl cluster-info`
    * **Purpose:** Shows basic information about your Kubernetes cluster, including the addresses of the Kubernetes master and other services like KubeDNS.

* **Command:** `kubectl get nodes`
    * **Purpose:** Lists all nodes that are part of your cluster. With Minikube, you will typically see one node named `minikube`.

* **Command:** `kubectl describe node minikube`
    * **Purpose:** Provides detailed information about the `minikube` node, including its status, capacity, allocated resources, labels, taints, and recent events.

---

## 2. Deploy Your First Application (e.g., Nginx Web Server)

You can deploy applications using imperative commands or declarative YAML files.

* **Option A: Using `kubectl create deployment` (Imperative Command - Quick Way)**
    * **Command:**
        ```bash
        kubectl create deployment nginx-deployment --image=nginx:latest
        ```
    * **Purpose:** Creates a new Kubernetes Deployment named `nginx-deployment` that will run containers based on the latest `nginx` image from Docker Hub.

* **Option B: Using a YAML manifest (Declarative Way - Recommended Practice)**
    * **Step 1:** Create a file named `nginx-deployment.yaml` with the following content:
        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: nginx-deployment
        spec:
          replicas: 1      # Start with 1 instance (Pod)
          selector:
            matchLabels:   # How the Deployment finds which Pods to manage
              app: nginx
          template:        # Blueprint for creating the Pods
            metadata:
              labels:
                app: nginx # Pods created from this template will have this label
            spec:
              containers:
              - name: nginx-container # Name of the container within the Pod
                image: nginx:latest   # Docker image to use
                ports:
                - containerPort: 80 # Port the Nginx container exposes
        ```
    * **Step 2:** Apply the YAML file to your cluster:
        * **Command:**
            ```bash
            kubectl apply -f nginx-deployment.yaml
            ```
        * **Purpose:** Creates or updates the resources (in this case, a Deployment) in your cluster based on the definitions in the `nginx-deployment.yaml` file.

---

## 3. Inspect Your Deployment and Pods

After deploying your application, you can inspect its components:

* **Command:** `kubectl get deployments`
    * **Purpose:** Lists all Deployments in the current namespace, showing their desired and current replica counts, and availability.

* **Command:** `kubectl get replicasets` (or `kubectl get rs`)
    * **Purpose:** Lists all ReplicaSets. Deployments manage ReplicaSets to ensure the desired number of Pods are running.

* **Command:** `kubectl get pods` (or `kubectl get po`)
    * **Purpose:** Lists all Pods in the current namespace. Pods are the smallest deployable units and run your containers.
    * **Tip:** Use `kubectl get pods -o wide` to see more details like the Pod's IP address and the node it's scheduled on.

* **Command:** `kubectl describe deployment nginx-deployment`
    * **Purpose:** Shows detailed information about the `nginx-deployment`, including its current status, replica counts, update strategy, associated ReplicaSets, and recent events.

* **Command:** `kubectl describe pod <your-nginx-pod-name>`
    * **Purpose:** Shows detailed information about a specific Pod. Replace `<your-nginx-pod-name>` with an actual Pod name obtained from `kubectl get pods`. This includes its status, IP, controlled-by information, containers, volumes, and events.

* **Command:** `kubectl logs <your-nginx-pod-name>`
    * **Purpose:** Displays the standard output (stdout) logs from a specific Pod. If the Pod has multiple containers, you can specify the container name using the `-c <container-name>` flag.
    * **Tip:** Use `kubectl logs -f <your-nginx-pod-name>` to stream the logs live (follow).

---

## 4. Expose Your Application to Access It

To make your application accessible, you need to create a Kubernetes Service.

* **Command:**
    ```bash
    kubectl expose deployment nginx-deployment --type=NodePort --port=80
    ```
    * **Purpose:** Creates a Service named `nginx-deployment` of type `NodePort`. This Service will route traffic to port 80 on the Pods managed by `nginx-deployment`. `NodePort` makes the service accessible on a static port on the IP address of your Minikube node.

* **Command:** `kubectl get services` (or `kubectl get svc`)
    * **Purpose:** Lists all Services in the current namespace, showing their type, cluster IP, external IP (if applicable), and ports.

* **Command:** `minikube service nginx-deployment`
    * **Purpose:** (Minikube specific) This convenient command retrieves the URL for the `nginx-deployment` service and usually attempts to open it in your default web browser.

---

## 5. Scale Your Application

You can easily change the number of running instances (Pods) of your application.

* **Command:**
    ```bash
    kubectl scale deployment nginx-deployment --replicas=3
    ```
    * **Purpose:** Changes the desired number of replicas for the `nginx-deployment` to 3. Kubernetes will then create or delete Pods to match this new count.

* **Verify:** Run `kubectl get pods` again to see that there are now 3 `nginx-deployment` pods running or being created.

---

## 6. Update Your Application (Simulate a Rolling Update)

Kubernetes can perform rolling updates to deploy a new version of your application with zero downtime.

* **Command:**
    ```bash
    kubectl set image deployment/nginx-deployment nginx-container=nginx:1.25.0
    ```
    * **Purpose:** Updates the image of the container named `nginx-container` (as defined in your Deployment's Pod template) within the `nginx-deployment` to use the `nginx:1.25.0` image. This triggers a rolling update strategy by default.
    * **Note:** If you used `kubectl create deployment`, the container name might default to the deployment name (e.g., `nginx-deployment`). You can check the actual container name using `kubectl describe deployment nginx-deployment`.

* **Command:** `kubectl rollout status deployment/nginx-deployment`
    * **Purpose:** Monitors the progress of the rolling update for the specified deployment.

* **Tip:** Use `kubectl get pods -w` (watch mode) to see new pods being created with the updated image and old pods being terminated.

---

## 7. Access a Pod Directly (Get a Shell Inside a Container)

For debugging or inspection, you can get a shell directly inside a running container.

* **Command:**
    ```bash
    kubectl exec -it <your-nginx-pod-name> -- /bin/bash
    ```
    * **Purpose:** Opens an interactive terminal session (`-it`) and executes the `/bin/bash` command inside the specified Pod.
    * **Note:** Replace `<your-nginx-pod-name>` with an actual Pod name. If `/bin/bash` is not available in the container, try `/bin/sh`. Type `exit` to leave the Pod's shell.

---

## 8. Clean Up Your Test Application

It's good practice to remove resources you no longer need.

* **Delete the Service:**
    * **Command:**
        ```bash
        kubectl delete service nginx-deployment
        ```

* **Delete the Deployment (this also deletes its ReplicaSets and Pods):**
    * **Command:**
        ```bash
        kubectl delete deployment nginx-deployment
        ```

* **Alternative (if you created resources using a YAML file):**
    * **Command:**
        ```bash
        kubectl delete -f nginx-deployment.yaml
        ```
    * **Purpose:** Deletes all resources that were defined in the `nginx-deployment.yaml` file.

---

## 9. Explore Minikube Addons

Minikube comes with several helpful addons.

* **Command:** `minikube addons list`
    * **Purpose:** Lists all available Minikube addons and shows their current status (enabled or disabled).

* **Command:** `minikube addons enable dashboard`
    * **Purpose:** Enables the Kubernetes Dashboard addon, which provides a web-based UI for your cluster.

* **Command:** `minikube dashboard`
    * **Purpose:** Opens the Kubernetes Dashboard in your default web browser.

---

## Stopping Minikube

When you're done experimenting:

* **To stop the Minikube cluster (preserves the cluster's state and data for the next session):**
    * **Command:**
        ```bash
        minikube stop
        ```
    * **Purpose:** Shuts down the Minikube virtual machine or container, freeing up system resources like CPU and RAM. Your deployed applications and configurations within Minikube are saved. You can restart it later with `minikube start`.

* **To delete the Minikube cluster entirely (removes all state and data):**
    * **Command:**
        ```bash
        minikube delete
        ```
    * **Purpose:** Completely removes the Minikube cluster and all associated files and disk images. Use this if you want a completely fresh start next time or to free up significant disk space. The next `minikube start` will create a brand new cluster.

---