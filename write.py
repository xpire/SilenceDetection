import os, csv

parent_dir = './match/norm/cut_dc_hp10_halfpadding/'
all_dirs = [ name for name in os.listdir(parent_dir) if os.path.isdir(os.path.join(parent_dir, name)) ]
for dir in all_dirs:
    for subdir, dirs, files in os.walk(os.path.join(parent_dir, dir)):
        files= sorted(files, key=lambda x: int((x.split(".")[1])))

        with open(os.path.join(subdir,"./filenames.csv"),'w+', newline="") as f:
            w=csv.writer(f)

            for filename in files:
                w.writerow([filename, ""])
