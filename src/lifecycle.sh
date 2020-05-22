#!/usr/bin/env bash
#
# lifecycle -- This script installs the `kaggle` package in all
#   Python 3 environments. Inspiration from AWS SageMaker notebook
#   instance lifecycle configuration samples provided on GitHub:
#   https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples

# KAGGLE_SECRET_NAME=${secret_name}

echo [INFO] Fetching the Kaggle API and saving it in kaggle.json...
KAGGLE_API_FILE=/home/ec2-user/.kaggle/kaggle.json
KAGGLE_API=$(aws secretsmanager get-secret-value --secret-id KaggleApiKey | jq -r .SecretString)
if [[ $? -ne 0 ]] ; then
	echo [ERROR] Error when fetching secret from AWS SecretsManager
	exit 1
fi
echo [INFO] Successfully fetched Kaggle API key

mkdir -p $(dirname "$KAGGLE_API_FILE")
echo "$KAGGLE_API" > "$KAGGLE_API_FILE"
chmod 600 "$KAGGLE_API_FILE"
chown ec2-user: "$KAGGLE_API_FILE"

echo [INFO] Installing the kaggle Python package in all Python 3 environments...
sudo -u ec2-user bash -s << EOF

for env in base /home/ec2-user/anaconda3/envs/* ; do
	source /home/ec2-user/anaconda3/bin/activate $(basename "$env")

	if [[ "$env" = 'JupyterSystemEnv' ]] ; then
		continue
	fi

	# The Kaggle package is only available for Python 3
	python_version=$(python -c 'import sys; print(sys.version_info.major)')
	if [[ "$python_version" -eq 3 ]] ; then
		pip install --upgrade --quiet kaggle
		echo "[INFO] Installed package in $env"
	else
		echo "[INFO] Skipping installation for $env -- (Python $python_version)"
	fi

	source /home/ec2-user/anaconda3/bin/deactivate
done
EOF
echo [INFO] Finished installing kaggle package in all relevant packages
