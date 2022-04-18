--- gen_credentials_ipa.sh_bckup	2022-04-18 05:31:52.925032988 -0700
+++ gen_credentials_ipa.sh	2022-04-18 05:36:05.430521111 -0700
@@ -49,7 +49,11 @@
   echo "Host $HOST exists"
 else
   echo "Adding new host: $HOST"
-  ipa host-add $HOST --force --no-reverse
+  if [[ $HOST =~ \. ]]; then
+    ipa host-add $HOST  --force --no-reverse
+  else
+    ipa host-add $HOST.{{ cp_domain }}  --force --no-reverse
+  fi
 fi

 set +e