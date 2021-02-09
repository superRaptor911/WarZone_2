import EasyDrive

EasyDrive.init()
EasyDrive.uploadFile("bin.zip", "godot/warzone2/bin.zip")
print("Upload complete")
file = EasyDrive.getFile("godot/warzone2/bin.zip")

permission = file.InsertPermission({
                        'type': 'anyone',
                        'value': 'anyone',
                        'role': 'reader'})
file.Upload()

print("---------------------------------------------------")
print("Link to file :")
print(file["alternateLink"])
print("---------------------------------------------------")
