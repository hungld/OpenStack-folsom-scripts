BASE_DIR=$(dirname $(readlink -f $0))
CONFIG=$BASE_DIR/stackrc
LOCAL_CONFIG=localrc

ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin_password}
SERVICE_PASSWORD=${SERVICE_PASSWORD:-service_pass}
SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-service}


function read_config()
{
	. $CONFIG
	if test -e $LOCAL_CONFIG; then
		echo "using local configuration file $LOCAL_CONFIG" >&2
		. $LOCAL_CONFIG
	fi
}

function run_command()
{
	echo -n "$1..."
        shift
        STDOUT=$($* 2>&1) && (echo "DONE") || (echo "ERROR"; echo $STDOUT; kill -9 $$)
}

read_config
