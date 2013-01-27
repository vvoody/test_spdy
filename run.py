from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome import service


def main():
    srv = service.Service('/home/vvoody/.virtualenvs/selenium/bin/chromedriver')
    srv.start()
    # capabilities = {'chrome.binary': '/opt/google/chrome/google-chrome'}
    # setting startup options by 'chrome.switches' not working anymore

    chrome_options = Options()
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--use-spdy=off")
    chrome_options.add_argument("--enable-http-pipelining")
    capabilities = chrome_options.to_capabilities()
    #driver = webdriver.Chrome(chrome_options=chrome_options)

    driver = webdriver.Remote(srv.service_url, capabilities)

    driver.get('http://www.google.com/');
    driver.quit()
    srv.stop()


if __name__ == "__main__":
    main()
