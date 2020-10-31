# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
from dfply import *
import pandas as pd
import yaml   as y

# ---- declare-globals ---------------------------------------------------------

with open(r'config.yml', 'r') as f:
    config = y.safe_load(f.read().replace('!expr', ''))

# ---- load-data ---------------------------------------------------------------
ds = pd.read_csv(config['default']['path_subject_1_raw'])
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
