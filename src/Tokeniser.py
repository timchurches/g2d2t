#! /usr/bin/env python

from ply import lex


class Lexer:
    UNIQUE_WORDS = {
        }

    tokens = [
        'WORD',
        'OTHER',
        ]

    # token regexes
    t_ignore = " \t"

    # track linenos
    def t_newline(self, t):
        r'\n+'
        t.lexer.lineno += len(t.value)

    # skip errors
    def t_error(self, t):
        print "illegal sequence '%s'" % t.value[0]
        t.lexer.skip(1)

    # handle words
    def t_WORD(self, t):
        r'(?i)[a-z\-_0-9(){}:,]+'
        t.type = self.UNIQUE_WORDS.get(t.value, 'WORD')
        return t

    def t_OTHER(self, t):
        r'.'
        return t

    def __init__(self, **kwargs):
        self.lexer = lex.lex(module=self, **kwargs)

    def set_input(self, input_data):
        self.lexer.input(input_data)

    def lexdata(self):
        return self.lexer.lexdata


if __name__ == '__main__':
    l = Lexer()
    l.set_input('this is a TEST but not a simple test: 2,2-bis(4-hydroxy-3-tert-butylphenyl)propane')
    for tok in l.lexer:
        print tok
