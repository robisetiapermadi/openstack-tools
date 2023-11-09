# parallel cold migrate
## How to use
### Getting Started
```
./cold-migrate.sh -h

Bash script for parallel cold migrate.

Syntax: ./cold-migrate.sh
options:
-h     Print this Help.
-i     /path/to/instance/list
       define path for instance list. Format: separate by newline for every instance id.
-d     [DESTINATION]
       define destination host
-n     [INTEGER]
       determining the number of parallels
```

### Example:
instance-list.txt: 
```
6c67737a-180a-4a4d-a35b-70fb366b7acb
7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
8bb930c6-b569-4764-a137-06c440329f21
92a149dc-a072-4fd3-acd7-2a6c34708e02
cb6245ba-c7e8-4fd5-bc21-be2b87b74067
776a89e1-5cfa-4050-9f05-d82ecd282352
```


Cold-migrate the instances in the `instance-list.txt` file to a specific host(in this case to stgpub02hvza19.neo.id) simultaneously with a maximum of 4 jobs:
```
./cold-migrate.sh -i instance-list.txt  -n 4 -d stgpub02hvza19.neo.id
```

After the script has finished running, there will be 2 output files, namely:
- summary file, which contains the status of the instance after being cold-migrated 
```
# Example summary_2023-11-09_16:50:35.csv

id,before,after,instance_status,cold-migrate_status
92a149dc-a072-4fd3-acd7-2a6c34708e02,stgpub02hvza10.neo.id,stgpub02hvza19.neo.id,ACTIVE,done
7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d,stgpub02hvza10.neo.id,stgpub02hvza19.neo.id,ACTIVE,done
8bb930c6-b569-4764-a137-06c440329f21,stgpub02hvza10.neo.id,stgpub02hvza19.neo.id,ACTIVE,done
6c67737a-180a-4a4d-a35b-70fb366b7acb,stgpub02hvza10.neo.id,stgpub02hvza19.neo.id,ACTIVE,done
776a89e1-5cfa-4050-9f05-d82ecd282352,stgpub02hvza10.neo.id,stgpub02hvza19.neo.id,ACTIVE,done
cb6245ba-c7e8-4fd5-bc21-be2b87b74067,stgpub02hvza10.neo.id,stgpub02hvza19.neo.id,ACTIVE,done
```
- log file, which contains the logs during the cold-migration process
```
2023-11-09T16:50:38+07: Powering-off instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:50:38+07: Powering-off instance 8bb930c6-b569-4764-a137-06c440329f21
2023-11-09T16:50:38+07: Powering-off instance 92a149dc-a072-4fd3-acd7-2a6c34708e02
2023-11-09T16:50:38+07: Powering-off instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:50:43+07: Cold-migrating instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:50:43+07: Cold-migrating instance 8bb930c6-b569-4764-a137-06c440329f21
2023-11-09T16:50:43+07: Cold-migrating instance 92a149dc-a072-4fd3-acd7-2a6c34708e02
2023-11-09T16:50:43+07: Cold-migrating instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:50:50+07: post-migrating instance 92a149dc-a072-4fd3-acd7-2a6c34708e02
2023-11-09T16:50:50+07: migrating instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:50:51+07: migrating instance 8bb930c6-b569-4764-a137-06c440329f21
2023-11-09T16:50:52+07: migrating instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:50:53+07: post-migrating instance 92a149dc-a072-4fd3-acd7-2a6c34708e02
2023-11-09T16:50:53+07: post-migrating instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:50:54+07: post-migrating instance 8bb930c6-b569-4764-a137-06c440329f21
2023-11-09T16:50:54+07: post-migrating instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:50:55+07: post-migrating instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:50:56+07: post-migrating instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:51:02+07: migration has confirmed instance 8bb930c6-b569-4764-a137-06c440329f21
2023-11-09T16:51:02+07: Powering-on instance 8bb930c6-b569-4764-a137-06c440329f21
2023-11-09T16:51:02+07: migration has confirmed instance 92a149dc-a072-4fd3-acd7-2a6c34708e02
2023-11-09T16:51:02+07: Powering-on instance 92a149dc-a072-4fd3-acd7-2a6c34708e02
2023-11-09T16:51:03+07: migration has confirmed instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:51:03+07: Powering-on instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d
2023-11-09T16:51:06+07: migration has confirmed instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:51:06+07: Powering-on instance 6c67737a-180a-4a4d-a35b-70fb366b7acb
2023-11-09T16:51:09+07: full_lifecycle_cold_migration instance 8bb930c6-b569-4764-a137-06c440329f21 Finish
2023-11-09T16:51:10+07: full_lifecycle_cold_migration instance 92a149dc-a072-4fd3-acd7-2a6c34708e02 Finish
2023-11-09T16:51:11+07: full_lifecycle_cold_migration instance 7ddc7e4e-c543-40c1-9aea-ac9dc7b0d41d Finish
2023-11-09T16:51:13+07: full_lifecycle_cold_migration instance 6c67737a-180a-4a4d-a35b-70fb366b7acb Finish
2023-11-09T16:51:20+07: Powering-off instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:21+07: Powering-off instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:26+07: Cold-migrating instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:27+07: Cold-migrating instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:34+07: post-migrating instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:34+07: migrating instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:37+07: post-migrating instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:37+07: post-migrating instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:43+07: confirming migration instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:44+07: migration has confirmed instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:44+07: Powering-on instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:46+07: migration has confirmed instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:46+07: Powering-on instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067
2023-11-09T16:51:49+07: Still Powering-on instance 776a89e1-5cfa-4050-9f05-d82ecd282352
2023-11-09T16:51:51+07: full_lifecycle_cold_migration instance cb6245ba-c7e8-4fd5-bc21-be2b87b74067 Finish
2023-11-09T16:51:51+07: full_lifecycle_cold_migration instance 776a89e1-5cfa-4050-9f05-d82ecd282352 Finish
```
