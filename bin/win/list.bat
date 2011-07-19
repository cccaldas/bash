#!/usr/bin/env python

import os, types, stat, pwd, time

# Align center is not supported because of the terrible form :)
ALIGN_RIGHT   = 0x0001
ALIGN_LEFT    = 0x0002
PADDING_LEFT  = 0x0010
PADDING_RIGHT = 0x0020
PADDING_ALL   = PADDING_LEFT | PADDING_RIGHT

def _rpad_to_maxlen(slist, padchar=' '):
    maxlen = max(map(len, slist))
    res = map(lambda s: s + padchar * (maxlen - len(s)), slist)
    return res

def _lpad_to_maxlen(slist, padchar=' '):
    maxlen = max(map(len, slist))
    res = map(lambda s: padchar * (maxlen - len(s)) + s, slist)
    return res

def test_mask(mask, flag):
    '''
    tests mask for all bits of flag set
    '''
    return mask & flag == flag

def _align_para(para, mode):
    if test_mask(mode, ALIGN_RIGHT):
        para = _lpad_to_maxlen(para) # little confusing: right align == left padding
    elif test_mask(mode, ALIGN_LEFT):
        para = _rpad_to_maxlen(para)
    else:
        raise ValueError, "NO ALIGN SPECIFIED!"

    if test_mask(mode, PADDING_LEFT):
        para = map(lambda x: ' ' + x, para)
    if test_mask(mode, PADDING_RIGHT):
        para = map(lambda x: x + ' ', para)

    return para

def _glue_cols(col1, col2):
    return map(lambda x: '%s|%s' % (x[0], x[1]), zip(col1, col2))

def _has_column_headers(cols):
    fail_count = 0
    for c in cols:
        try:
            a = c[2]
        except IndexError:
            fail_count += 1
    return fail_count == 0

def _join_to_list(*arguments):
    '''
    join all parameters to one list, 
    expanding lists and tuples
    '''
    res = list()
    for arg in arguments:
        if isinstance(arg, types.ListType):
            res.extend(arg)
        elif isinstance(arg, types.TupleType):
            res.extend(list(arg))
        else:
            res.append(arg)
    return res

def format_table(cols):
    # 1. aligning data
    if len(cols) == 0:
        return list()

    header_present = _has_column_headers(cols)
    if header_present:
        # prefix all data with headers // TODO: alignment set to center 
        cols = map(lambda x: [_join_to_list(x[2], x[0]), x[1] ], cols)

    cols2 = map(lambda x: _align_para(x[0], x[1]), cols)
    if len(cols2) == 0:
        return list()

    empty_vert_border = [ '' ] * len(cols2[0])

    cols2.append(empty_vert_border)
    cols2.insert(0, empty_vert_border)

    glued_cols = reduce(_glue_cols, cols2)
    if len(glued_cols) == 0:
        return list()

    border = '=' * len(glued_cols[0])
    glued_cols.insert(0, border)
    glued_cols.append(border)
    if header_present:
        glued_cols.insert(2, border)  # insert delimiter berween header and values        

    return glued_cols

def demo():
    nums = [ '1', '2', '3', '4' ]
    speeds = [ '100', '10000', '1500', '12' ]
    desc = [ '', 'label 1', 'none', 'very long description' ]
    lines = format_table( [(nums, ALIGN_RIGHT|PADDING_ALL, 'FILE'), 
                           (speeds, ALIGN_RIGHT|PADDING_ALL, 'SIZE'), 
                           (desc, ALIGN_LEFT|PADDING_ALL, 'DESC')] )


def convert_bytes(bytes):
	bytes = float(bytes)
	if bytes >= 1099511627776:
		terabytes = bytes / 1099511627776
		size = '%.2fT' % terabytes
	elif bytes >= 1073741824:
		gigabytes = bytes / 1073741824
		size = '%.2fG' % gigabytes
	elif bytes >= 1048576:
		megabytes = bytes / 1048576
		size = '%.2fM' % megabytes
	elif bytes >= 1024:
		kilobytes = bytes / 1024
		size = '%.2fK' % kilobytes
	else:
		size = '%.2fb' % bytes
	return size

def text_color(text, color):
	"""docstring for colored"""
	if color == 'yellow':
		text = '\033[93m' + text
	elif color == 'blue':
		text = '\033[94m' + text
	elif color == 'default':
		text = '\x1b[39m' + text
	elif color == 'cyan':
		text = '\x1b[36m' + text
	elif color == 'green':
		text = '\x1b[32m' + text
	elif color == 'purple':
		text = '\x1b[35m' + text
	elif color == 'red':
		text = '\x1b[31m' + text
		
	text += '\033[0m'
	return text
	
def text_style(text, style):
	
	if style == 'bold':
		text = '\x1b[1m' + text
	
	text += '\033[0m'
	return text

def get_permissions(file):
	mode=stat.S_IMODE(os.lstat(file)[stat.ST_MODE])
	perms="-"
	for who in "USR", "GRP", "OTH":
		for what in "R", "W", "X":
			if mode & getattr(stat,"S_I"+what+who):
				perms=perms+what.lower()
			else:
				perms=perms+"-"
	
	return perms

def get_dirs(path):
	items 	= os.listdir(path)
	dirs 	= []
	for item in items:
		if stat.S_ISDIR(os.stat(item).st_mode):
			dirs.append(item)
	
	return dirs
	
def get_files(path):
	items	= os.listdir(path)
	files	= []
	
	for item in items:
		if stat.S_ISDIR(os.stat(item).st_mode) == False:
			files.append(item)
	
	return files

files 	= get_files('.')
dirs 	= get_dirs('.')
items	= []

names 		= []
sizes 		= []
permissions = []
owners		= []
updates		= []

#dir
for item in get_dirs('.'):
	color = 'cyan'
	names.append(text_color(item + '/', color))
	sizes.append(text_color('-', color))
	permissions.append(text_color(get_permissions(item), color))
	owners.append(text_color(pwd.getpwuid(os.stat(item).st_uid)[0], color))
	updates.append(text_color('', 'default'))

#file
for item in get_files('.'):
	color = 'default'
	names.append(text_color(item, color))
	sizes.append(text_color(convert_bytes(os.stat(item).st_size), color))
	permissions.append(text_color(get_permissions(item), color))
	owners.append(text_color(pwd.getpwuid(os.stat(item).st_uid)[0], color))	
	updates.append(text_color(time.ctime(os.path.getmtime(item)), color))
	
print ''
print 'List of:' + os.getcwd()

lines = format_table( [(names, ALIGN_LEFT|PADDING_ALL, text_color('NAME', 'default')),
						(sizes, ALIGN_LEFT|PADDING_ALL, text_color('SIZE', 'default')),
						(permissions, ALIGN_LEFT|PADDING_ALL, text_color('PERMISSIONS', 'default')),
						(owners, ALIGN_LEFT|PADDING_ALL, text_color('OWNER', 'default')),
						(updates, ALIGN_LEFT|PADDING_ALL, text_color('LAST MODIFIED', 'default'))
						])

print '\n'.join(lines)

print ''