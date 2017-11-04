#! /usr/bin/env python

"""
Simple Named Entity Recogniser

Trained using a list of multi-token terms
Fed a stream of tokens
Spits out marked up regions in the text.
"""

import Tokeniser


class NerState:
    def __init__(self, token):
        self.token = token
        self.transitions = {}
        self.final_lengths = []

    def has_transition(self, token):
        return self.get_transition(token) is not None

    def get_transition(self, token):
        return self.transitions.get(token)

    def add_transition(self, token):
        assert token not in self.transitions
        new_state = NerState(token)
        self.transitions[token] = new_state
        return new_state

    def mark_final(self, token_length):
        self.final_lengths.append(token_length)

    def is_final(self):
        return len(self.final_lengths) != 0


class NerTraverser:
    def __init__(self, state):
        self.state = state
        self.collected_term = []

    def traverse(self, token):
        new_state = self.state.get_transition(token.value)
        if new_state is None:
            return None
        self.collected_term.append(token)
        self.state = new_state
        return self


class SimpleNer:
    def __init__(self, label, edit_tolerance=0):
        self.label = label
        self.edit_tolerance = edit_tolerance
        self.start_state = NerState(None)

    def train(self, terms):
        """
        Run through the terms and build the recogniser tree
        """
        for term in terms:
            self.train_term(term)

    def train_term(self, tokens):
        """
        Add a single sequence of tokens to the recogniser
        """
        state = self.start_state
        length = len(tokens)
        while tokens:
            next_token = tokens.pop(0).lower()
            if not state.has_transition(next_token):
                state = state.add_transition(next_token)
            else:
                state = state.get_transition(next_token)
            if len(tokens) == 0:
                state.mark_final(length)

    def recognise(self, tokens):
        result = []
        traversers = []
        for token in tokens:
            traversers.append(NerTraverser(self.start_state))
            traversers = filter(None, [traverser.traverse(token) for traverser in traversers])
            for traverser in traversers:
                if traverser.state.is_final():
                    for l in traverser.state.final_lengths:
                        result.append(traverser.collected_term[-l:])
        return result


if __name__ == '__main__':
    s = SimpleNer()
    s.train([['THIS', 'is', 'a', 'test'], ['simple'], ['simple', 'test'], ['test']])
    l = Tokeniser.Lexer()
    l.set_input('this is a TEST but not a SIMPLE test')

    print 'Parsing "%s"' % l.lexdata()
    hits = s.recognise(l.lexer)
    for hit in hits:
        s, e = hit[0].lexpos, hit[-1].lexpos+len(hit[-1].value)
        print 'found "%s" at [%d, %d)' % (l.lexer.lexdata[s:e], s, e)
