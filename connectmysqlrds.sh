#!/bin/bash
set -e

ENVIRONMENT=$1
APPLICATION_NAME=$2
echo "Getting Secrets from SSM...."
DB_HOST=$(aws ssm get-parameter --with-decryption --name "/nonprod/rds/mysql/host" --query "Parameter.Value" --output text)
DB_USERNAME=$(aws ssm get-parameter --with-decryption --name "/$ENVIRONMENT/$APPLICATION_NAME/DB_USERNAME" --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --with-decryption --name "/$ENVIRONMENT/$APPLICATION_NAME/DB_PASSWORD" --query "Parameter.Value" --output text)

echo "Please select an option:"
echo "1. Connect to Database"
echo "2. Delete Database"

read option

case $option in
  1)
    echo "Connecting to database.. Creating Bastion Pod..."
    kubectl run "bastion-$RANDOM" --rm -it --image alpine --env="DB_HOST=$DB_HOST" --env="DB_USERNAME=$DB_USERNAME" --env="DB_PASSWORD=$DB_PASSWORD" -- sh -c 'apk add mysql-client && mysql -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD'
    ;;
  2)
    echo "Enter the Database Name of $APPLICATION_NAME in $ENVIRONMENT environment:"
    read db_name
    echo "Are you sure you want to delete $db_name? (y/n)"
    read confirmation
    if [ "$confirmation" == "y" ]; then
      echo "Deleting database $db_name... Creating Bastion Pod..."
      kubectl run "bastion-$RANDOM" --rm -it --image alpine --env="DB_HOST=$DB_HOST" --env="DB_USERNAME=$DB_USERNAME" --env="DB_PASSWORD=$DB_PASSWORD" -- sh -c "apk add mysql-client && mysql -h'$DB_HOST' -u'$DB_USERNAME' -p'$DB_PASSWORD' -e 'DROP DATABASE $db_name'"
    else
      echo "Aborted."
    fi
    ;;
  *)
    echo "Invalid option selected."
    ;;
esac
