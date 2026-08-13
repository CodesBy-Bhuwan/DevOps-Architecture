cluster-info:
	kubectl cluster-info

nodes:
	kubectl get nodes

pods:
	kubectl get pods -A

svc:
	kubectl get svc -A

ns:
	kubectl get namespaces

deploy:
	kubectl get deployments -A
