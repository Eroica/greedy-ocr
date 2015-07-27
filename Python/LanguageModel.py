import re
import nltk

class Lexicon(set):
    """

    """

    def __init__(self, lexicon_filename):
        """
        """

        super(Lexicon, self).__init__()

        self |= set([line.strip() for line in open(lexicon_filename)])

    def query(self, word):
        """
        """

        search_term = '^' + word + '$'

        return [word.group(0) for word in (re.search(search_term, l) for l in self) if word]

# class TrigramModel()

text = [x.strip() for x in open(CONFIG.MERCURIUS_FILE).read().split()]
freq = nltk.FreqDist(text)
bi = list(nltk.bigrams(text))
tri = list(nltk.ngrams(text, 3))