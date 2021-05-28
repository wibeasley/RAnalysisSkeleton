import yaml

with open(r'config.yml') as file:
    # The FullLoader parameter handles the conversion from YAML
    # scalar values to Python the dictionary format
    config = yaml.load(file.read().replace('!expr', ''), Loader=yaml.FullLoader)['default']

# print(config)

print(config['path_subject_1_raw'])
