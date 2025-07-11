#!/bin/sh

# This script is designed to run inside the keepalived container
# to check the health of a MariaDB Galera node running with host networking

# MariaDB connection parameters
MARIADB_USER=${MARIADB_USER:-"root"}
MARIADB_PASSWORD=${MARIADB_ROOT_PASSWORD:-"root"}
# Using localhost since both containers use host networking
MARIADB_HOST=${MARIADB_HOST:-"localhost"}
MARIADB_PORT=${MARIADB_PORT:-"3306"}

# Function to check if we can connect to MySQL
check_mysql_connection() {
    mariadb-admin -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" -h"$MARIADB_HOST" -P"$MARIADB_PORT" ping &>/dev/null
    return $?
}

# Function to get Galera status
check_galera_status() {
    local wsrep_status
    local wsrep_cluster_status
    local wsrep_connected
    local wsrep_ready

    if ! wsrep_status=$(mariadb -uroot -p"$MARIADB_PASSWORD" -h"$MARIADB_HOST" -P"$MARIADB_PORT" -N -e "SHOW STATUS LIKE 'wsrep_%'" 2>/dev/null); then
        echo "Error: Cannot query Galera status"
        return 1
    fi

    # Extract key metrics
    wsrep_cluster_status=$(echo "$wsrep_status" | grep -w "wsrep_cluster_status" | awk '{print $2}')
    wsrep_connected=$(echo "$wsrep_status" | grep -w "wsrep_connected" | awk '{print $2}')
    wsrep_ready=$(echo "$wsrep_status" | grep -w "wsrep_ready" | awk '{print $2}')

    # Check if node is healthy
    if [ "$wsrep_cluster_status" = "Primary" ] && [ "$wsrep_connected" = "ON" ] && [ "$wsrep_ready" = "ON" ]; then
        echo "Galera node is healthy"
        return 0
    # Check if node is in transition
    elif [ "$wsrep_connected" = "ON" ] && [ "$wsrep_ready" = "OFF" ]; then
        echo "Galera node is in transition state"
        return 2
    else
        echo "Galera node is unhealthy"
        return 1
    fi
}

# Main execution
if ! check_mysql_connection; then
    echo "Error: Cannot connect to MySQL"
    exit 1
fi

check_galera_status
exit $?

