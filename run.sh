#!/bin/bash

options=(
    "-v --thread 2 --time 2 --step 1"
    "-v --thread 8 --time 5 --step 5"
    "-v --thread 16 --time 10 --step 10"
    "-v --thread 32 --time 20 --step 50"
)

base_command() {
    ./bin/lab1 "$@"
}

print_verbose_results() {
    for i in "${options[@]}"; 
    do
        time base_command ${i}
        echo "==================================="
    done
}

# save_real_time() {
#     for i in "${options[@]}"; 
#     do
#         { time base_command ${i}; } 2>&1 | grep real >> $1
#     done
# }
# 
# save_real_time output.txt
print_verbose_results
