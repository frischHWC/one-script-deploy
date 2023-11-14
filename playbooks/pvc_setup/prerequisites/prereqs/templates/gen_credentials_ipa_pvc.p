--- gen_credentials_ipa.sh	2023-01-06 11:00:38.040373706 -0500
+++ gen_credentials_ipa.sh	2023-01-06 11:01:09.517430290 -0500
@@ -37,6 +37,7 @@

 # PRINCIPAL is in the full service/fqdn@REALM format. Parse to determine
 # principal name and host.
+PRINCIPAL=$(echo $PRINCIPAL | sed 's/\.\./\./g')
 PRINC=${PRINCIPAL%%/*}
 HOST=`echo $PRINCIPAL | cut -d "/" -f 2 | cut -d "@" -f 1`