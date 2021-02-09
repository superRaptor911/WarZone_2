from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import os.path


drive = None

def init(reAuth = False):
	print("Initiating pydrive")
	
	#Setup client secrets
	if os.path.isfile("client_secrets.json"):
		os.remove("client_secrets.json")
	
	f = open("client_secrets.json", "a")
	f.write("{\"web\":{\"client_id\":\"23942977559-9vlvhfernh8d9avl4dld4obdi8lin52o.apps.googleusercontent.com\",\"project_id\":\"brave-streamer-282114\",\"auth_uri\":\"https://accounts.google.com/o/oauth2/auth\",\"token_uri\":\"https://oauth2.googleapis.com/token\",\"auth_provider_x509_cert_url\":\"https://www.googleapis.com/oauth2/v1/certs\",\"client_secret\":\"FXTpCDmwFTpEFLAMCKKu9Rg5\",\"redirect_uris\":[\"http://localhost:8080/\"],\"javascript_origins\":[\"http://localhost:8080\"]}}")
	f.close()

	global drive
	gauth = GoogleAuth()

	# Try to load saved client credentials
	if not reAuth:
		gauth.LoadCredentialsFile("mycreds.txt")

	if gauth.credentials is None:
	    # Authenticate if they're not there
	    gauth.LocalWebserverAuth()
	elif gauth.access_token_expired:
	    # Refresh them if expired
	    gauth.Refresh()
	else:
	    # Initialize the saved creds
	    gauth.Authorize()

	# Save the current credentials to a file
	gauth.SaveCredentialsFile("mycreds.txt")
	drive = GoogleDrive(gauth)

	#Remove client sectrets
	os.remove("client_secrets.json")
	print("Initiation success")


#List contents of a folder
#Use recursive = True to display contents of sub-folders
def listFolder(folder_id = "", recursive = False, spaces = 0):
	if folder_id == "":
		folder_id = "root"
	# View all folders and file in your Google Drive
	fileList = drive.ListFile({'q': "'%s' in parents and trashed=false" % folder_id}).GetList()
	for file in fileList:
		for i in range(spaces):
			print("    ", end ="")

		if isFolder(file):
			print('*%s' % file['title'])
			
			#Recursively list sub-folder
			if recursive:
				listFolder(file['id'], True, spaces + 1)
		else:
			print('%s' % file['title'])


def getFile(title , folder_id = "root"):
	fileList = drive.ListFile({'q': "'%s' in parents and trashed=false" % folder_id}).GetList()
	titles = title.split("/")
	final_file = None

	#Iterate through titles
	for t in titles:
		flag1 = False

		for i in fileList:
		  if i['title'] == t:
		  	fileList = drive.ListFile({'q': "'%s' in parents and trashed=false" % i['id']}).GetList()
		  	flag1 = True
		  	final_file = i
		  	break

		#File/Dir does not exist
		if not flag1:
			return None
		
	return final_file



def isFolder(file):
	return file['mimeType']=='application/vnd.google-apps.folder'


#Function to download file from drive
def downloadFile(drive_path, output_name = "") -> bool:
	#Get File from drive
	file = getFile(drive_path)
	
	#Check existence of file
	if not file:
		print("%s does not exists in your drive")
		return False

	file_name = file['title']
	if output_name != "":
		file_name = output_name

	file_size = float(file['fileSize']) / 1048576.0


	print("Downloading %s of size %.3f MB" % (file['title'], file_size))
	file.GetContentFile(file_name)
	return True


#Function to create folder in your drive
def createFolder(folder_name):
	if folder_name == "":
		return "root"

	#Get folder names	
	folders = folder_name.split("/")
	files = drive.ListFile({'q': "'root' in parents and trashed=false"}).GetList()
	cur_folder_id = 'root'

	for f in folders:
		if f == "":
			break

		flag = False
		#Check if folders exists
		for i in files:
			#folder exists, switch to that folder
			if i['title'] == f and isFolder(i):
				flag = True
				files = drive.ListFile({'q': "'%s' in parents and trashed=false" % i['id']}).GetList()
				cur_folder_id = i['id']
				break

		#Folder not exists, Create and switch to that folder
		if not flag:
			folder = drive.CreateFile({'title': f, "mimeType": "application/vnd.google-apps.folder", 'parents': [{'id': cur_folder_id}]})
			folder.Upload()
			cur_folder_id = folder['id']
			print("Created Folder %s" %f)

	#return folder id
	return cur_folder_id



def uploadFile(src_path, dest_path = "", conflict_policy = "delete"):
	#Check existence of file
	if not os.path.isfile(src_path):
		print("Error : file %s does not exists" % src_path)
		return

	#Get file size
	file_size = float(os.stat(src_path).st_size) / 1048576.0

	strings = src_path.split("/")
	file_name = strings[len(strings) - 1]
	
	strings = dest_path.split("/")
	title = strings[len(strings) - 1]
	dest_path = dest_path[:-len(title)]

	
	#use filename as title if title is not set
	if title == "":
		title = file_name

	folder_id = createFolder(dest_path)
	file = getFile(title, folder_id)

	#Handle existing file with same title
	if file and not isFolder(file):
		print("File %s already exists in your drive" % title)
		if conflict_policy == "delete":
			print("Deleting %s from your drive" % title)
			file.Delete()
		else:
			print("Keeping both files")


	print("uploading file %s, size : %.3f MB" % (file_name, file_size))
	file = drive.CreateFile({'title': title, 'parents': [{'id': folder_id}]})
	file.SetContentFile(src_path)
	file.Upload()
