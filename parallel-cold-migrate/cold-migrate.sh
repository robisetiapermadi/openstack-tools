#!/usr/bin/env bash

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
log_name="log_$(date -I).log"
summary_name="summary_$(date +%F_%T).csv"


help(){
  # Display Help
  echo "Bash script for parallel cold migrate."
  echo
  echo "Syntax: ./$me"
  echo "options:"
  echo "-h     Print this Help."
  echo "-i     /path/to/instance/list"
  echo "       define path for instance list. Format: separate by newline for every instance id."
  echo "-d     [DESTINATION]"
  echo "       define destination host"
  echo "-n     [INTEGER]"
  echo "       determining the number of parallels"
  echo

}

power_off(){
  #argument $1 : instance-id
  openstack server stop $1
}

power_on(){
  #argument $1 : instance-id
  openstack server start $1
}

check_instance_status(){
  #argument $1 : instance-id
  openstack server show $1 -c status -f value
}

check_migration_status(){
  #argument $1 : instance-id
  openstack server migration list --server $1 -f value -c Status --limit 1
}

cold_migrate(){
  #argument $1 : instance-id
  #argument $2 : destination host
  openstack server migrate --host $2 $1
}

confirm_migration(){
  #argument $1 : instance-id
  openstack server migration confirm $1
}

get_host(){
  #argument $1 : instance-id
  openstack server show $1 -c "OS-EXT-SRV-ATTR:host" -f value
}

full_lifecycle_cold_migration(){
  #argument $1 : instance-id
  #argument $2 : destination host

  echo "start cold-migrate $i in background"

  host_before=`get_host $1`
  destination=$2
  instance_id=$1

  echo "$(date +%FT%T%Z): Powering-off instance $instance_id" >> $log_name

  power_off $instance_id

  while [ "$(check_instance_status $instance_id)" != "SHUTOFF" ]; do 
    echo "$(date +%FT%T%Z): Still Powering-off instance $instance_id" >> $log_name
  done

  echo "$(date +%FT%T%Z): Cold-migrating instance $instance_id" >> $log_name
  cold_migrate $instance_id $destination

  migration_status=$(check_migration_status $instance_id)

  while [ "$migration_status" != "finished" ]; do 
    echo "$(date +%FT%T%Z): $migration_status instance $instance_id" >> $log_name
    migration_status=$(check_migration_status $instance_id)
  done

  confirm_migration $instance_id

  migration_status=$(check_migration_status $instance_id)

  while [ "$migration_status" != "confirmed" ]; do 
    echo "$(date +%FT%T%Z): confirming migration instance $instance_id" >> $log_name
    migration_status=$(check_migration_status $instance_id)
  done

  echo "$(date +%FT%T%Z): migration has confirmed instance $instance_id" >> $log_name

  echo "$(date +%FT%T%Z): Powering-on instance $instance_id" >> $log_name

  power_on $instance_id

  while [ "$(check_instance_status $instance_id)" != "ACTIVE" ]; do 
    echo "$(date +%FT%T%Z): Still Powering-on instance $instance_id" >> $log_name
  done

  echo "$(date +%FT%T%Z): full_lifecycle_cold_migration instance $instance_id Finish" >> $log_name

  host_after=`get_host $instance_id`
  instance_status=`check_instance_status $instance_id`


  if [ "$host_after" == "$destination" ]; then
    echo "cold-migrate $i in background finished"
    echo "$instance_id,$host_before,$host_after,$instance_status,done" >> $summary_name
  else
    echo "cold-migrate $i in background error. Please check manually"
    echo "$instance_id,$host_before,$host_after,$instance_status,fail" >> $summary_name
  fi
}

while getopts ":hi:n:d:" option; do
   case $option in
      h) help
         exit;;
      i) instance_list=$OPTARG;;
      n) parallel=$OPTARG;;
      d) destination_global=$OPTARG;;
     \?) # Invalid option
         echo "error: Invalid option"
         exit;;

   esac
done

if [ -z "$instance_list" ] ; then
        echo 'error: Missing -i' >&2
        exit 1
fi

if [ -z "$destination_global" ] ; then
        echo 'error: Missing -d' >&2
        exit 1
fi



if [ -z "$parallel" ] ; then
        echo 'error: Missing -n' >&2
        exit 1
fi




#process_id=$!

for i in `cat $instance_list`; do
  full_lifecycle_cold_migration $i $destination_global &
  job_count=`jobs -l | wc -l`
  while [ "$job_count" == "$parallel" ]; do 
    wait -n 
    job_count=`jobs -l | wc -l`
  done
done

wait