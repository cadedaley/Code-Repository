# This script takes a ip_addresses.csv file and then checks those IP Addresses for open 9100 ports.
# Upon finding an IP, it will send a Zebra Printer command in SGD/ZPL to gather inventory information and export it to a XLSX file

import socket
import os
import csv
from openpyxl import Workbook

def send_command_to_printer(printer_ip, command, timeout=2):
    try:
        # Establish a TCP connection to the printer
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            sock.connect((printer_ip, 9100))
            
            # Send the command to the printer
            sock.sendall(command.encode('ascii') + b'\r\n')
            
            # Read the response from the printer
            response = sock.recv(1024).decode('ascii').strip()
        
        return response
    except (socket.timeout, ConnectionRefusedError, OSError):
        return None

def store_data_in_excel(data, excel_file):
    # Create the directory if it doesn't exist
    directory = os.path.dirname(excel_file)
    os.makedirs(directory, exist_ok=True)
    
    # Create a new workbook and select the active sheet
    workbook = Workbook()
    sheet = workbook.active
    
    # Write the headers
    headers = ['Printer IP', 'Serial Number', 'WLAN MAC Address', 'Wired LAN MAC Address', 'F/W Version']
    sheet.append(headers)
    
    # Write the data to the Excel file
    for row in data:
        sheet.append(row)
    
    # Save the workbook
    workbook.save(excel_file)

# Example usage
ip_file = r'C:\Temp\ip_addresses.csv'
excel_file = r'C:\Temp\printer_data.xlsx'

serial_number_command = '! U1 getvar "device.unique_id"'
wlan_mac_command = '! U1 getvar "wlan.mac_addr"'
wired_mac_command = '! U1 getvar "internal_wired.mac_addr"'
fw_version_command = '! U1 getvar "appl.name"'

data = []

# Read IP addresses from the CSV file
with open(ip_file, 'r') as file:
    csv_reader = csv.reader(file)
    for row in csv_reader:
        printer_ip = row[0]
        
        serial_number = send_command_to_printer(printer_ip, serial_number_command)
        
        if serial_number is None:
            print(f"Connection failed for printer IP: {printer_ip}")
            data.append([printer_ip, 'Unreachable', 'Unreachable', 'Unreachable', 'Unreachable'])
            continue
        
        wlan_mac = send_command_to_printer(printer_ip, wlan_mac_command)
        fw_version = send_command_to_printer(printer_ip, fw_version_command)
        
        if wlan_mac == '"00:00:00:00:00:00"':
            wlan_mac = 'N/A'
            wired_mac = send_command_to_printer(printer_ip, wired_mac_command)
        else:
            wired_mac = 'N/A'
        
        data.append([printer_ip, serial_number, wlan_mac, wired_mac, fw_version])

store_data_in_excel(data, excel_file)
print(f"Data stored in: {excel_file}")
