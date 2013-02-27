import argparse
import time
import json
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

        self.load_conf()

        self.chrome_driver = service.Service(self.CHROME_DRIVER_PATH)
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
        self.request_url = ('https' if self.ssl else 'http') + '://' + self.REQUEST_PATH

        if self.args.verbosity:
            print self.args
            print self.chrome_options
            print self.conf

    def load_conf(self):
        with open('config.json', 'r') as f:
            config = json.load(f)
            self.conf = config

        self.CHROME_DRIVER_PATH = config.get('chrome_driver_path')
        self.REQUEST_PATH = config.get('request_path')
        self.DB = config.get('db')
        self.COLLECTION = config.get('collection')
        self.DBUSER = config.get('dbuser')
        self.DBPASSWD = config.get('dbpasswd')
        self.DBHOST = config.get('dbhost')

    def decide_chrome_startup_options(self):
        opts = Options()
        opts.add_argument('--disable-extensions')

        if self.protocol == 'http':
            # server should be 'SpdyEnabled off'
            pass
        elif self.protocol == 'spdy':
            # server should be 'SpdyEnabled off' and
            # Chrome supports SPDY by default
            if self.args.ssl is False:
                # server: SpdyDebugUseSpdyForNonSslConnections 2
                opts.add_argument('--use-spdy=no-ssl')
        elif self.protocol == 'http-pipelining':
            # server should be 'SpdyEnabled off'
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
        self.parser.add_argument('-z', '--holdon', help='seconds to hold on after page loaded', type=int, default=1)
        self.args = self.parser.parse_args()

    def run(self):
        self.chrome_driver.start()
        time.sleep(1)
        print "Test started at UTC time: %d." % self.when

        for i in range(self.args.times):
            driver = webdriver.Remote(self.chrome_driver.service_url, self.chrome_options)
            time.sleep(2)

            print "No. of test: %d." % i
            print self.request_url
            start = datetime.utcnow()
            driver.get(self.request_url)
            end = datetime.utcnow()
            t = (end - start).total_seconds()
            print "Load time: %f" % t
            self.results.append(t)

            time.sleep(self.args.holdon)
            driver.quit()
            time.sleep(1)

    def stop(self):
        self.chrome_driver.stop()

    def get_mongodb_uri(self):
        host = 'localhost' if self.DBHOST is None else self.DBHOST
        user_passwd_str = '' if self.DBUSER is None else '{0}:{1}@'.format(self.DBUSER, self.DBPASSWD)
        uri = "mongodb://{0}{1}/{2}".format(user_passwd_str, host, self.DB)
        return uri

    def dump_results_to_file(self, ds):
        with open('results.json', 'a') as f:
            json.dump(ds, f)
            f.write('\n')

    def save(self):
        import pymongo

        conn = pymongo.Connection(self.get_mongodb_uri(), safe=True)
        db = conn[self.DB]
        collection = db[self.COLLECTION]

        ds = {'when': self.when,
              'protocol': self.protocol,
              'ssl': self.ssl,
              'net_type': self.net_type,
              'net_up_bw': self.net_up_bw,
              'net_dw_bw': self.net_dw_bw,
              'net_rtt': self.net_rtt,
              'net_loss': self.net_loss,
              'results': self.results,
              'load_time': sum(self.results) / len(self.results),
              'deviation': 0,
              }

        try:
            collection.insert(ds)
        except Exception as e:
            print "ERROR({0}): {1}".format(e.errno, e.strerror)
            self.dump_results_to_file(ds)
        else:
            print "Test data saved to database."
            conn.close()

def main():
    # try here to close chromedriver server
    test = TestCase()
    try:
        test.run()
    except Exception as e:
        print "ERROR({0}): {1}".format(e.errno, e.strerror)
        print "chromedriver to be stopped."
    finally:
        test.stop()

    if test.args.dont_save:
        print "Test data not saved to database."
    else:
        test.save()

if __name__ == '__main__':
    main()
    #pass
