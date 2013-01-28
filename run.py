import argparse
import sys
import time
from datetime import datetime

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome import service

# Chrome + Selenium testing script
# This script won't setup the network condition, the given arguments
# will be used to store to database together with test results.

class TestCase():
    def __init__(self):
        self.parser = argparse.ArgumentParser()
        self.parse_arguments()

        self.chrome_driver = service.Service('/home/vvoody/.virtualenvs/selenium/bin/chromedriver')
        self.results = []

        # some kind of ID of a test
        self.when = int(datetime.utcnow().strftime("%s"))

        self.protocol = self.args.protocol
        self.chrome_options = self.decide_chrome_startup_options()
        self.ssl = self.args.ssl
        self.net_type = self.args.net_type
        self.net_up_bw = self.args.net_up_bw
        self.net_dw_bw = self.args.net_dw_bw
        self.net_rtt = self.args.net_rtt
        self.net_loss = self.args.net_loss
        self.request_url = ('https' if self.ssl else 'http') + '://en.m.wikipedia.org/wiki/Lionel_Messi.html'

        if self.args.verbosity:
            print self.args
            print self.chrome_options

    def decide_chrome_startup_options(self):
        opts = Options()
        opts.add_argument('--disable-extensions')

        if self.protocol == 'http':
            # server should be 'SpdyEnabled off'
            pass
        elif self.protocol == 'spdy':
            # server should be 'SpdyEnabled off' and
            # Chrome supports SPDY by default
            pass
        elif self.protocol == 'http-pipelining':
            opts.add_argument('--use-spdy=off')
            opts.add_argument('--enable-http-pipelining')
        else:
            print "Won't reach here."

        return opts.to_capabilities()

    def parse_arguments(self):
        self.parser.add_argument('-t', '--times', help='how many times to run', type=int, default=10)
        self.parser.add_argument('-p', '--protocol', help='protocol name to test',
                                 choices=['http', 'spdy', 'http-pipelining'], required=True)
        self.parser.add_argument('-s', '--ssl', help='SSL enabled', action='store_true')
        self.parser.add_argument('-n', '--net-type', help='network condition',
                                 choices=['EDGE', '3G', '4G'], required=True)
        self.parser.add_argument('-l', '--net-loss', help='packet loss ratio of network(percent)', required=True)
        self.parser.add_argument('-u', '--net-up-bw', help='uplink bandwidth of network(kbit/s)', required=True)
        self.parser.add_argument('-d', '--net-dw-bw', help='downlink bandwidth of network(kbit/s)', required=True)
        self.parser.add_argument('-r', '--net-rtt', help='RTT of network(millisecond)', required=True)
        self.parser.add_argument('-v', '--verbosity', help='more debug info', action='store_true')
        self.parser.add_argument('-x', '--dont-save', help='more debug info', action='store_true')
        self.args = self.parser.parse_args()

    def run(self):
        self.chrome_driver.start()
        time.sleep(1)
        print "Test started at UTC time: %d." % self.when

        for i in range(self.args.times):
            driver = webdriver.Remote(self.chrome_driver.service_url, self.chrome_options)
            time.sleep(2)

            print "No. of test: %d." % i
            start = datetime.utcnow()
            driver.get(self.request_url)
            end = datetime.utcnow()
            t = (end - start).total_seconds()
            print "Load time: %f" % t
            self.results.append(t)

            time.sleep(2)
            driver.quit()
            time.sleep(1)
        self.stop()

    def stop(self):
        self.chrome_driver.stop()

    def save(self):
        import pymongo

        conn = pymongo.Connection("mongodb://localhost", safe=True)
        db = conn.thesis
        benchmarks = db.benchmarks

        try:
            benchmarks.insert({'when': self.when,
                               'protocol': self.protocol,
                               'ssl': self.ssl,
                               'net_type': self.net_type,
                               'net_up_bw': self.net_up_bw,
                               'net_dw_bw': self.net_dw_bw,
                               'net_rtt': self.net_rtt,
                               'net_loss': self.net_loss,
                               'results': self.results,
                               'load_time': sum(self.results) / len(self.results)
                               })
        except Exception, e:
            print str(e)
        else:
            print "Test data saved to database."

def main():
    # try here to close chromedriver server
    try:
        test = TestCase()
        test.run()
    except Exception, e:
        print str(e)
        print "chromedriver to be stopped."
        test.stop()

    if test.args.dont_save:
        print "Test data not saved to database."
    else:
        test.save()

if __name__ == '__main__':
    main()
    #pass
