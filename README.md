# Cromwell-cn
Genomic Cromwell-on-aws for AWS China Region

# Repo-link
* CloudFormation Template link: https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/templates/cromwell-aio.template.yaml
* Simple Test Command:

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/scripts/simple-hello.wdl

curl -X POST "http://localhost:8000/api/workflows/v1" -H "accept: application/json" -F "workflowSource=@simple-hello.wdl"

* GATK Test Command:

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/scripts/HaplotypeCaller.aws.wdl

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/scripts/HaplotypeCaller.aws.json

curl -X POST "http://localhost:8000/api/workflows/v1" \
    -H  "accept: application/json" \
    -F "workflowSource=@HaplotypeCaller.aws.wdl" \
-F workflowInputs=@HaplotypeCaller.aws.json

# Tips for GATK test
* Please wait 30-45min (due to download speed) before submitting job to get ready for GATK docker image(~5GB) download and loading. 
    * In this wait phase, you can ssh to compute node jumping from Cromwell-server host and see whether “docker images” already included broadinstitute/gatk image or not.
* Set up a bucket of yourself in same region to place sufficient test data files through s3 sync:
    * aws s3 sync s3://gatk-test-data s3://yourbucket/ --region cn-northwest-1
* Modify the s3://gatk-test-data/filepath of bam, bam_index and intervals_list to your bucket like s3://yourbucket/filepath in HaplotypeCaller.aws.json 
