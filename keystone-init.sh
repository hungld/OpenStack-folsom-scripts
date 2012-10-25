#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

export SERVICE_TOKEN=$(grep '^admin_token' /etc/keystone/keystone.conf | awk '/ = / {print $3}')
export SERVICE_ENDPOINT=http://$KEYSTONE_HOST:35357/v2.0

#http://$(netstat -an | grep 35357 | awk '/ 0 / { print $4 }' | sed s/0.0.0.0/localhost/)/v2.0

function get_id (){
        echo `$@ | awk '/ id / { print $4 }'`
}

function init_keystone() 
{
        ADMIN_TENANT=$(get_id keystone tenant-create --name=admin)
        SERVICE_TENANT=$(get_id keystone tenant-create --name=$SERVICE_TENANT_NAME)

        ADMIN_USER=$(get_id keystone user-create --name=admin --pass="$ADMIN_PASSWORD" --email=admin@example.com)

        ADMIN_ROLE=$(get_id keystone role-create --name=admin)
        KEYSTONE_ADMIN_ROLE=$(get_id keystone role-create --name=KeystoneAdmin)
        KEYSTONE_SERVICE_ROLE=$(get_id keystone role-create --name=KeystoneServiceAdmin)

        for role in $ADMIN_ROLE $KEYSTONE_ADMIN_ROLE $KEYSTONE_SERVICE_ROLE; do
                keystone user-role-add --user_id $ADMIN_USER --role_id $role --tenant_id $ADMIN_TENANT;
        done

        MEMBER_ROLE=$(get_id keystone role-create --name=Member)

	KEYSTONE_SERVICE=$(get_id keystone service-create --name keystone --type identity --description 'OpenStack_Identity')
	keystone endpoint-create --region $KEYSTONE_REGION --service-id $KEYSTONE_SERVICE --publicurl 'http://'"$KEYSTONE_PUB_HOST"':5000/v2.0' --adminurl 'http://'"$KEYSTONE_ADMIN_HOST"':35357/v2.0' --internalurl 'http://'"$KEYSTONE_HOST"':5000/v2.0'

        NOVA_USER=$(get_id keystone user-create --name=nova --pass="$SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT --email=nova@example.com)
        keystone user-role-add --tenant_id $SERVICE_TENANT --user_id $NOVA_USER --role_id $ADMIN_ROLE
	NOVA_SERVICE=$(get_id keystone service-create --name nova --type compute --description 'OpenStack_Compute_Service')
	keystone endpoint-create --region $KEYSTONE_REGION --service-id $NOVA_SERVICE --publicurl "http://$NOVA_PUB_HOST:8774/v2/%(tenant_id)s" --internalurl "http://$NOVA_HOST:8774/v2/%(tenant_id)s" --adminurl="http://$NOVA_ADMIN_HOST:8774/v2/%(tenant_id)s" >/dev/null

        GLANCE_USER=$(get_id keystone user-create --name=glance --pass="$SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT --email=glance@example.com)
        keystone user-role-add --tenant_id $SERVICE_TENANT --user_id $GLANCE_USER --role_id $ADMIN_ROLE
	GLANCE_SERVICE=$(get_id keystone service-create --name glance --type image --description 'OpenStack_Image_Service')
	keystone endpoint-create --region $KEYSTONE_REGION --service-id $GLANCE_SERVICE --publicurl 'http://'"$GLANCE_PUB_HOST"':9292/v2' --adminurl 'http://'"$GLANCE_ADMIN_HOST"':9292/v2' --internalurl 'http://'"$GLANCE_HOST"':9292/v2'

        #QUANTUM_USER=$(get_id keystone user-create --name=quantum --pass="$SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT --email=quantum@example.com)
        #keystone user-role-add --tenant_id $SERVICE_TENANT --user_id $QUANTUM_USER --role_id $ADMIN_ROLE

        CINDER_USER=$(get_id keystone user-create --name=cinder --pass="$SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT --email=cinder@example.com)
	keystone user-role-add --tenant_id $SERVICE_TENANT --user_id $CINDER_USER --role_id $ADMIN_ROLE
	CINDER_SERVICE=$(get_id keystone service-create --name cinder --type volume --description 'OpenStack_Volume_Service')
	keystone endpoint-create --region $KEYSTONE_REGION --service-id $CINDER_SERVICE --publicurl 'http://'"$CINDER_PUB_HOST"':8776/v1/$(tenant_id)s' --adminurl 'http://'"$CINDER_ADMIN_HOST"':8776/v1/$(tenant_id)s' --internalurl 'http://'"$CINDER_HOST"':8776/v1/$(tenant_id)s'
	
	EC2_SERVICE=$(get_id keystone service-create --name ec2 --type ec2 --description 'OpenStack_EC2_service')
	keystone endpoint-create --region $KEYSTONE_REGION --service-id $EC2_SERVICE --publicurl 'http://'"$EC2_PUB_HOST"':8773/services/Cloud' --adminurl 'http://'"$EC2_ADMIN_HOST"':8773/services/Admin' --internalurl 'http://'"$EC2_HOST"':8773/services/Cloud'
	
	SWIFT_USER=$(get_id keystone user-create --name=swift --pass="$SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT --email=swift@example.com)
        keystone user-role-add --tenant_id $SERVICE_TENANT --user_id $SWIFT_USER --role_id $ADMIN_ROLE
	# Nova needs ResellerAdmin role to download images when accessing
	# swift through the s3 api. The admin role in swift allows a user
	# to act as an admin for their tenant, but ResellerAdmin is needed
	# for a user to act as any tenant. The name of this role is also
	# configurable in swift-proxy.conf
	RESELLER_ROLE=$(get_id keystone role-create --name=ResellerAdmin)
	keystone user-role-add --tenant_id $SERVICE_TENANT --user_id $NOVA_USER --role_id $RESELLER_ROLE
	
	SWIFT_SERVICE=$(get_id keystone service-create --name swift --type object-store --description 'OpenStack_Swift_service')
	keystone endpoint-create --region $KEYSTONE_REGION --service-id $SWIFT_SERVICE --publicurl 'http://'"$SWIFT_PUB_HOST"':8080/v1/AUTH_\$(tenant_id)s' --adminurl 'http://'"$SWIFT_ADMIN_HOST"':8080/' --internalurl 'http://'"$SWIFT_HOST"':8080/v1/AUTH_\$(tenant_id)s'
}

run_command "Init Keystone" init_keystone

keystone endpoint-list
