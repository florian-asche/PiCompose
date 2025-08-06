#!/bin/bash
################################################################################
# PiCompose - Docker-Compose-Manager                                           #
## This script searches the /compose directory for Docker Compose files        #
## and deploys them automatically.                                             #
################################################################################
# OpenSource found here: https://github.com/florian-asche/PiCompose            #
################################################################################

# Variables
base_path="/compose"

# pass variables to subshell
set -a

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [PiCompose] $1" | tee -a /var/log/picompose.log
}

# colors
function colors() {
    BLACK="\033[0;30m"
    BLUE="\033[0;34m"
    GREEN="\033[0;32m"
    CYAN="\033[0;36m"
    RED="\033[0;31m"
    PURPLE="\033[0;35m"
    BROWN="\033[0;33m"
    LIGHT_GRAY="\033[0;37m"
    DARK_GRAY="\033[1;30m"
    LIGHT_BLUE="\033[1;34m"
    LIGHT_GREEN="\033[1;32m"
    LIGHT_CYAN="\033[1;36m"
    LIGHT_RED="\033[1;31m"
    LIGHT_PURPLE="\033[1;35m"
    YELLOW="\033[1;33m"
    WHITE="\033[1;37m"
    NO_COLOUR="\033[0m"
    BLINK="\e[5m"
    NO_BLINK="\e[25m"
}

# load colors lib
colors

# Function to check if Docker is running
wait_for_docker() {
    log "Waiting for Docker service..."
    local timeout=90
    local elapsed=0
    local interval=1

    while ! systemctl is-active --quiet docker; do
        sleep $interval
        elapsed=$((elapsed + interval))
        if [ $elapsed -ge $timeout ]; then
            log "Timeout reached while waiting for Docker. Exiting."
            exit 1
        fi
    done

    # Additional time to ensure Docker is fully started
    sleep 5
    log "Docker is active"
}

# Function to set up cron jobs for re-deployments
setup_cron() {
    local folder="$1"
    local config_file="$folder/picompose.conf"
    
    if [ -f "$config_file" ]; then
        # Read configuration from file
        source "$config_file"
        
        # If CRON_ENABLED is enabled and CRON_SCHEDULE is defined
        if [ "$CRON_ENABLED" = "true" ] && [ -n "$CRON_SCHEDULE" ]; then
            local cron_job="$CRON_SCHEDULE /usr/local/bin/compose-manager.sh redeploy $folder > /dev/null 2>&1"
            
            # Create a cron job
            log "Creating cron job for $folder: $CRON_SCHEDULE"
            (crontab -l 2>/dev/null | grep -v "$folder" || true; echo "$cron_job") | crontab -
        fi
    else
        log "Configuration for $folder missing"
        return 1
    fi
}

# Function to clean up cron jobs
cleanup_cron() {
    log "Cleaning up old cron jobs"
    (crontab -l 2>/dev/null | grep -v "/usr/local/bin/compose-manager.sh redeploy" || true) | crontab -
}

# Function to deploy a Docker Compose project
deploy_compose() {
    local folder="$1"
    local config_file="$folder/picompose.conf"
    
    log "Deploying Docker Compose project $folder"
    
    if [ -f "$config_file" ]; then
        # Read configuration from file
        source "$config_file"

        # Change to the project directory
        cd "$folder"
        
        # Check if a docker-compose.yml exists
        if [ ! -f "docker-compose.yaml" ] && [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yaml" ] && [ ! -f "compose.yml" ]; then
            log "No compose yaml file found in $folder. Skipping."
            return 1
        fi
        
        # Download latest image
        if [ "$CRON_IMAGE_PULL" = "true" ] || [ "$BOOT_IMAGE_PULL" = "true" ]; then
            # Stop and remove existing containers if present
            log "Stopping existing containers if present"
            docker compose down --remove-orphans || true

            log "Downloading new docker images"
            docker compose pull
        fi

        # set some environment variables
        export HOSTNAME=$(hostname)

        # Start Docker Compose
        log "Starting Docker Compose"
        if docker compose up -d; then
            log "Deployment of $folder successful"
            return 0
        else
            log "Error deploying $folder"
            return 1
        fi
    else
        log "Configuration for $folder missing"
        return 1
    fi
}

# Function to search for docker-compose projects
scan() {    
    # Check if /boot/firmware exists, if not, try /boot
    if [ ! -d "$base_path" ]; then
        log "No $base_path found!"
        return 1
    fi
        
    # Search the Compose directory for subdirectories
    log "Searching for Docker Compose projects in $base_path"
    found_projects=0
    
    for dir in "$base_path"/*/; do
        if [ -d "$dir" ]; then
            log "Found project: $dir"
            ((found_projects++))

            setup_cron "$dir"

            if [ "$runs_on_boot" = "true" ] && [ "$BOOT_ENABLED" != "true" ]; then
                log "Run on boot is disabled, deployment of $dir skipped!"
                continue
            else
                deploy_compose "$dir"
            fi
        fi
    done
    
    log "Total of $found_projects projects found and processed"
}

# help output
function usage() {
    local program=$0
    echo -e "Usage: \t $program [redeploy <SPECIFIC_PROJECT/DIRECTORY>] [boot] [help]"
    echo -e "Example: $program"
    echo -e ""
    echo -e "Optional:"
    echo -e "redeploy <SPECIFIC_PROJECT/DIRECTORY>\tDeploy only a specific project by directory name"
    echo -e "boot \t\t\t\t\tScript runs like it whould on a boot. With specific project based settings"
    #echo -e "-c \t\t\t\tEnable Colors"
    #echo -e "-v \t\t\t\tEnable Verbose"
    #echo -e "-y \t\t\t\tAutomatically answer all questions with yes, use with caution"
    #echo -e ""
    #echo -e "-d\t\t\t\tdebug mode"
    echo -e "help\t\t\t\t\thelp output"
    echo -e ""

    echo -e "Please report any bugs or problems to https://github.com/florian-asche/PiCompose/issues"
    exit 10
}

# Main function
main() {
    log "PiCompose - Docker Compose Manager starting"
        
    # Depending on the parameter passed
    case "$1" in
        redeploy)
        # Redeploy specific project
            # Wait until Docker has started
            wait_for_docker

            # Redeploy a specific project
            deploy_compose "$base_path/$2"
            ;;
        boot)
        # Runs only on boot
            # set variable if this script runs on boot
            runs_on_boot=true

            # Wait until Docker has started
            wait_for_docker

            # Clean up old cron jobs before creating new ones
            cleanup_cron
            # Scan the boot partition for Compose projects
            scan
            ;;
        help)
        # Output the help text
            usage
            ;;
        *)
        # Default run
            # Wait until Docker has started
            wait_for_docker

            # Clean up old cron jobs before creating new ones
            cleanup_cron
            # Scan the boot partition for Compose projects
            scan
            ;;
    esac
    
    log "PiCompose - Docker Compose Manager finished"
}

# Start main function with passed parameters
main "$@"
