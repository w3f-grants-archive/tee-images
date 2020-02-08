#!/usr/bin/env bash
trap "exit" SIGTERM SIGINT

echo
echo "----------------------------------------"
echo "Zondax STM32-OPTEE container - zondax.ch"
echo "----------------------------------------"
echo

# CUSTOMIZE CONTAINER START UP

bash -c "trap 'exit' SIGTERM SIGINT; $@"
