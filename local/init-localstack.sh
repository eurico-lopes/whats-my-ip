set -e

sleep 10
AWS_ACCESS_KEY_ID="nothing" AWS_SECRET_ACCESS_KEY="nothing" aws dynamodb --region=us-east-1 --endpoint-url=http://localstack:4566 create-table \
    --table-name terraform-state-table \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD

AWS_ACCESS_KEY_ID="nothing" AWS_SECRET_ACCESS_KEY="nothing" aws s3api --region=us-east-1 --endpoint-url=http://localstack:4566 create-bucket \
    --bucket terraform-state-bucket