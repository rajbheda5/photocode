from flask import Flask, request
from json import dumps, loads
from google.cloud import vision
import os
import pandas as pd


app = Flask(__name__)


@app.route('/')
def index():
    return "<h1>Welcome to our server !!</h1>"


@app.route('/OCR', methods=['GET', 'POST'])
def ocr():
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r"vision_api.json"
    data = loads(request.data.decode('utf-8'))
    picture = data['url']
    print(picture)
    client = vision.ImageAnnotatorClient()
    response = client.annotate_image({
        'image': {'source': {'image_uri': f"{picture}"}},
        'features': [{'type_': vision.Feature.Type.DOCUMENT_TEXT_DETECTION}]
    })  # returns TextAnnotation
    text = ''
    for page in response.full_text_annotation.pages:
        for block in page.blocks:
            print('\nBlock confidence: {}\n'.format(block.confidence))
            for paragraph in block.paragraphs:
                print('Paragraph confidence: {}'.format(
                    paragraph.confidence))

                for word in paragraph.words:
                    word_text = ''.join([
                        symbol.text for symbol in word.symbols
                    ])
                    print('Word text: {} (confidence: {})'.format(
                        word_text, word.confidence))
                    text += word_text
                    for symbol in word.symbols:
                        print('\tSymbol: {} (confidence: {})'.format(
                            symbol.text, symbol.confidence))
                    text += ' '

    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))
    return text


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
