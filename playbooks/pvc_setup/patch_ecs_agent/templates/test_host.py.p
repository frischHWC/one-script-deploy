--- a/agents/cmf/src/cmf_test/monitor/test_host.py
+++ b/agents/cmf/src/cmf_test/monitor/test_host.py
@@ -493,7 +493,7 @@
                              local_filesystem_whitelist,
                              fstypes_info_proc_file)
 
-    def get_all_mounted_partitions(self):
+    def get_all_mounted_partitions(self, monitored_nodev_fstypes):
       retlist = []
       retlist.append(sdiskpart('/dev/sda1', '/', 'ext2', 'rw'))
       retlist.append(sdiskpart('/dev/sda2', '/windows', 'vfat', 'rw'))