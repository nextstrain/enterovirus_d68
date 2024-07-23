import os
import glob
import shutil
import datetime

# This script copies the latest files from vp1/auspice and genome/auspice to auspice/ folder, while renaming to include the date

#run this script from the root of enterovirus_d68 folder

if __name__ == '__main__':

    print("Copying latest files from vp1/auspice and genome/auspice to auspice/ folder, while renaming to include the date")

    two_dirs = ["vp1", "genome"]

    for cur_dir in two_dirs:

        #start of split
        print("Processing", cur_dir)

        search_dir = cur_dir+"/auspice/"

        #looking for 3 types of file to copy
        file_endings = [".json", "_root-sequence.json", "_tip-frequencies.json"]
        file_endings[0] = cur_dir+file_endings[0]

        #list files and sort by date (oldest last)
        files = list(filter(os.path.isfile, glob.glob(search_dir + "*")))
        files.sort(key=lambda x: os.path.getmtime(x))

        poss_files = files[-3:]

        #check that each file ending in file_endings appears exactly once in poss_files
        for ending in file_endings:
            if sum([file.endswith(ending) for file in poss_files]) != 1:
                print("Ending ", ending, " not found exactly once in ", poss_files)
                exit()

        #if all is good, rename these files with dates
        # first get the last modified date of the file, then add it to the end of the file name
        for file in poss_files:
            mtime = os.path.getmtime(file)
            timestring = datetime.datetime.fromtimestamp(mtime).strftime('%Y-%m-%d')
            new_name = file.replace(search_dir, "auspice/")
            new_name = new_name.replace(cur_dir, cur_dir+"-"+timestring)
            shutil.copyfile(file, new_name)