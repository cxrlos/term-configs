#!/usr/bin/env python3
"""Listens on Hyprland IPC socket2 and runs refresh-gh.sh when Firefox opens."""
import os, socket, subprocess, pathlib, sys

SCRIPT = pathlib.Path(__file__).parent / 'refresh-gh.sh'


def socket_path() -> str:
    sig = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
    if not sig:
        sys.exit('HYPRLAND_INSTANCE_SIGNATURE not set')
    xdg = os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}')
    return f'{xdg}/hypr/{sig}/.socket2.sock'


def main() -> None:
    path = socket_path()
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(path)
        buf = ''
        while True:
            chunk = s.recv(4096).decode('utf-8', errors='ignore')
            if not chunk:
                break
            buf += chunk
            while '\n' in buf:
                line, buf = buf.split('\n', 1)
                # event format: openwindow>>addr,workspace,class,title
                if not line.startswith('openwindow>>'):
                    continue
                payload = line.split('>>', 1)[1]
                parts = payload.split(',', 3)
                if len(parts) >= 3 and parts[2].lower().startswith('firefox'):
                    subprocess.Popen(['bash', str(SCRIPT)],
                                     stdout=subprocess.DEVNULL,
                                     stderr=subprocess.DEVNULL)


if __name__ == '__main__':
    main()
