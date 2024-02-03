import re

with open("DelStringFile.txt") as file:
    ips = re.findall(r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b", file.read())
    for ip in ips:
        print(ip)