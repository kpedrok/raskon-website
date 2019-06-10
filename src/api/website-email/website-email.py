import json
from string import Template

import boto3

ses_client = boto3.client('ses')


def send_email(event, context):
    SENDER = "Pedro <pedro@taglivros.com.br>"
    print(event)
    email = event
    data = [{"email": "pedrokvb@gmail.com"}]
    template_email_indicador_html = ('''
       <!DOCTYPE html>
       <html lang="en">
       <body>
        <h1>Raskon - Cadastro</h1>
        <p>Cadastro do email $email.</p>
       </body>
       </html>
       ''')
    template_email_indicador = Template(
        template_email_indicador_html).safe_substitute(email=email)
    for i in data:
        RECIPIENT = i['email']
        # CONFIGURATION_SET = "teste1"
        # AWS_REGION = "us-west-2"
        SUBJECT = ("Raskon - Cadastro")
        BODY_TEXT = ("Raskon - Acesso")
        BODY_HTML = template_email_indicador
        CHARSET = "UTF-8"
        try:
            response = ses_client.send_email(
                Destination={
                    'ToAddresses': [
                        RECIPIENT,
                    ],
                },
                Message={
                    'Body': {
                        'Html': {
                            'Charset': CHARSET,
                            'Data': BODY_HTML,
                        },
                        'Text': {
                            'Charset': CHARSET,
                            'Data': BODY_TEXT,
                        },
                    },
                    'Subject': {
                        'Charset': CHARSET,
                        'Data': SUBJECT,
                    },
                },
                Source=SENDER,
                # ConfigurationSetName=CONFIGURATION_SET,
            )
        except ClientError as e:
            print(e.response['Error']['Message'])
        else:
            print("Email sent! Message ID:"),
            print(response['MessageId'])


def lambda_handler(event, context):
    email = event['queryStringParameters']['email']
    send_email(email, "")
    message = {
        'message': 'Your message was sent successfully!'
    }
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(message)}
