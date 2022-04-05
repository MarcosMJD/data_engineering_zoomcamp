"""
ID            1-11   Character
LATITUDE     13-20   Real
LONGITUDE    22-30   Real
ELEVATION    32-37   Real
STATE        39-40   Character
NAME         42-71   Character
GSN FLAG     73-75   Character
HCN/CRN FLAG 77-79   Character
WMO ID       81-85   Character
"""

file_path = '.\\'
file_name = 'stations.txt'
header = ['id','latitude','longitude','elevation','state','name','gsn_flag','hcn_crn_flag','wmo_id']
is_text_column = [True,False,False,False,True,True,True,True,True]
column_indexes = [[1,11],[13,20],[22,30], [32,37], [39,40], [42,71], [73,75], [77,79], [81,85]]

if __name__ == "__main__":

  with open(f'{file_path}{file_name}') as f_t:
    with open(f"{file_path}{file_name.replace('txt','csv')}", "w") as f_c:
      f_c.writelines([','.join(header)+'\n'])
      for line in f_t:
        columns = []
        for i, index in enumerate(column_indexes):
          text = line[index[0]:index[1]].strip()
          if is_text_column:
            columns.append('"'+text+'"')
          else:
            columns.append(line[index[0]:index[1]])

        f_c.writelines([','.join(columns) + '\n'])
  
 