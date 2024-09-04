# This script takes a subnets.csv file and then checks those subnets for open 9100 ports.
# Upon finding an open port, it will send a Zebra Printer command in SGD/ZPL to gather inventory information and export it to a XLSX file

import socket
import os
import csv
from ipaddress import ip_network
from concurrent.futures import ThreadPoolExecutor
from openpyxl import Workbook

def is_port_open(ip, port, timeout=1):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            result = sock.connect_ex((str(ip), port))
            return result == 0
    except socket.error:
        return False

def send_command_to_printer(printer_ip, command, timeout=2):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            sock.connect((printer_ip, 9100))
            sock.sendall(command.encode('ascii') + b'\r\n')
            response = sock.recv(1024).decode('ascii').strip()
        return response
    except (socket.timeout, ConnectionRefusedError, OSError):
        return None

def store_data_in_excel(data, excel_file):
    directory = os.path.dirname(excel_file)
    os.makedirs(directory, exist_ok=True)
    
    workbook = Workbook()
    sheet = workbook.active
    
    headers = ['Printer IP', 'Serial Number', 'WLAN MAC Address', 'Wired LAN MAC Address', 'F/W Version']
    sheet.append(headers)
    
    for row in data:
        sheet.append(row)
    
    workbook.save(excel_file)

def scan_subnet(subnet):
    data = []
    for ip in ip_network(subnet).hosts():
        if is_port_open(ip, 9100):
            printer_ip = str(ip)
            serial_number = send_command_to_printer(printer_ip, '! U1 getvar "device.unique_id"')
            
            if serial_number is None:
                continue
            
            wlan_mac = send_command_to_printer(printer_ip, '! U1 getvar "wlan.mac_addr"')
            fw_version = send_command_to_printer(printer_ip, '! U1 getvar "appl.name"')
            
            if wlan_mac == '"00:00:00:00:00:00"':
                wlan_mac = 'N/A'
                wired_mac = send_command_to_printer(printer_ip, '! U1 getvar "internal_wired.mac_addr"')
            else:
                wired_mac = 'N/A'
            
            data.append([printer_ip, serial_number, wlan_mac, wired_mac, fw_version])
    return data

# Example usage
subnet_file = r'C:\Temp\subnets.csv'
excel_file = r'C:\Temp\ZebraPrinterInventory.xlsx'

subnets = []
with open(subnet_file, 'r') as file:
    csv_reader = csv.reader(file)
    for row in csv_reader:
        subnets.append(row[0])

with ThreadPoolExecutor() as executor:
    futures = []
    for subnet in subnets:
        future = executor.submit(scan_subnet, subnet)
        futures.append(future)
    
    data = []
    for future in futures:
        data.extend(future.result())

store_data_in_excel(data, excel_file)
print(f"Data stored in: {excel_file}")

store_data_in_excel(data, excel_file)
print(f"Data stored in: {excel_file}")
