#!/usr/bin/python
# -*- coding: utf-8 -*-
# This script is for send automated csv via gmail to custom channel from DataVault.
# 1) Put custom_channel.py and create_csv.sql in the path below
# 2) Replace host, dbname, port, user, password, pah, from_addr, email_pass below
# 3) Run command: python custom_channel.py <bundle_id> <platform> <ad_network_name> <tenjin_campaign_id> <to_email_address>
import os.path
import smtplib
import psycopg2
import csv
import sys
import datetime

from email import Encoders
from email.MIMEBase import MIMEBase
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

# DataVault hostname
host = 'host'
# DataVault database name
dbname = 'dbname'
# DataVault port number
port = '5439'
# DataVault username
user = 'user'
# DataVault password
password = 'password'
#File path you put this script and sql file
path = '/Users/Makoto/Desktop/tmp/'
#Email address you want to send csv from
from_addr = 'makoto@tenjin.io'
#Email password
email_pass = 'abc'

def create_csv():

    connenction_string = "dbname=" + dbname + ' port=' + port + ' user=' + user + ' password=' + password + ' host=' + host
    print "Connecting to \n        ->%s" % (connenction_string)
    conn = psycopg2.connect(connenction_string)
    cur = conn.cursor()

    fd = open(path + 'create_csv.sql', 'r')
    sqlFile = fd.read()

    sqlFile2 = sqlFile.replace('BUNDLE_ID',args[1]).replace('PLATFORM',args[2]).replace('NETWORK',args[3]).replace('TENJIN_CAMPAING_ID',args[4])
    fd.close()
    print sqlFile2
    cur.execute(sqlFile2)
    field_names = [i[0] for i in cur.description]
    rows = cur.fetchall()

    with open(path + args[1] + '-' + args[2] + '-' + args[3] + '.csv', 'w') as f:
        writer = csv.writer(f, lineterminator='\n')
        writer.writerow(field_names)    
        writer.writerows(rows)

def create_message(from_addr, to_addr, subject, body, mime, attach_file):

    msg = MIMEMultipart()
    msg["Subject"] = subject
    msg["From"] = from_addr
    msg["To"] = to_addr

    body = MIMEText(body)
    msg.attach(body)

    attachment = MIMEBase(mime['type'],mime['subtype'])
    file = open(attach_file['path'])
    attachment.set_payload(file.read())
    file.close()
    Encoders.encode_base64(attachment)
    msg.attach(attachment)
    attachment.add_header("Content-Disposition","attachment", filename=attach_file['name'])

    return msg

def send(from_addr, to_addrs, msg):

    host, port = 'smtp.gmail.com', 465
    smtp = smtplib.SMTP_SSL(host, port)
    smtp.ehlo()
    smtp.login(from_addr, email_pass)
    smtp.sendmail(from_addr, to_addrs, msg.as_string())
    smtp.close()

if __name__ == '__main__':
    args = sys.argv

    create_csv()

    to_addr = args[5]
    subject = "test" 
    body = "test body"
    mime={'type':'text', 'subtype':'comma-separated-values'}
    attach_file={'name':args[1] + '-' + args[2] + '-' + args[3] + '.csv', 'path': path + args[1] + '-' + args[2] + '-' + args[3] + '.csv'}
    msg = create_message(from_addr, to_addr, subject, body, mime, attach_file)
    send(from_addr, [to_addr], msg)
