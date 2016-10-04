#!/usr/bin/env python
# coding: utf-8
__version__ = "0.5.4"

import threading
import base64
import re
import os
import urllib2
from time import sleep
import sys
import codecs
from threading import current_thread

class MobileInternet(object) :
    def __init__(self, couch) :
        self.couch = couch

    def connected(self) :
        return self.couch.connected().UTF8String()

try :
    from pyobjus import autoclass, objc_f, objc_str as String, objc_b as Boolean
    CouchBaseClass = autoclass('mica')
    CouchBaseAlloc = CouchBaseClass.alloc()
    couch = CouchBaseAlloc.init()
except ImportError, e :
    couch = False
    print "Warning: pyobjus could not be imported"

cwd = re.compile(".*\/").search(os.path.realpath(__file__)).group(0)
sys.path = [cwd, cwd + "mica/"] + sys.path
#print "Path is: " + str(sys.path)

print "Loading initial parameters"
from params import parameters

print "Loading certificate file for couch"
fh = open(parameters["cert"], 'r')
cert = fh.read()
fh.close()

#print dir(couch)

print "Loading mica services"

def startpoll(*args) :
    try: 
        print "Trying to open port..."
        urllib2.urlopen('http://localhost:10000/serve/favicon.ico')
        print "Open success. Creating webview..."
        couch.webview_(String("http://localhost:10000/"))
        print "Webview created. Done."
        return
    except urllib2.HTTPError, e:
        print("Failed to access twisted: " + str(e.code))
    except urllib2.URLError, e:
        print("Failed to access twisted: " + str(e.args))

    threading.Timer(1, startpoll).start()

if __name__ == '__main__':
    #certset = couch.security_(String(parameters["cert"]))
    if couch :
        mobile_internet = MobileInternet(couch)
        for db in [parameters["local_database"], "files", "sessiondb"] :
            port = couch.start_(String(db))
            if port == -1 :
                print "AAAHHHHHH. FAILURE."

        print "Python before Go, we are on thread: " + str(current_thread())
        from mica.mica import go, second_splash
        from mica.common import pre_init_localization
        pre_init_localization(couch.get_language().UTF8String())
        parameters["couch"] = couch
        parameters["mobileinternet"] = mobile_internet

        couch.webviewstatic_(String(second_splash()));
        threading.Timer(5, startpoll).start()

        go(parameters)
    else :
        port = 0

    print "Port received: " + str(port)

    while True:
        print "Uh oh. Problem in MICA. May need to restart application."
        sleep(1)
