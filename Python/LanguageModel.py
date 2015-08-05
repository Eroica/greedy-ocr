import re
import nltk

import gr_config as CONFIG

class NgramModel(dict):
    """

    """

    def __init__(self, text, n=2):
        """
        """

        super(NgramModel, self).__init__()

        _ngrams = list(nltk.ngrams(text, n))

        for word_pair in _ngrams:
            if word_pair[0] not in self:
                self[word_pair[0]] = Bag()

            for i in range(1, n):
                self[word_pair[0]].insert(word_pair[i])


class Bag(dict):
    """This data structure describes how often a specific word has been
    seen in a text. Every word is a key and the value a counter starting
    at `1'. If the word is encountered again, the counter increments.

    """

    def __init__(self):
        """Creates and returns a new `Bag' object.
        """

        super(Bag, self).__init__()

    def insert(self, key):
        """Insert a word into `self'. If the word is already found,
        increment its counter.
        """

        try:
            self[key] += 1
        except KeyError:
            self[key] = 1

    def remove(self, key):
        """Decrement a word's counter. If the counter reaches `0', the
        word gets deleted from `self'.
        """

        count = self[key]
        self[key] = (count and count > 1) and count - 1 or 0

        if self[key] == 0:
            del self[key]


class Lexicon(set):
    """

    """

    def __init__(self, lexicon_filename):
        """
        """

        super(Lexicon, self).__init__()

        try:
            self |= set([line.strip() for line in open(lexicon_filename)])
        except IOError:
            print "File `" + lexicon_filename + "' could not be found!"

    def query(self, word):
        """
        """

        search_term = '^' + word + '$'

        return [word.group(0) for word in (re.search(search_term, l) for l in self) if word]