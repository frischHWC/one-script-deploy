--- /tmp/gen_credentials_ipa.sh	2022-02-03 03:05:50.102862982 -0800
+++ gen_credentials_ipa.sh	2022-01-31 05:22:52.944775628 -0800
@@ -49,7 +49,11 @@
   echo "Host $HOST exists"
 else
   echo "Adding new host: $HOST"
-  ipa host-add $HOST
+  if [[ $HOST =~ \. ]]; then
+    ipa host-add $HOST  --force --no-reverse
+  else
+    ipa host-add $HOST.{{ cp_domain }}  --force --no-reverse
+  fi
 fi

 set +e
@@ -62,9 +66,8 @@
 else
   PRINC_EXISTS=no
   echo "Adding new principal: $PRINCIPAL"
-  ipa service-add $PRINCIPAL
+  ipa service-add $PRINCIPAL --force
 fi
-
 # Set the maxrenewlife for the principal, if given. There is no interface
 # offered by the IPA to set it, so we use KADMIN as suggested in a few IPA
 # related forums.