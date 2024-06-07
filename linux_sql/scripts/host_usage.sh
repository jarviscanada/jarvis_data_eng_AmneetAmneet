#! /bin/bash

#Setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#validate arguments
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#parse node usage data
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")
memory_free=$(echo "$vmstat_mb" | awk '{print $4}'| tail -n1 | xargs)
cpu_idle=$(echo "$vmstat_mb" | awk 'NR>2 {print $15}')
cpu_kernel=$(echo "$vmstat_mb" | awk 'NR>2 {print $14}')
disk_io=$(echo "$vmstat_mb" | awk 'NR>2 {print $10+$11}')
disk_available=$(df -BM / | awk 'NR==2 {sub(/M/, "", $4); print $4}')

export PGPASSWORD=$psql_password

# insert usage data
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) \
VALUES ('$timestamp', \
        (SELECT id FROM host_info WHERE hostname='$hostname'), \
        '$memory_free', \
        '$cpu_idle', \
        '$cpu_kernel', \
        '$disk_io', \
        '$disk_available');"
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
