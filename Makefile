SHELL := /bin/bash

NVM_SH := /home/hiren/.local/bin/nvm.sh
NVM_USE := . $(NVM_SH) && nvm use

.PHONY: help install update dev build analyze lint lint-fix format test test-watch clean

help:
	@echo "beaver-ui — Project Scaffold Commands"
	@echo ""
	@echo "  make install      Install dependencies"
	@echo "  make update       Update all npm packages"
	@echo "  make dev          Start Vite dev server"
	@echo "  make build        Build for production"
	@echo "  make analyze      Build + generate stats.html bundle treemap"
	@echo "  make lint         Run ESLint"
	@echo "  make lint-fix     Run ESLint with auto-fix"
	@echo "  make format       Format code with Prettier"
	@echo "  make test         Run tests once"
	@echo "  make test-watch   Run tests in watch mode"
	@echo "  make clean        Remove dist/ and node_modules/"
	@echo ""
	@echo "  aviary-ui must be cloned at ../aviary-ui and built before 'make install'."
	@echo "  See README.md for full setup instructions."

install:
	$(NVM_USE) && npm install

update:
	$(NVM_USE) && npm update

dev:
	$(NVM_USE) && npm run dev

build:
	$(NVM_USE) && npm run build

analyze:
	$(NVM_USE) && npm run analyze
	@echo ""
	@echo "✓ Bundle report → stats.html"

lint:
	$(NVM_USE) && npm run lint

lint-fix:
	$(NVM_USE) && npm run lint:fix

format:
	$(NVM_USE) && npm run format

test:
	$(NVM_USE) && npm run test

test-watch:
	$(NVM_USE) && npm run test:watch

clean:
	rm -rf dist node_modules
	@echo "Cleaned"
