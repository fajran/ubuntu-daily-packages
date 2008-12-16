
import os
import popen2
import re
import sys

BASE="data"

__all__ = ["cat"]

def cat(group, code, section, arch, rev="HEAD"):
	global BASE
	pwd = os.getcwd()
	os.chdir(BASE)

	try:

		# Get Object ID

		find = "files/%s/%s/%s/files.%s" % (group, code, section, arch)

		cmd = "git ls-tree -r %s" % rev
		(sout, sin, serr) = popen2.popen3(cmd)

		info = None
		for line in sout:
			line = line.strip()

			if line.endswith(find):
				info = re.split(u'\s+', line)
				break
		
		if not info:
			return None
		
		(perm, type, object, file) = info

		# Read file

		cmd = "git cat-file blob %s" % object
		(sout, sin, serr) = popen2.popen3(cmd)
		
		return sout

	finally:
		os.chdir(pwd)

def diff(group, code, section, arch, start=None, end="HEAD"):
	global BASE
	pwd = os.getcwd()
	os.chdir(BASE)

	try:

		path = "files/%s/%s/%s/files.%s" % (group, code, section, arch)

		if start == None:
			rev = end
		else:
			rev = "%s %s" % (start, end)

		cmd = "git diff %s -- %s" % (rev, path)

		(sout, sin, serr) = popen2.popen3(cmd)

		return sout

	finally:
		os.chdir(pwd)

def changes(group, code, section, arch, start=None, end="HEAD"):
	res = diff(group, code, section, arch, start, end)

	re_file = re.compile(u'^--- ..files/([^/]+)/([^/]+)/([^/]+)/files.(.+)$')
	
	added = []
	removed = []

	inside = False
	for line in res:
		line = line.rstrip()

		if not inside:
			if line.startswith("---"):
				(group, code, section, arch) = re_file.match(line).groups()

			if line.startswith('@@'):
				inside = True

		else:
			if line[0] == ' ':
				pass

			elif line[0:1] == '@@':
				pass

			elif line[0:4] == 'diff':
				inside = False

			elif line[0] == '+':
				added.append(line[1:])

			elif line[0] == '-':
				removed.append(line[1:])

	return (added, removed)

def test_changes():
	#changes("ubuntu", "hardy-updates", "main", "i386", "tags/2008-12-15")
	(a, r) = changes("ubuntu", "hardy-updates", "*", "i386", "tags/2008-12-15")

	print "added: %d" % len(a)
	for f in a:
		print "+ %s" % f

	print "removed: %d" % len(r)
	for f in r:
		print "- %s" % f
	

def test_cat():
	res = cat("ubuntu", "hardy-updates", "main", "i386", "tags/2008-12-15")

	if not res:
		print "Not found"
		sys.exit(1)
	
	else:

		for line in res:
			print line.rstrip()

def test_diff():
	res = diff("ubuntu", "hardy-updates", "main", "i386", "tags/2008-12-15")
	res = diff("ubuntu", "hardy-updates", "*", "i386", "tags/2008-12-15")
	for line in res:
		print line.rstrip()


if __name__ == "__main__":
	test_changes()

