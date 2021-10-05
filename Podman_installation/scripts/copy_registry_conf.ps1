cmd /c "Icacls C:\\Users\\$($env:USERNAME)\\.minikube\\machines\\minikube\\id_rsa /Inheritance:r"
scp -i $(minikube ssh-key) -o StrictHostKeyChecking=no C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\registries.conf docker@$(minikube ip):/home/docker/registries.conf
minikube ssh "dos2unix  /home/docker/registries.conf;sudo cp /home/docker/registries.conf /etc/containers/registries.conf"
