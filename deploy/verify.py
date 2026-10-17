#!/usr/bin/env python3
"""Acceptance checks; never prints passwords or tokens."""
import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

root = Path(__file__).resolve().parent
env = dict(line.split('=', 1) for line in (root / '.env').read_text().splitlines() if '=' in line and not line.startswith('#'))
base = os.environ.get('CHECK_BASE_URL', 'http://127.0.0.1:' + env.get('HTTP_PORT', '8080'))
state_file = root / '.acceptance.json'

def request(path, payload=None, token=None, content_type='application/json'):
    headers = {'Content-Type': content_type}
    if token:
        headers['token'] = token
    body = json.dumps(payload).encode() if isinstance(payload, dict) else payload
    with urllib.request.urlopen(urllib.request.Request(base + path, data=body, headers=headers), timeout=15) as response:
        return response.read()

def api(path, payload=None, token=None):
    data = json.loads(request(path, payload, token))
    if data.get('code') != '200':
        raise RuntimeError('API failed: ' + path + ' code=' + str(data.get('code')))
    return data.get('data')

for attempt in range(90):
    try:
        request('/login')
        login = api('/api/user/login', {'username': 'admin', 'password': env['ADMIN_INITIAL_PASSWORD']})
        token = login['token']
        assert login['role'] == 'ADMIN'
        break
    except (urllib.error.URLError, RuntimeError, KeyError, ConnectionError):
        if attempt == 89:
            raise RuntimeError('Backend did not become ready; inspect container logs privately.') from None
        time.sleep(2)
print('PASS: frontend route and fresh administrator login')

products = api('/api/product/selectAll', token=token)
assert any(p['productNo'] == 'DEPLOY-CHECK-001' for p in products)
print('PASS: authenticated product query')

if '--after-restart' in sys.argv:
    state = json.loads(state_file.read_text())
else:
    boundary = 'AgentMallAcceptanceBoundary'
    content = ('AgentMall persistence check ' + str(int(time.time() * 1000000000)) + '\n').encode()
    body = ('--' + boundary + '\r\nContent-Disposition: form-data; name="file"; filename="deployment-check.txt"\r\nContent-Type: text/plain\r\n\r\n').encode() + content + ('\r\n--' + boundary + '--\r\n').encode()
    uploaded = json.loads(request('/api/files/upload', body, token, 'multipart/form-data; boundary=' + boundary))
    assert uploaded['code'] == '200'
    assert uploaded['data'].startswith('/files/download/')
    state = {'download_path': uploaded['data'], 'sha256': hashlib.sha256(content).hexdigest()}
    state_file.write_text(json.dumps(state))
downloaded = request(state['download_path'])
assert hashlib.sha256(downloaded).hexdigest() == state['sha256']
print('PASS: upload/download' + (' and persistence after restart' if '--after-restart' in sys.argv else ' through Nginx /api/ and /files/'))
