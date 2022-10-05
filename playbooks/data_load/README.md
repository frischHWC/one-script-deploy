# Data generator and loading

Intent of this project is to provide ansible scripts to automate the data generation and loading into different services of a CDP cluster (HDFS, HBase, Hive, Ozone, Kafka, Kudu, SolR).
It is designed to be flexible by letting the user choose which data to generate, to which services, and user-friendly by setting a minimum of configuration while letting the user configure as much as wanted, in a single configuration file.

## Design

All configurations are expected to be set in the extra_vars.yml file.

There are three playbooks that could run independently but are in fact tied together by some variables used from one playbook to the other.

### Auto-configure

Using CM, this playbook catches all required configurations to launch generation of data.
Its goal is to facilitate configuration required by each service to generate by picking up as much as it can configurations.

### Ranger Policies

This playbook aims at pushing required policies for data generation into Ranger, in order to avoid rights possible problems.

### Generate Data

This playbook generates random data by launching multiple times a random-datagen program.


## How to launch it ?


Run the below command:

    ansible-playbook -i <PATH_TO_HOSTS_FILE> main.yml --extra-vars "@extra_vars.yml"

