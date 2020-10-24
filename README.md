# weather-data-download-lambda

Downloads weather data from openweatherapi

It downloads city weather data, validates the data intergrity(not much).

## Get API Key

Create an account in openweathermap.org, get the apiKey and apiKey takes atleast 2 hours to get active.

## Download City data and Unzip it

``` bash
wget http://bulk.openweathermap.org/sample/history.city.list.json.gz 
tar -xzf *.json.gz
```

## Testing

1. [SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) CLI

Install AWS SAM : https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html

Generate test-event in our case : `sam local generate-event cloudwatch scheduled-event`
Output will be something like this :

``` json
{
  "id": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
  "detail-type": "Scheduled Event",
  "source": "aws.events",
  "account": "123456789012",
  "time": "1970-01-01T00:00:00Z",
  "region": "us-east-1",
  "resources": [
    "arn:aws:events:us-east-1:123456789012:rule/ExampleRule"
  ],
  "detail": {}
}
```

* Create SAM [template](template.yaml)
* Validate the template

``` bash
sam validate
```

* Build image (You need docker for this)

``` bash
sam build
```

* Invoke the lambda

``` bash
sam local invoke 
```

Note: Refresh lambda image after code change using sam build. 

2. [Python Lambda Local](https://pypi.org/project/python-lambda-local/)

Install the dependency using `pip3 install python-lambda-local`
If installed this dependency in venv, please activate it first `source venv/bin/activate`
Execute the lambda : `python-lambda-local -f lambda_handler -e test/env.json src/app.py test/event.json`

## Deployment of the lambda

### Packaging

``` bash
mkdir -p target
pip install --target target/ -r requirements.txt
cp src/*.py target

cd target && zip -r9 ../weather_data_download.zip .
cd -

```

### Deployment

Run the deployment script if you are lazy like me `./deploy.sh`
you may need to make the deploy.sh executable `sudo chmod +x deploy.sh`
OR

* Create package using above step
* Run terraform apply manually
