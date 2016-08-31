#!/usr/bin/env python

#
# Usage: may need to 'pip install localizable' before running this script
#

import codecs
import localizable
import os

class ASAPPLocalizedStringFinder(object):
    SOURCE_ROOT = 'ASAPP'
    SOURCE_EXTENSIONS = ('.swift')

    def __init__(self):
        self.strings = self.process_directory(self.SOURCE_ROOT)

    def process_directory(self, dir):
        strings = {}
        for root, dirs, files in os.walk(dir):
            for name in files:
                if os.path.splitext(name)[1] not in self.SOURCE_EXTENSIONS:
                    continue
                self.process_file(strings, os.path.join(root, name))
        return strings

    def process_file(self, strings, path):
        with open(path) as f:
            for line in f.readlines():
                self.scan_line(strings, line)

    def scan_line(self, strings, line):
        MARKER_START = 'ASAPPLocalizedString("'
        MARKER_END = '")'
        start = 0
        while True:
            index = line.find(MARKER_START, start)
            if index < 0:
                return
            end = line.find(MARKER_END, index)
            if end < 0:
                return
            string = unicode(line[index + len(MARKER_START):end], 'utf8')
            strings[string] = {
                'key': string,
                'value': string,
                'comment': '',
            }
            start = end


class FileReader(object):
    LOCALIZABLE_ROOT = 'Resources/Localizations'
    LOCALIZABLE_NAME = 'Localizable.strings'
    MASTER_LOCALIZATION = 'en.lproj'
    LOCALIZATIONS = ('es.lproj', 'ko.lproj')

    def __init__(self, localization):
        self.strings = self.read_strings(localization)

    def read_strings(self, localization):
        path = os.path.join(self.LOCALIZABLE_ROOT, localization, self.LOCALIZABLE_NAME)
        strings = localizable.parse_strings(filename=path)
        return dict((d['key'], d) for d in strings)


def write_file(path, strings):
    with codecs.open(path, 'w', 'utf-8') as f:
        keys = sorted(strings, key=lambda s: s.lower())
        for key in keys:
            info = strings[key]
            display_string = info['value'].replace('"', '\\"').replace('\n', '\\n')
            f.write(u'/*{}*/\n'.format(info['comment']))
            f.write(u'"{}" = "{}";\n'.format(key, display_string))


def main():
    # Find all ASAPPLocalizableStrings in the source code
    source_strings = ASAPPLocalizedStringFinder().strings

    # Read all existing localizations in the master localization
    master_strings = FileReader(FileReader.MASTER_LOCALIZATION).strings

    # Determine changes
    added_keys = [key for key in source_strings if key not in master_strings]
    removed_keys = [key for key in master_strings if key not in source_strings]

    # Generate a new master localization
    for key in removed_keys:
        del master_strings[key]
    for key in added_keys:
        master_strings[key] = source_strings[key]

    # output merged master
    path = os.path.join(FileReader.LOCALIZABLE_ROOT, FileReader.MASTER_LOCALIZATION, FileReader.LOCALIZABLE_NAME)
    write_file(path, master_strings)

    # output new strings for translation
    for localization in FileReader.LOCALIZATIONS:
        strings = FileReader(localization).strings
        added_keys = [key for key in master_strings if key not in strings]
        added_strings = dict((key, master_strings[key]) for key in added_keys)
        path = 'Resources/Localizations/New-{}.strings'.format(localization)
        write_file(path, added_strings)


if __name__ == '__main__':
    main()
