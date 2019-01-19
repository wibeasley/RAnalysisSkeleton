from dfply import *
import pandas as pd

flight_data = pd.read_csv('flight.csv')
flight_data.head()
(ds2 = flight_data >>
  select(X.year)
)

(ds2 =
  flight_data >>
 select(X.year, X.month, X.day) >>
 # drop(X.third_col) >>
 head(3))



ds3 = (diamonds >>
 group_by(X.cut) >>
 mutate(
   price_lead = lead(X.price),
   price_lag  = lag(X.price) * -1
 ) >>
 head(2) >>
 select(
   X.cut,
   X.price,
   X.price_lead,
   X.price_lag
  )
)
