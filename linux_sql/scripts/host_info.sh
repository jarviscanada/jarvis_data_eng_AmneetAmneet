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

#parse hardware specification
hostname=$(hostname -f)
lscpu_out=`lscpu`
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | grep -i "Architecture" | awk -F: '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" |  grep -i "Model name:" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | grep -i "CPU MHz:" | awk -F: '{print $2}' | xargs)
l2_cache=$(echo "$lscpu_out" | grep -i "l2 cache:" | awk -F: '{print $2}' | xargs | sed 's/K//')
total_mem=$(free -k | grep -i "Mem:" | awk '{print $2}' | sed 's/[^0-9]*//g')
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")

# insert host data
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem) \
VALUES ('${hostname}', \
        ${cpu_number}, \
        '${cpu_architecture}', \
        '${cpu_model}', \
        ${cpu_mhz}, \
        ${l2_cache}, \
        '${timestamp}', \
        ${total_mem});"
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$psql_command"
exit $?