# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
from dfply import *
import pandas as pd
import yaml   as y
import sqlite3

# ---- declare-globals ---------------------------------------------------------

with open(r'config.yml', 'r') as f:
    cfg = y.safe_load(f.read().replace('!expr', ''))

# ---- load-data ---------------------------------------------------------------
ds = pd.read_csv(cfg['default']['path_subject_1_raw'])
# ds = pd.read_csv("data-public/raw/subject-1.csv")

# ---- tweak-data --------------------------------------------------------------
ds = (
    ds >>
    select(
        X.subject_id,
        X.county_id,
        X.gender_id,
        X.race,
        X.ethnicity
    ) >>
    arrange(X.subject_id)
)

print(ds.head(3))

# ---- save-to-db --------------------------------------------------------------
cnn = sqlite3.connect(cfg['default']['path_database'])
cnn.execute(
    "\
        DROP TABLE if exists subject_py;\
    "
)
cnn.execute(
    "\
        CREATE TABLE `subject_py` (\
            subject_id      int   primary key,\
            county_id       int   not null,\
            gender_id       float not null,\
            race            float not null,\
            ethnicity       float not null\
        )\
    "
)
ds.to_sql("subject_py", cnn, if_exists = "append", index = False)
cnn.close()
