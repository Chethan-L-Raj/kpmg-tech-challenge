def get_values_for_keys(objects, keys):
  result = []
  def find_values(objects, keys):
        for key, value in objects.items():
            if key in keys:
                result.append(value)
            if type(value) == dict:
              find_values(value, keys)

  find_values(objects, keys)
  return result

input_objects = {'a': {'b': {'c': 1,'d': 2},'e': 3},'f': 4}

keys_to_find = ['a']

output = get_values_for_keys(input_objects, keys_to_find)
print("values =", output)