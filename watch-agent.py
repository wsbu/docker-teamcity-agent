#!/usr/bin/python3
import os
import select
import sys
import subprocess
import signal
import time


class BuildAgentWatcher(object):
    PROCESS = None
    AGENT_SCRIPT = None

    @staticmethod
    def handle_stop(signal_number, stack):
        BuildAgentWatcher.stop()

    @classmethod
    def run(cls) -> None:
        log_file = sys.argv[1]

        cls.AGENT_SCRIPT = sys.argv[2]
        if not os.path.exists(cls.AGENT_SCRIPT) or 'agent.sh' != os.path.basename(cls.AGENT_SCRIPT):
            raise Exception('Second argument should point to agent.sh script for TeamCity build agent. Received {0}'
                            .format(cls.AGENT_SCRIPT))

        signal.signal(signal.SIGTERM, cls.handle_stop)
        cls.do_tail(log_file)

    @classmethod
    def do_tail(cls, log_file: str) -> None:
        cls.PROCESS = subprocess.Popen(['tail', '-F', log_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        p = select.poll()
        p.register(cls.PROCESS.stdout)

        while True:
            while p.poll(1):
                sys.stdout.write(cls.PROCESS.stdout.readline().decode())
            time.sleep(0.1)

    @classmethod
    def stop(cls):
        if cls.PROCESS:
            cls.PROCESS.terminate()
            try:
                cls.PROCESS.wait(timeout=1)
            except subprocess.TimeoutExpired:
                cls.PROCESS.kill()

        subprocess.run([cls.AGENT_SCRIPT, 'stop'], check=True)


if '__main__' == __name__:
    BuildAgentWatcher.run()
