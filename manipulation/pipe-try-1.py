from dfply import *
import yaml

# print(diamonds)
# diamonds >>= head(3)
# print(diamonds)
ds = (diamonds >>
  head(10))

print(ds)
stream = file('config.yml', 'r')

a <- yaml.load(stream)
print(a)