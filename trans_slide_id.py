import argparse
import os

parser = argparse.ArgumentParser(description='Match slide_id in csv file to the name of WSI slides')
parser.add_argument('--process_file', type=str, help='process_list_autogen.csv')
parser.add_argument('--csv_file', type=str, help='tcga_paad_clin.csv')
parser.add_argument('--new_csv_file', type=str, help='TCGA-PAAD.csv')
args = parser.parse_args()


def main():
    slide_list = []
    with open(args.process_file) as fr:
        for line in fr.readlines():
            recs = line.strip().split(',')
            if recs[0] == 'slide_id':
                continue
            slide = os.path.splitext(recs[0])[0]
            #print(slide)
            if slide not in slide_list: slide_list.append(slide)
    fw = open(args.new_csv_file, "w")
    with open(args.csv_file) as fr:
        for line in fr.readlines():
            recs = line.strip().split(',')
            records = [rec.strip('"') for rec in recs]
            #print(recs)
            if records[0] == 'slide_id':
                fw.write(line)
            else:
                for slide in slide_list:
                    if records[0] in slide:
                        fw.write(",".join([slide]+records[1:])+'\n')
                        break
    fw.close()


if __name__ == "__main__":
    main()
    print("finished!")
