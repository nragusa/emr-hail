#!/bin/bash
set -x -e

OUTPUT_PATH=""
HAIL_VERSION="0.1"
SPARK_VERSION="2.2.0"
IS_MASTER=false

if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
  IS_MASTER=true
fi

while [ $# -gt 0 ]; do
    case "$1" in
    --output-path)
      shift
      OUTPUT_PATH=$1
      ;;
    --hail-version)
      shift
      HAIL_VERSION=$1
      ;;
    --spark-version)
      shift
      SPARK_VERSION=$1
      ;;
    -*)
      error_msg "unrecognized option: $1"
      ;;
    *)
      break;
      ;;
    esac
    shift
done

if [ "$IS_MASTER" = true ]; then
  sudo yum update -y
  sudo yum install g++ cmake git -y
  sudo /usr/bin/pip install --upgrade pip
  git clone https://github.com/hail-is/hail.git
  cd hail/
  # Update JAVA_HOME to hail can build properly
  export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk.x86_64/
  ./gradlew -Dspark.version=$SPARK_VERSION shadowJar archiveZip

  cp $PWD/build/distributions/hail-python.zip $HOME
  cp $PWD/build/libs/hail-all-spark.jar $HOME
  
  echo "" >> $HOME/.bashrc
  echo "export PYTHONPATH=\${PYTHONPATH}:$HOME/hail-python.zip" >> $HOME/.bashrc
  
  aws s3 cp $PWD/build/distributions/hail-python.zip $OUTPUT_PATH
  aws s3 cp $PWD/build/libs/hail-all-spark.jar $OUTPUT_PATH
fi
