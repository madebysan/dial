"""Resume bounded audio checks for a candidate JSON array. No audio is saved."""
import argparse
import hashlib
import ipaddress
import json
import re
import socket
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlsplit


def public_url(url: str) -> bool:
    parsed = urlsplit(url)
    if parsed.scheme not in {'http', 'https'} or not parsed.hostname or parsed.username or parsed.password:
        return False
    try:
        addresses = socket.getaddrinfo(parsed.hostname, parsed.port or (443 if parsed.scheme == 'https' else 80), type=socket.SOCK_STREAM)
        return bool(addresses) and all(ipaddress.ip_address(item[4][0]).is_global for item in addresses)
    except (socket.gaierror, ValueError):
        return False


def check(url: str) -> dict:
    checked = datetime.now(timezone.utc).isoformat()
    if not public_url(url):
        return {'url': url, 'checkedAt': checked, 'ok': False, 'reason': 'Not a resolvable public HTTP(S) URL'}
    command = ['ffmpeg', '-hide_banner', '-nostdin', '-rw_timeout', '12000000', '-i', url,
               '-t', '3', '-vn', '-f', 'null', '-']
    try:
        result = subprocess.run(command, capture_output=True, text=True, errors='replace', timeout=25)
    except subprocess.TimeoutExpired:
        return {'url': url, 'checkedAt': checked, 'ok': False, 'reason': '25-second decode deadline exceeded'}
    log = result.stderr
    audio = re.search(r'Stream #\S+.*?Audio: ([^,]+)', log)
    bitrate = re.search(r'icy-br\s*:\s*(\d+)', log)
    name = re.search(r'icy-name\s*:\s*(.+)', log)
    title = re.search(r'StreamTitle\s*:\s*(.+)', log, re.IGNORECASE)
    offline = bool(title and re.search(r'^(?:Airtime|.*FM)\s*-\s*offline\s*$|station is offline', title.group(1), re.IGNORECASE))
    success = result.returncode == 0 and bool(re.search(r'time=00:00:0[3-9]', log)) and not offline
    return {'url': url, 'checkedAt': checked, 'ok': success, 'exitCode': result.returncode,
            'codec': audio.group(1).strip() if audio else None,
            'bitrateKbps': int(bitrate.group(1)) if bitrate else None,
            'streamName': name.group(1).strip() if name else None,
            'titlesObserved': bool(title), 'titleSample': title.group(1).strip() if title else None,
            'offlinePlaceholder': offline, 'sampleSeconds': 3 if success else 0,
            'log': log[-14000:]}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('candidates', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--limit', type=int)
    parser.add_argument('--refresh', action='store_true', help='Repeat checks instead of reusing this run’s saved evidence')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    rows = json.loads(args.candidates.read_text())
    for index, row in enumerate(rows[:args.limit], 1):
        url = row.get('streamURL') or row.get('url_resolved') or row.get('url')
        key = hashlib.sha256(url.encode()).hexdigest()[:20]
        target = args.out / f'{key}.json'
        if target.exists() and not args.refresh:
            evidence = json.loads(target.read_text())
            # Reclassify known placeholder titles in older cached samples.
            title = re.search(r'StreamTitle\s*:\s*(.+)', evidence.get('log', ''), re.IGNORECASE)
            if title and re.search(r'^(?:Airtime|.*FM)\s*-\s*offline\s*$|station is offline', title.group(1).strip(), re.IGNORECASE):
                evidence['ok'] = False
                evidence['offlinePlaceholder'] = True
                target.write_text(json.dumps(evidence, ensure_ascii=False, indent=2)+'\n')
        else:
            evidence = check(url)
            target.write_text(json.dumps(evidence, ensure_ascii=False, indent=2)+'\n')
        print(f'{index}/{len(rows)} {row.get("name", row.get("id"))}: {"PASS" if evidence["ok"] else "FAIL"}', flush=True)


if __name__ == '__main__':
    main()
