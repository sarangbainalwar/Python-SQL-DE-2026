print("importing my module...  ")

test = 'Test String'

def find_index(to_search, target):
    '''find the index of the value in a sequence or return -1 if not found'''
    for i,value in enumerate(to_search):
        if value == target:
            return i 
    return -1