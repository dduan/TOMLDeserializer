#!/usr/bin/env python3

from glob import glob
from os.path import splitext
import json

def convert(json):
    if type(json) == dict:
        for (k, v) in json.items():
            if type(v) == dict and  'value' in v and type(v['value']) == list and 'type' in v and v['type'] == 'array':
                json[k] = convert(v['value'])
            elif type(v) == dict and  'value' in v and type(v['value']) == str and 'type' in v and type(v['type']) == str:
                json[k] = v['value']
            else:
                json[k] = convert(v)
    elif type(json) == list:
        for (i, v) in enumerate(json):
            if type(v) == dict and  'value' in v and type(v['value']) == list and 'type' in v and v['type'] == 'array':
                json[i] = convert(v['value'])
            elif type(v) == dict and  'value' in v and type(v['value']) == str and 'type' in v and type(v['type']) == str:
                json[i] = v['value']
            else:
                json[i] = convert(v)

    return json

if __name__ == '__main__':
    for weird in glob("*.json"):
        weird_content = json.loads(open(weird).read())
        output = convert(weird_content)

        with open(weird, 'w') as f:
            f.write(json.dumps(output, indent = 4))
