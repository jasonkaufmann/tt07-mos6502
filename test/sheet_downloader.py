import os
import requests
import io
import google.auth
from google.auth.transport.requests import Request
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
import googleapiclient.http

# Path to your service account credentials JSON file
CREDENTIALS_FILE = '/Users/jasonkaufmann/projects/google-cloud-keys/sheets-to-excel-426920-8d2dfa45ab3f.json'

# The ID of your Google Sheet
SPREADSHEET_ID = '1-L1wdx-0zM9c0ryWbvyelTP7A6zHdrYMIoM-KRMMrjo'

# Name for the downloaded file
FILE_NAME = 'ISA.xlsx'

def download_google_sheet_as_xlsx(credentials_file, spreadsheet_id, file_name):
    # Authenticate using service account credentials
    creds = Credentials.from_service_account_file(credentials_file, scopes=['https://www.googleapis.com/auth/drive'])

    # Build the Drive API service
    service = build('drive', 'v3', credentials=creds)

    # Export Google Sheet as XLSX
    request = service.files().export_media(fileId=spreadsheet_id, mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    # Get current directory
    current_directory = os.getcwd()

    # Make the request and save the file
    file_path = os.path.join(current_directory, file_name)
    fh = io.FileIO(file_path, 'wb')
    downloader = googleapiclient.http.MediaIoBaseDownload(fh, request)
    done = False
    while done is False:
        status, done = downloader.next_chunk()
        print(f'Download {int(status.progress() * 100)}%.')
        print("Downloaded ISA.xlsx")

if __name__ == '__main__':
    download_google_sheet_as_xlsx(CREDENTIALS_FILE, SPREADSHEET_ID, FILE_NAME)
