# Justin 2019
# CLI to read excel files


import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("path", help='Path to excel file')

args = parser.parse_args()


df = pd.read_excel(args.path)
print(df)
