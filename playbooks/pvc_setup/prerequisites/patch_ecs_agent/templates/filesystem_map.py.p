--- a/agents/cmf/src/cmf/monitor/host/filesystem_map.py
+++ b/agents/cmf/src/cmf/monitor/host/filesystem_map.py
@@ -143,7 +143,7 @@
         f.close()
 
       partition_list = []
-      for p in self.get_all_mounted_partitions():
+      for p in self.get_all_mounted_partitions(monitored_fstypes):
         if p.fstype not in monitored_fstypes:
           continue
         if self._device_exclude_regex.match(p.device):
@@ -186,7 +186,7 @@
     stdout,stderr = out.communicate()
     return stdout
 
-  def get_all_mounted_partitions(self):
+  def get_all_mounted_partitions(self, monitored_fstypes):
     try:
       disk_partitions_cmd = 'findmnt -l -o source,fstype,target,options'
       disk_details = self.get_result_from_executed_command(disk_partitions_cmd)
@@ -194,7 +194,9 @@
       disk_partitions_details = []
       for i in range(4,len(disk_details)-1, 4):
         sdisk_details = psutil._common.sdiskpart(device=disk_details[i], mountpoint=disk_details[i+2], fstype=disk_details[i+1], opts=disk_details[i+3])
-        if(sdisk_details.fstype in ['nfs','nfs4']):
+        # skip collecting mounted 'nfs' partition information if agent is configured (using config.ini) to not monitor this fstype.
+        # These have caused RPC timeouts and result in delayed heartbeat response.
+        if (sdisk_details.fstype in monitored_fstypes and sdisk_details.fstype in ['nfs','nfs4']):
           try:
             nfs_remote_connection = sdisk_details.device.split(':')[0]
             cmd_execute = 'rpcinfo -u ' + nfs_remote_connection +' nfs'