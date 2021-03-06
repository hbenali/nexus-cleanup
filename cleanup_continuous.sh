#!/bin/bash -eu
# This script removes old continuous deployment releases
#####
# Internal: Sort Continuous release according to their suffixes (date)
do_sort_continuous_releases() {
    arr=($@)
    # Well old school to sort array :p
    for ((i = 0; i < $#; i++)); do
        for ((j = 0; j < ${#arr[@]} - i - 1; j++)); do
            if [ $(date -d $(do_correct_date_format ${arr[j]}) +"%s") -lt $(date -d $(do_correct_date_format ${arr[$((j + 1))]}) +"%s") ]; then
                temp=${arr[j]}
                arr[$j]=${arr[$((j + 1))]}
                arr[$((j + 1))]=$temp
            fi
        done
    done
    echo ${arr[@]}
}
# Internal: Format Continuous release suffix to Date Format
do_correct_date_format() {
    local dt=$(echo $1 | cut -d '-' -f2)
    echo ${dt:4:4}-${dt:2:2}-${dt:0:2}
}

get_suffix() {
    echo $1 | cut -d '-' -f2
}

do_delete_curl() {
    curl -u $NEXUS_ADMIN:$NEXUS_PASSWORD -X "DELETE" -w "%{http_code}" "$NEXUS_URL/$1"
}

NB_RELEASES_TO_KEEP=0
BASE_PATH=/srv/nexus/storage/hosted

######################
##Modules
GATEIN_DEP=2.2.0
MAVEN_DEPMGT_POM=19.0
GATEIN_WCI=6.2.0
KERNEL=6.2.0
CORE=6.2.0
WS=6.2.0
GATEIN_PC=6.2.0
GATEIN_SSO=6.2.0
GATEIN_PORTAL=6.2.0
PLATFORM_UI=6.2.0
COMMONS=6.2.0
SOCIAL=6.2.0
GAMIFICATION=2.2.0
KUDOS=2.2.0
PERK_STORE=2.2.0
WALLET=2.2.0
APP_CENTER=2.2.0
PUSH_NOTIFICATIONS=2.2.0
EXO_ES_EMBEDDED=3.2.0
ADDONS_MANAGER=2.2.0
MEEDS=1.2.0
WIKI=6.2.0
JCR=6.2.0
ECMS=6.2.0
AGENDA=1.1.0
CHAT_APPLICATION=3.2.0
CMIS_ADDON=6.2.0
DATA_UPGRADE=6.2.0
DIGITAL_WORKPLACE=1.2.0
LAYOUT_MANAGEMENT=1.2.0
NEWS=2.2.0
ONLYOFFICE=2.2.0
REMOTE_EDIT=3.2.0
SAML2_ADDON=3.2.0
SPNEGO_ADDON=3.2.0
TASK=3.2.0
WEB_CONFERENCING=2.2.0
JITSI=1.1.0
ANALYTICS=1.1.0
PLATFORM_PRIVATE_DISTRIBUTIONS=6.2.0
######

releases=($(do_sort_continuous_releases $(curl -s "https://repository.exoplatform.org/content/groups/public/org/exoplatform/gatein/gatein-dep/maven-metadata.xml" |
    grep "<version>.*</version>" |
    sort --version-sort | uniq |
    sed -e "s#\(.*\)\(<version>\)\(.*\)\(</version>\)\(.*\)#\3#g" | grep -P ^$GATEIN_DEP-202102[0-9][0-9]$ | xargs)))
echo "Available releases are:"
echo ${releases[@]}
if [ ${#releases[@]} -le $NB_RELEASES_TO_KEEP ]; then
    echo "Releases number (${#releases[@]}) does not exceed the maximum quota ($NB_RELEASES_TO_KEEP). Nothing to do."
    exit 0
fi
echo "OK, Let's start the cleanup! :-)"
releases_to_be_dropped=("${releases[@]:$NB_RELEASES_TO_KEEP}")
echo "Releases to be dropped are:"
echo ${releases_to_be_dropped[@]}
counter=1
for release in ${releases_to_be_dropped[@]}; do
    rel_suffix=$(get_suffix $release)
    echo "==========================================================================================="
    echo " ($counter/${#releases_to_be_dropped[@]}) Dropping Release:  $PLATFORM_PRIVATE_DISTRIBUTIONS-$rel_suffix..."
    echo "==========================================================================================="
    echo "gatein-dep:$GATEIN_DEP-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/gatein/gatein-dep -type d -name $GATEIN_DEP-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "maven-depmgt-pom:$MAVEN_DEPMGT_POM-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/maven-depmgt-pom -type d -name $MAVEN_DEPMGT_POM-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "gatein-wci:$GATEIN_WCI-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/gatein/wci -type d -name $GATEIN_WCI-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "kernel:$KERNEL-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/kernel -type d -name $KERNEL-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "core:$CORE-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/core -type d -name $CORE-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "ws:$WS-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/ws -type d -name $WS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "gatein-pc:$GATEIN_PC-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/gatein/pc -type d -name $GATEIN_PC-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "gatein-sso:$GATEIN_SSO-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/gatein/sso -type d -name $GATEIN_SSO-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "gatein-portal:$GATEIN_PORTAL-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/gatein/portal -type d -name $GATEIN_PORTAL-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "platform-ui:$PLATFORM_UI-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/platform-ui -type d -name $PLATFORM_UI-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "commons:$COMMONS-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/commons -type d -name $COMMONS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "social:$SOCIAL-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/social -type d -name $SOCIAL-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "gamification:$GAMIFICATION-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/gamification -type d -name $GAMIFICATION-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "kudos:$KUDOS-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/kudos -type d -name $KUDOS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "perk-store:$PERK_STORE-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/perk-store -type d -name $PERK_STORE-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "wallet:$WALLET-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/wallet -type d -name $WALLET-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "app-center:$APP_CENTER-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/app-center -type d -name $APP_CENTER-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "push-notifications:$PUSH_NOTIFICATIONS-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/push-notifications -type d -name $PUSH_NOTIFICATIONS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "exo-es-embedded:$EXO_ES_EMBEDDED-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/exo-es-embedded -type d -name $EXO_ES_EMBEDDED-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "addons-manager:$ADDONS_MANAGER-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/platform/addons-manager -type d -name $ADDONS_MANAGER-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "meeds:$MEEDS-$rel_suffix"
    find $BASE_PATH/exo-releases/io/meeds/distribution -type d -name $MEEDS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "wiki:$WIKI-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/wiki -type d -name $WIKI-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "jcr:$JCR-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/jcr -type d -name $JCR-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "ecms:$ECMS-$rel_suffix"
    find $BASE_PATH/exo-releases/org/exoplatform/ecms -type d -name $ECMS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "agenda:$AGENDA-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/agenda -type d -name $AGENDA-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "chat-application:$CHAT_APPLICATION-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/chat -type d -name $CHAT_APPLICATION-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "cmis-addon:$CMIS_ADDON-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/cmis -type d -name $CMIS_ADDON-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "data-upgrade:$DATA_UPGRADE-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/upgrade -type d -name $DATA_UPGRADE-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "digital-workplace:$DIGITAL_WORKPLACE-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/digital-workplace -type d -name $DIGITAL_WORKPLACE-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "layout-management:$LAYOUT_MANAGEMENT-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/layout-management -type d -name $LAYOUT_MANAGEMENT-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "news:$NEWS-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/news -type d -name $NEWS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "onlyoffice:$ONLYOFFICE-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/onlyoffice -type d -name $ONLYOFFICE-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "remote-edit:$REMOTE_EDIT-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/open-document -type d -name $REMOTE_EDIT-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "saml2-addon:$SAML2_ADDON-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/sso/saml2-addon-* -type d -name $SAML2_ADDON-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "spnego-addon:$SPNEGO_ADDON-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/sso/spnego-addon-* -type d -name $SPNEGO_ADDON-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "task:$TASK-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/task -type d -name $TASK-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "web-conferencing:$WEB_CONFERENCING-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/web-conferencing -type d -name $WEB_CONFERENCING-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "jitsi:$JITSI-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/jitsi -type d -name $JITSI-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "analytics:$ANALYTICS-$rel_suffix"
    find $BASE_PATH/exo-addons-releases/org/exoplatform/addons/analytics -type d -name $ANALYTICS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    echo "platform-private-distributions:$PLATFORM_PRIVATE_DISTRIBUTIONS-$rel_suffix"
    find $BASE_PATH/exo-private-releases/com/exoplatform/platform/distributions -type d -name $PLATFORM_PRIVATE_DISTRIBUTIONS-$rel_suffix -exec rm -rvf {} \; 2>/dev/null || true
    ((counter++))
done
