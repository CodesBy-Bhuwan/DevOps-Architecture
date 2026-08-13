#########################################
# Inventory
#########################################

ENV ?= dev

INVENTORY = ansible/inventory/$(ENV).ini

PLAYBOOK = ansible/playbooks

#ANSIBLE = ansible-playbook -i $(INVENTORY)

ANSIBLE_CONFIG = ansible/ansible.cfg

ANSIBLE = ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) \
	ansible-playbook -i $(INVENTORY)

VAGRANT_DIR = vagrant

MASTER = master
WORKER1 = worker1
WORKER2 = worker2
