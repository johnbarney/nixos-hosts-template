SHELL := /usr/bin/env bash

HOST ?= $(shell (hostnamectl --static 2>/dev/null || hostname -s 2>/dev/null || true) | tr -d '\n')
ifeq ($(strip $(HOST)),)
HOST := example-desktop
endif
ISO_PACKAGE ?= installer-iso
ISO_OUTPUT_DIR ?= ./result/iso
ETC_NIXOS ?= /etc/nixos
BACKUP_DIR ?= /etc/nixos.bak
CRYPTROOT_DEVICE ?= /dev/disk/by-partlabel/cryptroot
REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_FLAKE := path:$(REPO_DIR)
ETC_NIXOS_FLAKE := path:$(ETC_NIXOS)

.PHONY: help check build-iso iso-path iso-sha switch test-switch update-lock update-base post-install-backup post-install-copy-hw post-install-link post-install-switch post-install-cryptenroll post-install-all

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9._-]+:.*## ' $(MAKEFILE_LIST) | sed 's/:.*## /: /' | sort

check: ## Run flake checks (no build)
	nix flake check --no-build "$(REPO_FLAKE)"

build-iso: ## Build installer ISO
	@set -euo pipefail; \
	mkdir -p "$(ISO_OUTPUT_DIR)"; \
	out_path="$$(nix build "$(REPO_FLAKE)#$(ISO_PACKAGE)" -L --no-link --print-out-paths)"; \
	cp -f "$$out_path"/iso/*.iso "$(ISO_OUTPUT_DIR)/"; \
	chmod u+w "$(ISO_OUTPUT_DIR)"/*.iso; \
	$(MAKE) iso-sha

iso-path: ## Print built ISO path(s)
	@ls -1 "$(ISO_OUTPUT_DIR)"/*.iso

iso-sha: ## Print SHA256 for built ISO(s)
	sha256sum "$(ISO_OUTPUT_DIR)"/*.iso

switch: ## Rebuild and switch current system for HOST (uses sudo)
	sudo nixos-rebuild switch --flake "$(REPO_FLAKE)#$(HOST)"

test-switch: ## Build and test switch for HOST (uses sudo)
	sudo nixos-rebuild test --flake "$(REPO_FLAKE)#$(HOST)"

update-lock: ## Update flake inputs
	nix flake update

update-base: ## Update dendritic public base input only
	nix flake update dendritic

post-install-backup: ## Backup /etc/nixos to /etc/nixos.bak (uses sudo)
	sudo mv $(ETC_NIXOS) $(BACKUP_DIR)

post-install-copy-hw: ## Copy generated hardware config from backup into current repo
	mkdir -p "$(REPO_DIR)/hosts/$(HOST)"
	cp "$(BACKUP_DIR)/hosts/$(HOST)/hardware-configuration.nix" "$(REPO_DIR)/hosts/$(HOST)/hardware-configuration.nix"

post-install-link: ## Symlink /etc/nixos to current repo (uses sudo)
	sudo ln -sfn "$(REPO_DIR)" "$(ETC_NIXOS)"

post-install-switch: ## Rebuild and switch from /etc/nixos for HOST (uses sudo)
	sudo nixos-rebuild switch --flake "$(ETC_NIXOS_FLAKE)#$(HOST)"

post-install-cryptenroll: ## Enroll TPM2 unlock for cryptroot (uses sudo)
	sudo systemd-cryptenroll --tpm2-device=auto "$(CRYPTROOT_DEVICE)"

post-install-all: post-install-backup post-install-copy-hw post-install-link post-install-switch post-install-cryptenroll ## Run full post-install migration flow
