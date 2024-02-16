#!/bin/bash

# Function to find the parent PID of a given PID
get_parent_pid() {
    local pid=$1
    local parent_pid=$(ps -o ppid= -p $pid)
    echo $parent_pid
}

# Function to find the grandparent PID of a given PID
get_grandparent_pid() {
    local pid=$1
    local parent_pid=$(get_parent_pid $pid)
    local grandparent_pid=$(get_parent_pid $parent_pid)
    echo $grandparent_pid
}

# Function to find the PID of a process matching a specific pattern
get_pid_by_pattern() {
    local pattern=$1
    local pid=$(pgrep -f "$pattern")
    echo $pid
}

# Main function to check if grandparent PID of all grandchild PIDs match the PID of a process matching the pattern
check_grandparent_pid_match() {
    local pattern=$1
    local grandchild_pids=$(pgrep -P 1)  # Get all direct child PIDs
    local agent_pid=$(get_pid_by_pattern "$pattern")  # Get the PID of process matching the pattern

    # Loop through each grandchild PID
    for pid in $grandchild_pids; do
        grandparent_pid=$(get_grandparent_pid $pid)
        if [ "$grandparent_pid" != "$agent_pid" ]; then
            echo "Grandparent PID of $pid does not match the PID of process matching pattern '$pattern'"
            return 1
        fi
    done
    echo "Grandparent PID of all grandchild PIDs match the PID of process matching pattern '$pattern'"
    return 0
}

# Usage example
pattern="agent.jar"
check_grandparent_pid_match "$pattern"