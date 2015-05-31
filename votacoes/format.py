import sys
for i in open(sys.argv[1],'r'):
    tokens = i.strip().split(',')
    if len(tokens) == 17:
        print ','.join(tokens)
