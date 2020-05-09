#!/usr/bin/env bash
#
# lifecycle -- This script installs the `kaggle` package in all
#   Python 3 environments. Inspiration from AWS SageMaker notebook
#   instance lifecycle configuration samples provided on GitHub:
#   https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples

set -e

KAGGLE_API_FILE=/home/ec2-user/.kaggle/kaggle.json
KAGGLE_API=$(aws secretsmanager get-secret-value --secret-id KaggleApiKey | jq -r .SecretString)

mkdir -p $(dirname "${KAGGLE_API_FILE}")
echo "${KAGGLE_API}" > "${KAGGLE_API_FILE}"
chmod 600 "${KAGGLE_API_FILE}"
chown ec2-user: "${KAGGLE_API_FILE}"

sudo -u ec2-user -i << EOF

for env in base /home/ec2-user/anaconda3/envs/* ; do
	source /home/ec2-user/anaconda3/bin/activate $(basename "$env")

	if [ $env = 'JupyterSystemEnv' ] ; then
		continue
	fi

	# The Kaggle package is only available for Python 3
	python_version=$(python -c 'import sys; print(sys.version_info.major)')
	if [ $python_version -ne 3 ] ; then
		continue
	fi

	pip install --upgrade --quiet kaggle

	source /home/ec2-user/anaconda3/bin/deactivate
done

EOF
