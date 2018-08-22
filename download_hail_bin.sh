#!/bin/bash
set -x -e

S3_BUCKET="s3://emr-hail-0.2-us-east-1"
S3_REGION="us-east-1"
IS_MASTER=false

if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
  IS_MASTER=true
fi

if [ "$IS_MASTER" = true ]; then

  aws s3 cp $S3_BUCKET/hail/hail-python.zip $HOME --region $S3_REGION
  aws s3 cp $S3_BUCKET/hail/hail-all-spark.jar $HOME --region $S3_REGION

  echo "" >> $HOME/.bashrc
  echo "export PYTHONPATH=\${PYTHONPATH}:$HOME/hail-python.zip" >> $HOME/.bashrc
  
fi
