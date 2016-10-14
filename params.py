# coding: utf-8
import os
import sys
import re

cwd = re.compile(".*\/").search(os.path.realpath(__file__)).group(0)

parameters = {
           "port" : 10000,
           "sslport" : -1,
           "host" : "127.0.0.1",
           "keepsession" : True,
           "debug_host" : False,
           "log" : False,
           "tlog" : False,
           "cert" : cwd + "mica/mica.der",
           "privkey" : False,
           "slaves" : False,
           "slave_port" : False,
           "scratch" : os.environ["HOME"] + "/Documents/",
           "session_dir" : os.environ["HOME"] + "/Documents/",
           "duplicate_logger" : False,
           "couch_adapter_type" : "iosMicaServerCouchbaseMobile",
           "transreset" : False,
           "transcheck" : False,
           "mobileinternet" : False,
           "serialize_couch_on_mobile" : True,

           "trans_id" : False,
           "trans_secret" : False,

           "main_server" : "readalien.com",
           "couch_server" : "db.readalien.com",
           "couch_proto" : "https",
           "couch_port" : "443",

            # Only used during development by uncommenting
            # a hard-coded HTTP listener for debugging purposes.
            # couchdb listener is not enabled in the app store
           "local_database" : "mica",
           "local_username" : False,#"admin",
           "local_password" : False,#"devtest",
           "local_port" : 5984,
}

