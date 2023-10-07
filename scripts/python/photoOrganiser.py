# Sorts photos into MM/YYYY folders

import os
from PIL import Image
from PIL.ExifTags import TAGS
import shutil
import hashlib



searchPath      = "Y:\Media"
destinationPath = "Y:\OrganisedNEW"

def maybeRenameImage(file, destination):
    if os.path.exists(destination):
        try:
            file_size = os.path.getsize(file)
            destination_size = os.path.getsize(destination) 
            if file_size != destination_size:
                srcmd5 = hashlib.md5()
                dstmd5 = hashlib.md5()
                with open(file, "rb") as fh:
                    data = fh.read()
                    srcmd5.update(data)
                with open(destination, "rb") as fh:
                    data = fh.read().strip()
                    dstmd5.update(data)

                if srcmd5.hexdigest()==dstmd5.hexdigest():
                    print(f"skipping {file} due to MD5 match")
                    return False
                else:
                    oldext = os.path.splitext(destination)[1]
                    oldfilename = os.path.splitext(destination)[0]

                    destination=f'{oldfilename}a{oldext}'
                    maybeRenameImage(file, destination)

            else: 
                print(f"skipping {file} due to identical size")
                return False
        except:
            return False
    else:
        pass
    return destination

def getPathFromExif(filename):
    try:
        img=Image.open(filename)
        exif_table={}
        for k, v in img.getexif().items():
            tag=TAGS.get(k)
            exif_table[tag]=v
            datepath=exif_table
        #print(f'Image {filename}')
        datetime=exif_table["DateTime"]
        datearray=datetime.replace(" ", ":").split(":")
        return f"{destinationPath}/{'/'.join(datearray)[:7]}/{os.path.basename(filename)}"
    except:
        return f"{destinationPath}/unsorted/{os.path.basename(filename)}"


def findimages(dir):
    ext = [".jpg", ".JPG", ".jpeg", ".JPEG", ".mov", ".avi", ".MPG", ".mp4", ".DNG", ".HEIC", ".CR2", ".gif", ".MTS", ".3gp"]
    images=[]
    for root, dirs, files in os.walk(dir):
        for file in files:
            if file.endswith(tuple(ext)):
                path=os.path.join(root, file)
                images.append(path.replace("\\", "/"))
    return images

print("Building image list...")
filenames=findimages(searchPath)

for file in filenames:
    destination=getPathFromExif(file)
    dstfilename=maybeRenameImage(file, destination)
    if dstfilename:
        try: 
            if not os.path.isdir(os.path.dirname(destination)):
                os.makedirs(os.path.dirname(destination))
            print(f"{file}::{dstfilename}")
            shutil.copy2(file, dstfilename)
            
        except Exception as ex:
            print(ex)
            fh = open("sortfailures.log", "a")
            fh.write(f"Failed to move {file} due to Exception: {ex}\r")
            pass