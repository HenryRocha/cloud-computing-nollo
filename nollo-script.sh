#!/bin/bash

# Constants and default values.
TF_AUTO_VARS_PATH="./infrastructure/terraform.auto.tfvars"

# Settings the default values for all flags.
should_generate_wireguard_keys=0
should_create_admin_config=0

function usage {
	cat <<-EOF
	Usage: nollo-script [options] ...

	This script deploys the infrastructure defined in the
	"infrastructure" directory.

	Options:
	  -h, --help                        This help output
	  -k, --gen-keys                    Generate Wireguard keys
	  -c, --wg-admin-config	 file       Output the Wireguard admin config to a file

	Example:
	nollo-script --gen-keys
	EOF
    if [ -n "$*" ] ; then
        echo 1>&2
        echo "Error: $*" 1>&2
        exit 1
    else
        exit 0
    fi
}

function generate_wireguard_keys {
    if grep -q WG_ADMIN_PBK "$1"; then
        printf "Error: WG_ADMIN_PBK variable already exists in $1\n"
        exit 1
    fi
    
    if grep -q WG_BE_SERVER_PVK "$1"; then
        printf "Error: WG_BE_SERVER_PVK variable already exists in $1\n"
        exit 1
    fi
    
    if grep -q WG_BE_SERVER_PBK "$1"; then
        printf "Error: WG_BE_SERVER_PBK variable already exists in $1\n"
        exit 1
    fi
    
    if grep -q WG_FE_SERVER_PVK "$1"; then
        printf "Error: WG_FE_SERVER_PVK variable already exists in $1\n"
        exit 1
    fi
    
    if grep -q WG_FE_SERVER_PBK "$1"; then
        printf "Error: WG_FE_SERVER_PBK variable already exists in $1\n"
        exit 1
    fi
    
    # Generate Wireguard keys.
    printf "Generating Wireguard keys...."
    
    admin_private_key=$(wg genkey)
    admin_public_key=$(echo $admin_private_key | wg pubkey)
    printf "WG_ADMIN_PBK = \"$admin_public_key\"\n" >> $1
    printf "WG_ADMIN_PVK = \"$admin_private_key\"\n"
    
    backend_wireguard_private_key=$(wg genkey)
    backend_wireguard_public_key=$(echo $backend_wireguard_private_key | wg pubkey)
    printf "WG_BE_SERVER_PVK = \"$backend_wireguard_private_key\"\n" >> $1
    printf "WG_BE_SERVER_PBK = \"$backend_wireguard_public_key\"\n" >> $1
    
    frontend_wireguard_private_key=$(wg genkey)
    frontend_wireguard_public_key=$(echo $frontend_wireguard_private_key | wg pubkey)
    printf "WG_FE_SERVER_PVK = \"$frontend_wireguard_private_key\"\n" >> $1
    printf "WG_FE_SERVER_PBK = \"$frontend_wireguard_public_key\"\n" >> $1
    
    printf "Done\n"
}

function create_wireguard_admin_config {
	cat > $1 <<-EOF
	[Interface]
	Address = 10.10.150.45/32
	SaveConfig = true
	ListenPort = 51820
	PrivateKey = $admin_private_key

	[Peer]
	PublicKey = $backend_wireguard_public_key
	AllowedIPs = 10.10.150.20/32, 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24, 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
	Endpoint = 54.174.225.244:51820
	PersistentKeepalive = 15
	EOF
}

function validate_tf_vars_file {
    # Validate Terraform variables.
    printf "Validating Terraform variables...."
    
    if ! grep -q AWS_ACCESS_KEY_ID "$1"; then
        printf "\nError: Missing AWS_ACCESS_KEY_ID variable in $1\n"
        exit 1
    fi
    
    if ! grep -q AWS_SECRET_ACCESS_KEY "$1"; then
        printf "\nError: Missing AWS_SECRET_ACCESS_KEY variable in $1\n"
        exit 1
    fi
    
    if ! grep -q NOLLO_DB_ROOT_PW "$1"; then
        printf "\nError: Missing NOLLO_DB_ROOT_PW variable in $1\n"
        exit 1
    fi
    
    if ! grep -q NOLLO_DB_ADMIN_PW "$1"; then
        printf "\nError: Missing NOLLO_DB_ADMIN_PW variable in $1\n"
        exit 1
    fi
    
    if ! grep -q NOLLO_DB_API_PW "$1"; then
        printf "\nError: Missing NOLLO_DB_API_PW variable in $1\n"
        exit 1
    fi
    
    if ! grep -q NOLLO_API_DSN "$1"; then
        printf "\nError: Missing NOLLO_API_DSN variable in $1\n"
        exit 1
    fi
    
    if ! grep -q WG_ADMIN_PBK "$1"; then
        printf "\nError: Missing WG_ADMIN_PBK variable in $1\n"
        exit 1
    fi
    
    if ! grep -q WG_BE_SERVER_PVK "$1"; then
        printf "\nError: Missing WG_BE_SERVER_PVK variable in $1\n"
        exit 1
    fi
    
    if ! grep -q WG_BE_SERVER_PBK "$1"; then
        printf "\nError: Missing WG_BE_SERVER_PBK variable in $1\n"
        exit 1
    fi
    
    if ! grep -q WG_FE_SERVER_PVK "$1"; then
        printf "\nError: Missing WG_FE_SERVER_PVK variable in $1\n"
        exit 1
    fi
    
    if ! grep -q WG_FE_SERVER_PBK "$1"; then
        printf "\nError: Missing WG_FE_SERVER_PBK variable in $1\n"
        exit 1
    fi
    
    printf "Done\n"
}

# Parse command line arguments.
while [ -n "$1" ] ; do
    case $1 in
        -k | --gen-keys)
            should_generate_wireguard_keys=1
        ;;
        --wg-admin-config)
            should_create_admin_config=1
            
            if [ "$2" = "" ]; then
                printf "Missing file for wg-admin-config"
                exit 1
            fi
            admin_config_fp=$2
            shift
        ;;
        -h | --help)
            usage
            exit 0
        ;;
        -*)
            usage "unknown option '$*'"
            exit 1
        ;;
        *)
            echo "No options..."
            exit 1
        ;;
    esac
    shift
done

# Call function to generate Wireguard keys.
if [ "$should_generate_wireguard_keys" = "1" ]; then
    generate_wireguard_keys $TF_AUTO_VARS_PATH
fi

# # Call function to create admin Wireguard configuation file.
# if [ "$should_create_admin_config" = "1" ]; then
#     create_wireguard_admin_config $admin_config_fp
# fi

# Call function to validate Terraform variables file
validate_tf_vars_file $TF_AUTO_VARS_PATH

# Init any new modules
cd ./infrastructure
terraform init

# Destroy old state
printf "Destroying previous Terraform state...."

terraform destroy --auto-approve

printf "\nDone\n"

# Create new state
printf "Creating new infrastructure...."

terraform apply --auto-approve

printf "\nDone\n"
