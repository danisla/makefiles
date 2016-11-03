# Additional args passed to all kubectl commands, example: --namespace default
KUBECTL_ARGS :=

K8S_VERSION ?= 1.4.5

### Executable dependencies
KUBECTL_BIN := $(shell command -v kubectl 2> /dev/null)
kubectl:
ifndef KUBECTL_BIN
	$(error kubectl not found, example install: "curl -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v$(K8S_VERSION)/bin/darwin/amd64/kubectl && chmod +x /usr/local/bin/kubectl")
endif
	$(eval KUBECTL := kubectl $(KUBECTL_ARGS))

# Create by file
$(MANIFESTS)/%.yaml: kubectl
	$(KUBECTL) create -f $@

# Delete by file
$(MANIFESTS)/%.yaml.delete: kubectl
	-$(KUBECTL) delete -f $(@:.delete=)

# Delete pod by name
delete-pod-%: kubectl
	$(KUBECTL) delete pod $*

delete-petset-pods-%: kubectl
	-@for pod in `$(KUBECTL) get pods -l component=$* -o json | jq -r '.items[].metadata.name'`; do make delete-pod-$$pod; done

delete-configmap-%: kubectl
	-$(KUBECTL) delete configmap $*

get-all-pods: kubectl
	$(KUBECTL) get pods --all-namespaces

get-ns: kubectl
	$(KUBECTL) get ns

get-petsets: kubectl
	$(KUBECTL) get petsets

get-pods: kubectl
	$(KUBECTL) get pods

watch-pods: kubectl
	kubectl get pods --all-namespaces -w

describe-pods: kubectl
	$(KUBECTL) describe pods

get-svc: kubectl
	$(KUBECTL) get services

wait-for-pod-%: kubectl
	@while [[ -z `$(KUBECTL) get pods $* -o json | jq 'select(.status.phase=="Running") | true'` ]]; do echo "Waiting for $* pod" ; sleep 2; done

logs-%: kubectl
	$(KUBECTL) logs $*

get-pod-%: wait-for-pod-%
	@echo "$*"

shell-%: wait-for-pod-%
	$(KUBECTL) exec -it $* -- bash

describe-pod-%: wait-for-pod-%
	$(KUBECTL) describe pods $*

describe-petset-%: kubectl
	$(KUBECTL) describe petset $*

scale-petset-%: kubectl
	@CURR=`$(KUBECTL) get petset $* -o json | jq -r '.status.replicas'` ; \
	IN="" && until [ -n "$$IN" ]; do read -p "Enter number of $* replicas (current: $$CURR): " IN; done ; \
	$(KUBECTL) patch petset $* -p '{"spec":{"replicas": '$$IN'}}'

get-pv: kubectl
	$(KUBECTL) get pv

get-pvc: kubectl
	$(KUBECTL) get pvc

describe-pv-%: kubectl
	$(KUBECTL) describe pv $*

describe-pvc-%: kubectl
	$(KUBECTL) describe pvc $*
