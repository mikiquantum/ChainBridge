#!/usr/bin/env bash
# Copyright 2020 ChainSafe Systems
# SPDX-License-Identifier: LGPL-3.0-only


set -e

contract_binding_path="on-chain/evm-contracts/"
base_path="./build/tmp"
BIN_DIR="$base_path/bin"
ABI_DIR="$base_path/abi"
RUNTIME_DIR="$base_path/runtime"
GO_DIR="$base_path/go"

# Remove old bin and abi
echo "Removing old builds..."
rm -rf $base_path
mkdir $base_path
mkdir $ABI_DIR
mkdir $BIN_DIR
mkdir $GO_DIR
mkdir $RUNTIME_DIR

echo "Copying new builds to root..."
cp -r $contract_binding_path/bindings/abi/* $ABI_DIR
cp -r $contract_binding_path/bindings/bin/* $BIN_DIR
cp -r $contract_binding_path/bindings/runtime/* $RUNTIME_DIR

for file in "$BIN_DIR"/*.bin
do
    base=`basename $file`
    value="${base%.*}"
    echo Compiling file $value from path $file

    # Create the go package directory
    mkdir $GO_DIR/$value
    
    # Build the go package
    abigen --abi $ABI_DIR/${value}.abi --pkg $value --type $value --bin $BIN_DIR/${value}.bin --out $GO_DIR/$value/$value.go
    
    # Capture build temp 
    bytecode=`cat ./build/tmp/runtime/Bridge.bin`
    variable="var RuntimeBytecode = '${bytecode}'"
    echo $variable >> $GO_DIR/$value/$value.go
done

# Remove old bindings
rm -rf ./contracts
mkdir ./contracts

# Copy in new bindings
cp -r $GO_DIR/* ./contracts

# cleanup tmp
rm -rf ./build/tmp